import 'package:flutter/material.dart';

class ClientItem extends StatelessWidget {
  final String name;
  final String matriculeFiscal;
  final int deliveriesCount;

  const ClientItem({
    Key? key,
    required this.name,
    required this.matriculeFiscal,
    required this.deliveriesCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Client Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Matricule Fiscal: $matriculeFiscal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Deliveries: $deliveriesCount',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            // Icon or Image
            Column(
              children: [
                Icon(
                  Icons.local_shipping,
                  color: Colors.blueAccent,
                  size: 36,
                ),
                const SizedBox(height: 6),
                Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
