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
  final TextEditingController _barcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the form with the current product values
    _nameController.text = widget.product.name;
    _categoryController.text = widget.product.category;
    _quantityController.text = widget.product.quantity.toString();
    _priceController.text = widget.product.price.toString();
    _barcodeController.text = widget.product.barcode;
  }

  Future<void> _updateProduct() async {
    try {
      final String name = _nameController.text.trim();
      final String category = _categoryController.text.trim();
      final int quantity = int.parse(_quantityController.text.trim());
      final double price = double.parse(_priceController.text.trim());
      final String barcode = _barcodeController.text.trim();

      if (name.isEmpty || category.isEmpty || barcode.isEmpty) {
        throw Exception('Name, category, and barcode are required.');
      }

      await _productRef
          .child(Utils.getDatabasePath())
          .child('sari3')
          .child('products')
          .child(widget.product.id) // Use the product's ID to update
          .update({
        'name': name,
        'category': category,
        'quantity': quantity,
        'price': price,
        'barcode': barcode,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateProduct,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit Product Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _barcodeController,
                decoration: const InputDecoration(
                  labelText: 'Barcode',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _updateProduct,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
