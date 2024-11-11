// lib/services/product_service.dart
import 'package:Rappido/util/utils.dart';
import 'package:firebase_database/firebase_database.dart';
import '../model/Product.dart';

class ProductService {
  final DatabaseReference _productsRef = FirebaseDatabase.instance
      .ref().child(Utils.getDatabasePath())
        .child('users')
        .child(Utils.getDatabasePath())
      .child('products');

  Future<List<Product>> fetchProducts() async {
    final snapshot = await _productsRef.get();
    if (snapshot.exists) {
      final productsMap = snapshot.value as Map<dynamic, dynamic>;
      return productsMap.entries.map((entry) {
        return Product.fromMap(entry.value as Map<dynamic, dynamic>, entry.key as String);
      }).toList();
    }
    return [];
  }

  Future<void> addProduct(Product product) async {
    // Generate a unique ID using push() and set the product data
    await _productsRef.push().set(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _productsRef.child(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _productsRef.child(productId).remove();
  }
}
