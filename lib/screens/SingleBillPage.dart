// lib/screens/single_bill_page.dart
import 'package:flutter/material.dart';

import '../model/PrintedArticle.dart';
 import '../service/PrinterService.dart';

class SingleBillPage extends StatelessWidget {
  final PrintedArticle bill; // Changed from Map to PrintedArticle
  final PrinterService _printerService = PrinterService();

  SingleBillPage({super.key, required this.bill});

  Future<void> _printBill(BuildContext context) async {
    await _printerService.printBill(context, bill); // Pass PrintedArticle directly
  }

  @override
  Widget build(BuildContext context) {
    final products = bill.bill.items; // Accessing items from Bill inside PrintedArticle

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printBill(context),
            tooltip: 'Print Bill',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${bill.bill.date}', // Access date from Bill inside PrintedArticle
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Amount: \$${bill.totalTTC.toStringAsFixed(2)}', // Use totalTTC from PrintedArticle
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            products.isNotEmpty
                ? Column(
              children: products.map<Widget>((product) {
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('Price: \$${product.unitPrice} x ${product.quantity}'),
                  trailing: Text('Total: \$${product.total.toStringAsFixed(2)}'),
                );
              }).toList(),
            )
                : const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No products found in this bill.'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Description: ${bill.bill.clientName}', // Use client name as a placeholder description
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
