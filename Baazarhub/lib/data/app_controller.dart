import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'marketplace_repository.dart';
import 'models.dart';

class AppController extends ChangeNotifier {
  AppController(this.repository) : _user = repository.currentUser;

  final MarketplaceRepository repository;
  AppUser? _user;
  List<Product> _products = [];
  final Map<String, int> _cart = {};
  final Set<String> _favorites = {};
  List<MarketplaceOrder> _orders = [];
  bool _busy = false;
  String _query = '';
  String _category = 'All';
  double? _minPrice;
  double? _maxPrice;
  bool _darkMode = false;
  Uint8List? _avatarBytes;
  final Map<String, List<ProductReview>> _reviews = {};

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get busy => _busy;
  String get query => _query;
  String get category => _category;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  bool get hasPriceFilter => _minPrice != null || _maxPrice != null;
  bool get darkMode => _darkMode;
  Uint8List? get avatarBytes => _avatarBytes;
  List<MarketplaceOrder> get orders => List.unmodifiable(_orders);
  Set<String> get favorites => Set.unmodifiable(_favorites);
  int get cartCount => _cart.values.fold(0, (sum, quantity) => sum + quantity);
  double get highestPrice => _products.isEmpty
      ? 10000
      : _products.map((item) => item.price).reduce((a, b) => a > b ? a : b);

  List<String> get categories => [
        'All',
        ...{for (final product in _products) product.category},
      ];

  List<Product> get products {
    final term = _query.toLowerCase().trim();
    return _products.where((product) {
      final inCategory = _category == 'All' || product.category == _category;
      final matches = term.isEmpty ||
          product.title.toLowerCase().contains(term) ||
          product.description.toLowerCase().contains(term);
      final aboveMinimum = _minPrice == null || product.price >= _minPrice!;
      final belowMaximum = _maxPrice == null || product.price <= _maxPrice!;
      return inCategory && matches && aboveMinimum && belowMaximum;
    }).toList();
  }

  List<Product> get myProducts =>
      _products.where((product) => product.sellerId == _user?.id).toList();

  List<CartLine> get cartLines => _cart.entries.map((entry) {
        final product = _products.firstWhere((item) => item.id == entry.key);
        return CartLine(product: product, quantity: entry.value);
      }).toList();

  double get cartSubtotal =>
      cartLines.fold(0, (sum, line) => sum + line.total);

  Future<void> initialize() async {
    _busy = true;
    notifyListeners();
    try {
      // Repositories may return const/unmodifiable collections. The controller
      // owns mutable state because products and orders are inserted locally
      // after a successful publish or checkout.
      _products = List<Product>.of(await repository.getProducts());
      _orders = List<MarketplaceOrder>.of(await repository.getOrders());
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    await _run(() async {
      _user = await repository.signIn(email, password);
      _orders = List<MarketplaceOrder>.of(await repository.getOrders());
    });
  }

  Future<void> signUp(String name, String email, String password) async {
    await _run(() async => _user = await repository.signUp(name, email, password));
  }

  Future<void> signOut() async {
    await repository.signOut();
    _user = null;
    _cart.clear();
    _avatarBytes = null;
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void setPriceRange(double? minimum, double? maximum) {
    _minPrice = minimum;
    _maxPrice = maximum;
    notifyListeners();
  }

  void clearPriceFilter() => setPriceRange(null, null);

  Future<void> uploadProfileImage(Uint8List imageBytes) async {
    await _run(() async {
      _user = await repository.uploadProfileImage(imageBytes);
      _avatarBytes = imageBytes;
    });
  }

  void search(String value) {
    _query = value;
    notifyListeners();
  }

  void selectCategory(String value) {
    _category = value;
    notifyListeners();
  }

  void toggleFavorite(String productId) {
    _favorites.contains(productId)
        ? _favorites.remove(productId)
        : _favorites.add(productId);
    notifyListeners();
  }

  void addToCart(Product product) {
    final next = (_cart[product.id] ?? 0) + 1;
    if (next <= product.stock) _cart[product.id] = next;
    notifyListeners();
  }

  void changeQuantity(Product product, int delta) {
    final next = (_cart[product.id] ?? 0) + delta;
    if (next <= 0) {
      _cart.remove(product.id);
    } else if (next <= product.stock) {
      _cart[product.id] = next;
    }
    notifyListeners();
  }

  Future<void> addProduct(Product product, Uint8List? imageBytes) async {
    await _run(() async {
      final saved = await repository.addProduct(product, imageBytes);
      _products.insert(0, saved);
    });
  }

  Future<void> deleteProduct(String id) async {
    await _run(() async {
      await repository.deleteProduct(id);
      _products.removeWhere((product) => product.id == id);
      _cart.remove(id);
    });
  }

  List<ProductReview> reviewsFor(String productId) =>
      List.unmodifiable(_reviews[productId] ?? const []);

  double averageRating(String productId) {
    final items = _reviews[productId] ?? const <ProductReview>[];
    if (items.isEmpty) return 0;
    return items.fold<int>(0, (sum, item) => sum + item.rating) / items.length;
  }

  Future<void> loadReviews(String productId) async {
    final items = await repository.getReviews(productId);
    _reviews[productId] = List<ProductReview>.of(items);
    notifyListeners();
  }

  Future<void> submitReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    await _run(() async {
      final saved = await repository.addReview(
        productId: productId,
        rating: rating,
        comment: comment,
      );
      final items = _reviews.putIfAbsent(productId, () => []);
      items.removeWhere((item) => item.userId == saved.userId);
      items.insert(0, saved);
    });
  }

  Future<MarketplaceOrder> checkout(String address, String paymentMethod) async {
    late MarketplaceOrder order;
    await _run(() async {
      order = await repository.placeOrder(
        items: cartLines,
        address: address,
        paymentMethod: paymentMethod,
      );
      _orders.insert(0, order);
      _cart.clear();
    });
    return order;
  }

  Future<void> _run(Future<void> Function() action) async {
    _busy = true;
    notifyListeners();
    try {
      await action();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
