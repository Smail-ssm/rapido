// lib/widgets/bill_history_item.dart
import 'package:flutter/material.dart';

class BillHistoryItem extends StatelessWidget {
  final String date;
  final double totalAmount;
  final String description;
  final String vendor;
  final VoidCallback onPrint;
  final VoidCallback onTap;

  const BillHistoryItem({
    Key? key,
    required this.date,
    required this.totalAmount,
    required this.description,
    required this.vendor,
    required this.onPrint,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text('Date: $date'),
          subtitle: Text('Amount: \$${totalAmount.toStringAsFixed(2)}\nDescription: $description'),
          trailing: IconButton(
            icon: const Icon(Icons.print),
            color: Colors.blue,
            tooltip: 'Print Bill',
            onPressed: onPrint,
          ),
        ),
      ),
    );
  }
}
