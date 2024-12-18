import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../model/Product.dart';
import '../util/utils.dart';

class SingleProductPage extends StatefulWidget {
  final Product product;

  const SingleProductPage({Key? key, required this.product}) : super(key: key);

  @override
  _SingleProductPageState createState() => _SingleProductPageState();
}

class _SingleProductPageState extends State<SingleProductPage> {
  final DatabaseReference _productRef = FirebaseDatabase.instance.ref();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the form with the current product values
    _nameController.text = widget.product.name;
    _categoryController.text = widget.product.category;
    _quantityController.text = widget.product.quantity.toString();
    _priceController.text = widget.product.price.toString();
  }

  Future<void> _updateProduct() async {
    // Get the new values from the form
    final String name = _nameController.text.trim();
    final String category = _categoryController.text.trim();
    final int quantity = int.parse(_quantityController.text.trim());
    final double price = double.parse(_priceController.text.trim());

    // Update the product in the Firebase Realtime Database
    await _productRef
        .child(Utils.getDatabasePath())
        .child('sari3')
        .child('products')
        .child(widget.product.id)  // Use the product's ID to update
        .update({
      'name': name,
      'category': category,
      'quantity': quantity,
      'price': price,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
      Navigator.pop(context); // Close the page after saving
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateProduct, // Save on button press
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Price'),
            ),
          ],
        ),
      ),
    );
  }
}
