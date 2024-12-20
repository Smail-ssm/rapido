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
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and Vendor
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date: $date',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Vendor: $vendor',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Total Amount
              Text(
                'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                'Description: $description',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.print),
                    color: Colors.blue,
                    tooltip: 'Print Bill',
                    onPressed: onPrint,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onTap,
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
