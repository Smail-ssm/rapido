import 'package:flutter/material.dart';

class ProductItem extends StatelessWidget {
  final String name;
  final String category;
  final int quantity;
  final double price;
  final VoidCallback onTap;       // Callback for tap
  final VoidCallback onLongPress; // Callback for long press

  const ProductItem({
    Key? key,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    required this.onTap,
    required this.onLongPress,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,               // Call onTap
      onLongPress: onLongPress,   // Call onLongPress
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          title: Text(name),
          subtitle: Text('Category: $category, Quantity: $quantity, Price: $price'),
        ),
      ),
    );
  }
}