class Product {
  final String id; // Unique identifier for the product
  final String name; // Name of the product
  final String description; // Product description
  final String category; // Product category
  final double price; // Price of the product
  final int quantity; // Quantity in stock
  final DateTime addedDate; // Date the product was added
  final String barcode; // Barcode of the product
  bool isSelected = false; // Track selection state

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.quantity,
    required this.addedDate,
    required this.barcode,
  });

  /// Factory constructor to create a `Product` object from a map.
  factory Product.fromMap(String id, Map<dynamic, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      price: (data['price'] as num).toDouble(),
      quantity: data['quantity'] as int,
      addedDate: DateTime.parse(data['addedDate'] as String),
      barcode: data['barcode'] as String,
    );
  }

  /// Convert `Product` object to a map for serialization.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'quantity': quantity,
      'addedDate': addedDate.toIso8601String(),
      'barcode': barcode,
    };
  }

  /// Update an existing `Product` object with new data while preserving unchanged fields.
  Product copyWith({
    String? name,
    String? description,
    String? category,
    double? price,
    int? quantity,
    DateTime? addedDate,
    String? barcode,
    bool? isSelected,
  }) {
    return Product(
      id: this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      addedDate: addedDate ?? this.addedDate,
      barcode: barcode ?? this.barcode,
    )..isSelected = isSelected ?? this.isSelected;
  }
}
