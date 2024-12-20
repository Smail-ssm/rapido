import 'package:flutter/material.dart';
import '../model/Bill.dart';
 import '../service/PrinterService.dart';

class SingleBillPage extends StatelessWidget {
  final Bill bill;
  final PrinterService _printerService = PrinterService();

  SingleBillPage({super.key, required this.bill});

  Future<void> _printBill(BuildContext context) async {
    try {
      await _printerService.printBill(context, bill);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill printed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to print bill: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<BillItem> products = bill.items;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Header
            Card(
              margin: const EdgeInsets.only(bottom: 20),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bill Date: ${bill.date}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Client: ${bill.client.name}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Amount: \$${bill.totalTTC.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Products Section
            const Text(
              'Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            products.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                      'Price: \$${product.unitPrice.toStringAsFixed(2)} x ${product.quantity}',
                    ),
                    trailing: Text(
                      'Total: \$${product.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            )
                : const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No products found in this bill.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Additional Description
            Card(
              margin: const EdgeInsets.only(top: 20),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Additional Notes: ${bill.description ?? "No additional notes"}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
