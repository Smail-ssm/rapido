import 'package:flutter/material.dart';

class ProductItem extends StatelessWidget {
  final String name;       // Product name
  final String category;   // Product category
  final int quantity;      // Quantity available
  final double price;      // Price per unit
  final String barcode;    // Barcode of the product
  final VoidCallback onTap;       // Callback for tap
  final VoidCallback onLongPress; // Callback for long press

  const ProductItem({
    Key? key,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    required this.barcode,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,               // Trigger onTap callback
      onLongPress: onLongPress,   // Trigger onLongPress callback
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: $category'),
              Text('Quantity: $quantity'),
              Text('Price: ${price.toStringAsFixed(2)}  Dt'),
              Text('Barcode: $barcode'),
            ],
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
