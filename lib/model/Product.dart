class Product {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String description;
  final String category;
  final DateTime dateAdded;
  final DateTime dateUpdated;
  final String status;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.description,
    this.category = '',
    DateTime? dateAdded,
    DateTime? dateUpdated,
    this.status = 'active',
  })  : dateAdded = dateAdded ?? DateTime.now(),
        dateUpdated = dateUpdated ?? DateTime.now();

  // Factory method to create a Product from a Map
  factory Product.fromMap(Map<dynamic, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: data['price']?.toDouble() ?? 0.0,
      quantity: data['quantity'] ?? 0,
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      dateAdded: DateTime.parse(data['dateAdded'] ?? DateTime.now().toIso8601String()),
      dateUpdated: DateTime.parse(data['dateUpdated'] ?? DateTime.now().toIso8601String()),
      status: data['status'] ?? 'active',
    );
  }

  // Method to convert Product to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'description': description,
      'category': category,
      'dateAdded': dateAdded.toIso8601String(),
      'dateUpdated': dateUpdated.toIso8601String(),
      'status': status,
    };
  }
}
