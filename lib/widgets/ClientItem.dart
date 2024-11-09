// lib/screens/widgets/client_item.dart
import 'package:flutter/material.dart';

class ClientItem extends StatelessWidget {
  final String name;
  final String socialReason;
  final int deliveriesCount;

  const ClientItem({
    Key? key,
    required this.name,
    required this.socialReason,
    required this.deliveriesCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Social Reason: $socialReason',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Deliveries: $deliveriesCount',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            Icon(Icons.local_shipping, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }
}
