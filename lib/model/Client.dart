class Client {
  final String id;
  final String name;
  final String matriculeFiscal; // Tax registration number
  final String address;
  final String contactNumber;
  final int deliveriesCount;

  Client({
    required this.id,
    required this.name,
    required this.matriculeFiscal,
    required this.address,
    required this.contactNumber,
    required this.deliveriesCount,
  });

  /// Factory constructor to create a `Client` object from a map.
  factory Client.fromMap(String id, Map<dynamic, dynamic> data) {
    return Client(
      id: id,
      name: data['name'] ?? '',
      matriculeFiscal: data['matriculeFiscal'] ?? '',
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      deliveriesCount: data['deliveriesCount'] ?? 0,
    );
  }

  /// Convert `Client` object to a map for serialization (e.g., saving to Firebase).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'matriculeFiscal': matriculeFiscal,
      'address': address,
      'contactNumber': contactNumber,
      'deliveriesCount': deliveriesCount,
    };
  }

  /// Update an existing `Client` object with new data while preserving unchanged fields.
  Client copyWith({
    String? name,
    String? matriculeFiscal,
    String? address,
    String? contactNumber,
    int? deliveriesCount,
  }) {
    return Client(
      id: this.id,
      name: name ?? this.name,
      matriculeFiscal: matriculeFiscal ?? this.matriculeFiscal,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      deliveriesCount: deliveriesCount ?? this.deliveriesCount,
    );
  }
}
