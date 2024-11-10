// lib/screens/generate_bill_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
 import '../model/Client.dart';
import '../util/utils.dart';

class Product {
  final String name;
  final double price;
  final int quantity;

  Product({required this.name, required this.price, required this.quantity});

  double get total => price * quantity;
}

class GenerateBillPage extends StatefulWidget {
  final Client client;

  const GenerateBillPage({super.key, required this.client});

  @override
  _GenerateBillPageState createState() => _GenerateBillPageState();
}

class _GenerateBillPageState extends State<GenerateBillPage> {
  final DatabaseReference _billsRef = FirebaseDatabase.instance.ref().child(Utils.getDatabasePath()).child('bills');
  final List<Product> _products = [];
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _vendorController = TextEditingController(); // Controller for vendor name

  void _addProduct() {
    if (_productNameController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty) {
      final product = Product(
        name: _productNameController.text,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
      );

      setState(() {
        _products.add(product);
      });

      // Clear the input fields
      _productNameController.clear();
      _priceController.clear();
      _quantityController.clear();
    }
  }

  Future<void> _saveBill() async {
    final billData = {
      'clientId': widget.client.id,
      'clientName': widget.client.name,
      'vendor': _vendorController.text, // Save vendor name
      'products': _products.map((product) => {
        'name': product.name,
        'price': product.price,
        'quantity': product.quantity,
        'total': product.total,
      }).toList(),
      'totalAmount': _products.fold(0.0, (sum, item) => sum + item.total),
      'date': DateTime.now().toIso8601String(),
    };

    await _billsRef.child(widget.client.id).push().set(billData);
    Navigator.pop(context); // Close the bill generation page after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Bill for ${widget.client.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveBill,
            tooltip: 'Save Bill',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.client.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Social Reason: ${widget.client.socialReason}'),
                    Text('Contact Number: ${widget.client.contactNumber}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _vendorController,
              decoration: const InputDecoration(labelText: 'Vendor Name'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _productNameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('Add Product'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Products List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: _products.map((product) {
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('Price: \$${product.price} x ${product.quantity}'),
                  trailing: Text('Total: \$${product.total.toStringAsFixed(2)}'),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Total Amount: \$${_products.fold(0.0, (sum, item) => sum + item.total).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
