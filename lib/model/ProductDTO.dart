import 'package:flutter/material.dart';

class ProductDTO extends StatelessWidget {
  final String name;
  final int quantity;
  final double unitPrice;
  final double remise;
  final String barcode;

  const ProductDTO({
    Key? key,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.remise,
    required this.barcode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate total price for display
    double totalPrice = quantity * (unitPrice - remise);

    return GestureDetector(
      onTap: () {
        // Handle tap events (e.g., navigate to product details)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected product: $name')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quantity: $quantity'),
              Text('Unit Price:  ${unitPrice.toStringAsFixed(2)} Dt'),
              Text('Remise:  ${remise.toStringAsFixed(2)} Dt'),
              Text('Total Price:  ${totalPrice.toStringAsFixed(2)}  Dt'),
              Text('Barcode: $barcode'),
            ],
          ),
          trailing: Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
