// lib/widgets/bill_item.dart
import 'package:flutter/material.dart';

class BillItem extends StatelessWidget {
  final String date;
  final double totalAmount; // Change to double
  final String description;
  final VoidCallback onPrint;
  final VoidCallback onTap; // Callback for item tap

  const BillItem({
    super.key,
    required this.date,
    required this.totalAmount, // Use double type for totalAmount
    required this.description,
    required this.onPrint,
    required this.onTap, // Pass onTap as a parameter
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Trigger the onTap action when the item is clicked
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
