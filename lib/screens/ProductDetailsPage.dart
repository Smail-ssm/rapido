// lib/screens/product_details_page.dart
import 'package:flutter/material.dart';

import '../model/Product.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text("Price: \$${product.price.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18)),
            Text("Quantity: ${product.quantity}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text(
              "Category: ${product.category}",
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Text(
              "Status: ${product.status}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              "Date Added: ${product.dateAdded.toLocal()}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Date Updated: ${product.dateUpdated.toLocal()}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              "Description:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
