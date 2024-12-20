import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../util/utils.dart';

class AddProductForm extends StatefulWidget {
  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _barcodeController = TextEditingController();

  final DatabaseReference _productsRef = FirebaseDatabase.instance
      .ref()
      .child(Utils.getDatabasePath())
      .child('sari3')
      .child('products');

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      final newProduct = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _categoryController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'quantity': int.parse(_quantityController.text.trim()),
        'barcode': _barcodeController.text.trim(),
        'addedDate': DateTime.now().toIso8601String(),
      };

      try {
        await _productsRef.push().set(newProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add Product',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value == null || value.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value == null || value.isEmpty ? 'Category is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Price is required';
                }
                if (double.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Quantity is required';
                }
                if (int.tryParse(value) == null) {
                  return 'Enter a valid integer';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'Barcode',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value == null || value.isEmpty ? 'Barcode is required' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
