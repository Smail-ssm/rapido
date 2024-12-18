import 'package:flutter/material.dart';

class ProductDTO extends StatelessWidget {
  final String name;
   final int quantity;
  final double price;  // Callback for long press

  const ProductDTO({
    Key? key,
    required this.name,
     required this.quantity,
    required this.price,
 }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          title: Text(name),
          subtitle: Text(' Quantity: $quantity, Price: $price'),
        ),
      ),
    );
  }
}