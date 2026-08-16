import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'models.dart';

abstract class MarketplaceRepository {
  AppUser? get currentUser;
  Future<AppUser> signIn(String email, String password);
  Future<AppUser> signUp(String name, String email, String password);
  Future<void> signOut();
  Future<AppUser> uploadProfileImage(Uint8List imageBytes);
  Future<List<Product>> getProducts();
  Future<Product> addProduct(Product product, Uint8List? imageBytes);
  Future<void> deleteProduct(String productId);
  Future<MarketplaceOrder> placeOrder({
    required List<CartLine> items,
    required String address,
    required String paymentMethod,
  });
  Future<List<MarketplaceOrder>> getOrders();
  Future<List<ProductReview>> getReviews(String productId);
  Future<ProductReview> addReview({
    required String productId,
    required int rating,
    required String comment,
  });
}

class DemoMarketplaceRepository implements MarketplaceRepository {
  AppUser? _currentUser;
  final List<Product> _products = [
    const Product(
      id: 'p1',
      sellerId: 'seller-1',
      sellerName: 'Tech World',
      title: 'Wireless Headphones',
      description:
          'Premium over-ear headphones with deep bass, clear calls and long battery life.',
      category: 'Electronics',
      price: 7499,
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=900',
      condition: ProductCondition.newItem,
      stock: 8,
      isFeatured: true,
    ),
    const Product(
      id: 'p2',
      sellerId: 'seller-2',
      sellerName: 'Urban Style',
      title: 'Classic Wrist Watch',
      description:
          'Minimal black dial watch with a premium metal strap for everyday wear.',
      category: 'Fashion',
      price: 4250,
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=900',
      condition: ProductCondition.newItem,
      stock: 12,
      isFeatured: true,
    ),
    const Product(
      id: 'p3',
      sellerId: 'seller-3',
      sellerName: 'Sneaker Stop',
      title: 'Running Sneakers',
      description:
          'Lightweight cushioned sneakers suitable for running and daily use.',
      category: 'Shoes',
      price: 5999,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=900',
      condition: ProductCondition.newItem,
      stock: 5,
    ),
    const Product(
      id: 'p4',
      sellerId: 'seller-4',
      sellerName: 'Home Craft',
      title: 'Modern Table Lamp',
      description:
          'Warm bedside lamp with an elegant shape and energy-efficient light.',
      category: 'Home',
      price: 2899,
      imageUrl:
          'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=900',
      condition: ProductCondition.used,
      stock: 1,
    ),
  ];
  final List<MarketplaceOrder> _orders = [];
  final Map<String, List<ProductReview>> _reviews = {};

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<AppUser> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (email.trim().isEmpty || password.length < 6) {
      throw Exception('Valid email aur kam az kam 6 character password likhein.');
    }
    return _currentUser = AppUser(
      id: 'demo-user',
      name: 'Husnain',
      email: email.trim(),
      address: 'Burewala, Punjab, Pakistan',
    );
  }

  @override
  Future<AppUser> signUp(String name, String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (name.trim().length < 2 ||
        !email.contains('@') ||
        password.length < 6) {
      throw Exception('Name, valid email aur 6+ character password zaroori hai.');
    }
    return _currentUser = AppUser(
      id: 'demo-user',
      name: name.trim(),
      email: email.trim(),
    );
  }

  @override
  Future<void> signOut() async => _currentUser = null;

  @override
  Future<AppUser> uploadProfileImage(Uint8List imageBytes) async {
    if (_currentUser == null) throw Exception('Please login first.');
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _currentUser!;
  }

  @override
  Future<List<Product>> getProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_products);
  }

  @override
  Future<Product> addProduct(Product product, Uint8List? imageBytes) async {
    final saved = Product(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      sellerId: product.sellerId,
      sellerName: product.sellerName,
      title: product.title,
      description: product.description,
      category: product.category,
      price: product.price,
      imageUrl: product.imageUrl.isEmpty
          ? 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=900'
          : product.imageUrl,
      condition: product.condition,
      stock: product.stock,
    );
    _products.insert(0, saved);
    return saved;
  }

  @override
  Future<void> deleteProduct(String productId) async {
    _products.removeWhere((product) => product.id == productId);
  }

  @override
  Future<MarketplaceOrder> placeOrder({
    required List<CartLine> items,
    required String address,
    required String paymentMethod,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (_currentUser == null) throw Exception('Please login first.');
    final order = MarketplaceOrder(
      id: 'BH-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      buyerId: _currentUser!.id,
      items: List.unmodifiable(items),
      total: items.fold(0, (sum, line) => sum + line.total),
      status: OrderStatus.confirmed,
      paymentMethod: paymentMethod,
      shippingAddress: address,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, order);
    return order;
  }

  @override
  Future<List<MarketplaceOrder>> getOrders() async => List.unmodifiable(_orders);

  @override
  Future<List<ProductReview>> getReviews(String productId) async =>
      List.unmodifiable(_reviews[productId] ?? const []);

  @override
  Future<ProductReview> addReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    if (_currentUser == null) throw Exception('Please login first.');
    final review = ProductReview(
      id: 'review-${DateTime.now().microsecondsSinceEpoch}',
      productId: productId,
      userId: _currentUser!.id,
      userName: _currentUser!.name,
      rating: rating,
      comment: comment.trim(),
      createdAt: DateTime.now(),
    );
    final list = _reviews.putIfAbsent(productId, () => []);
    list.removeWhere((item) => item.userId == _currentUser!.id);
    list.insert(0, review);
    return review;
  }
}

