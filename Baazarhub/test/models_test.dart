import 'package:bazaarhub/data/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cart line total uses product price and quantity', () {
    const product = Product(
      id: '1',
      sellerId: 'seller',
      sellerName: 'Seller',
      title: 'Test product',
      description: 'A valid test product description',
      category: 'Test',
      price: 1250,
      imageUrl: '',
      condition: ProductCondition.newItem,
      stock: 5,
    );

    const line = CartLine(product: product, quantity: 3);
    expect(line.total, 3750);
  });
}
