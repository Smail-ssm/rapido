class Product {
  final String id; // Unique identifier for the product
  final String name; // Name of the product
  final String description; // Product description
  final String category; // Product category
  final double price; // Price of the product
  final int quantity; // Quantity in stock
   final DateTime addedDate; // Date the product was added
  bool isSelected = false; // Track selection state

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.quantity,
     required this.addedDate,
  });

  factory Product.fromMap(String id, Map<dynamic, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      price: (data['price'] as num).toDouble(),
      quantity: data['quantity'] as int,
       addedDate: DateTime.parse(data['addedDate'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'quantity': quantity,
       'addedDate': addedDate.toIso8601String(),
    };
  }
}