class SupabaseMarketplaceRepository implements MarketplaceRepository {
  SupabaseMarketplaceRepository(this.client);

  final SupabaseClient client;

  @override
  AppUser? get currentUser {
    final user = client.auth.currentUser;
    if (user == null) return null;
    return AppUser(
      id: user.id,
      name: (user.userMetadata?['full_name'] as String?) ?? 'User',
      email: user.email ?? '',
    );
  }

  @override
  Future<AppUser> signIn(String email, String password) async {
    final response = await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final user = response.user;
    if (user == null) throw Exception('Login failed.');
    final data = await client.from('profiles').select().eq('id', user.id).single();
    return AppUser.fromMap(data);
  }

  @override
  Future<AppUser> signUp(String name, String email, String password) async {
    final response = await client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': name.trim()},
    );
    final user = response.user;
    if (user == null) throw Exception('Signup failed. Email verification check karein.');
    if (response.session == null) {
      throw Exception('Verification email open karein, phir login karein.');
    }
    return AppUser(id: user.id, name: name.trim(), email: email.trim());
  }

  @override
  Future<void> signOut() => client.auth.signOut();

  @override
  Future<AppUser> uploadProfileImage(Uint8List imageBytes) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('Please login first.');
    final path = '${user.id}/avatar-${DateTime.now().microsecondsSinceEpoch}.jpg';
    await client.storage.from('avatars').uploadBinary(
          path,
          imageBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    final avatarUrl = client.storage.from('avatars').getPublicUrl(path);
    final profile = await client
        .from('profiles')
        .update({'avatar_url': avatarUrl})
        .eq('id', user.id)
        .select()
        .single();
    return AppUser.fromMap(profile);
  }

  @override
  Future<List<Product>> getProducts() async {
    final rows = await client
        .from('products')
        .select('*, seller_profiles!products_seller_id_fkey(full_name)')
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return (rows as List).map((raw) {
      final map = Map<String, dynamic>.from(raw as Map);
      final profile = map['seller_profiles'] as Map<String, dynamic>?;
      map['seller_name'] = profile?['full_name'];
      return Product.fromMap(map);
    }).toList();
  }

  @override
  Future<Product> addProduct(Product product, Uint8List? imageBytes) async {
    var imageUrl = product.imageUrl;
    if (imageBytes != null) {
      final path = '${product.sellerId}/${DateTime.now().microsecondsSinceEpoch}.jpg';
      await client.storage.from('product-images').uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      imageUrl = client.storage.from('product-images').getPublicUrl(path);
    }
    final map = product.toInsertMap()..['image_url'] = imageUrl;
    final raw = await client.from('products').insert(map).select().single();
    final saved = Map<String, dynamic>.from(raw)
      ..['seller_name'] = currentUser?.name;
    return Product.fromMap(saved);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await client.from('products').update({'is_active': false}).eq('id', productId);
  }

  @override
  Future<MarketplaceOrder> placeOrder({
    required List<CartLine> items,
    required String address,
    required String paymentMethod,
  }) async {
    final result = await client.rpc('create_marketplace_order', params: {
      'p_shipping_address': address,
      'p_payment_method': paymentMethod,
      'p_items': items
          .map((line) => {
                'product_id': line.product.id,
                'quantity': line.quantity,
              })
          .toList(),
    });
    final map = Map<String, dynamic>.from(result as Map);
    return MarketplaceOrder(
      id: map['order_number'] as String,
      buyerId: currentUser!.id,
      items: List.unmodifiable(items),
      total: (map['total'] as num).toDouble(),
      status: OrderStatus.confirmed,
      paymentMethod: paymentMethod,
      shippingAddress: address,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<MarketplaceOrder>> getOrders() async {
    final user = currentUser;
    if (user == null) return const [];
    final rows = await client
        .from('orders')
        .select('*, order_items(*)')
        .eq('buyer_id', user.id)
        .order('created_at', ascending: false);
    return (rows as List).map((raw) {
      final map = Map<String, dynamic>.from(raw as Map);
      final rawItems = (map['order_items'] as List?) ?? const [];
      final items = rawItems.map((rawItem) {
        final item = Map<String, dynamic>.from(rawItem as Map);
        final quantity = (item['quantity'] as num).toInt();
        final product = Product(
          id: item['product_id'] as String,
          sellerId: item['seller_id'] as String,
          sellerName: 'BazaarHub Seller',
          title: item['product_title'] as String,
          description: 'Previously ordered product',
          category: 'Order',
          price: (item['unit_price'] as num).toDouble(),
          imageUrl: '',
          condition: ProductCondition.newItem,
          stock: quantity,
        );
        return CartLine(product: product, quantity: quantity);
      }).toList();
      final statusName = '${map['status']}';
      final status = OrderStatus.values.firstWhere(
        (item) => item.name == statusName,
        orElse: () => OrderStatus.pending,
      );
      return MarketplaceOrder(
        id: map['order_number'] as String,
        buyerId: map['buyer_id'] as String,
        items: items,
        total: (map['total'] as num).toDouble(),
        status: status,
        paymentMethod: map['payment_method'] as String,
        shippingAddress: map['shipping_address'] as String,
        createdAt: DateTime.tryParse('${map['created_at']}') ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<List<ProductReview>> getReviews(String productId) async {
    final rows = await client
        .from('reviews')
        .select('*, seller_profiles!reviews_user_id_fkey(full_name)')
        .eq('product_id', productId)
        .order('created_at', ascending: false);
    return (rows as List).map((raw) {
      final map = Map<String, dynamic>.from(raw as Map);
      final profile = map['seller_profiles'] as Map<String, dynamic>?;
      map['user_name'] = profile?['full_name'];
      return ProductReview.fromMap(map);
    }).toList();
  }

  @override
  Future<ProductReview> addReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('Please login first.');
    final raw = await client
        .from('reviews')
        .upsert(
          {
            'product_id': productId,
            'user_id': user.id,
            'rating': rating,
            'comment': comment.trim(),
          },
          onConflict: 'product_id,user_id',
        )
        .select()
        .single();
    final map = Map<String, dynamic>.from(raw)..['user_name'] = user.name;
    return ProductReview.fromMap(map);
  }
}
