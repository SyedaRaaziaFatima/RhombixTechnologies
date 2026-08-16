enum ProductCondition { newItem, used }

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.avatarUrl = '',
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String avatarUrl;

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'] as String,
        name: (map['full_name'] as String?) ?? 'User',
        email: (map['email'] as String?) ?? '',
        phone: (map['phone'] as String?) ?? '',
        address: (map['address'] as String?) ?? '',
        avatarUrl: (map['avatar_url'] as String?) ?? '',
      );

  AppUser copyWith({String? avatarUrl}) => AppUser(
        id: id,
        name: name,
        email: email,
        phone: phone,
        address: address,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );
}

class Product {
  const Product({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.condition,
    required this.stock,
    this.isFeatured = false,
  });

  final String id;
  final String sellerId;
  final String sellerName;
  final String title;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final ProductCondition condition;
  final int stock;
  final bool isFeatured;

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'] as String,
        sellerId: map['seller_id'] as String,
        sellerName: (map['seller_name'] as String?) ?? 'BazaarHub Seller',
        title: map['title'] as String,
        description: map['description'] as String,
        category: map['category'] as String,
        price: (map['price'] as num).toDouble(),
        imageUrl: (map['image_url'] as String?) ?? '',
        condition: map['condition'] == 'used'
            ? ProductCondition.used
            : ProductCondition.newItem,
        stock: (map['stock'] as num?)?.toInt() ?? 1,
        isFeatured: (map['is_featured'] as bool?) ?? false,
      );

  Map<String, dynamic> toInsertMap() => {
        'seller_id': sellerId,
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'image_url': imageUrl,
        'condition': condition == ProductCondition.used ? 'used' : 'new',
        'stock': stock,
      };
}

class CartLine {
  const CartLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get total => product.price * quantity;
}

class MarketplaceOrder {
  const MarketplaceOrder({
    required this.id,
    required this.buyerId,
    required this.items,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.createdAt,
  });

  final String id;
  final String buyerId;
  final List<CartLine> items;
  final double total;
  final OrderStatus status;
  final String paymentMethod;
  final String shippingAddress;
  final DateTime createdAt;
}

class ProductReview {
  const ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  factory ProductReview.fromMap(Map<String, dynamic> map) => ProductReview(
        id: map['id'] as String,
        productId: map['product_id'] as String,
        userId: map['user_id'] as String,
        userName: (map['user_name'] as String?) ?? 'BazaarHub User',
        rating: (map['rating'] as num).toInt(),
        comment: (map['comment'] as String?) ?? '',
        createdAt: DateTime.tryParse('${map['created_at']}') ?? DateTime.now(),
      );
}
