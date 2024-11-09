class Client {
  final String id;
  final String name;
  final String socialReason;
  final String address;
  final String contactNumber;
  final int deliveriesCount;

  Client({
    required this.id,
    required this.name,
    required this.socialReason,
    required this.address,
    required this.contactNumber,
    required this.deliveriesCount,
  });

  factory Client.fromMap(String id, Map<dynamic, dynamic> data) {
    return Client(
      id: id,
      name: data['name'] ?? '',
      socialReason: data['socialReason'] ?? '',
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      deliveriesCount: data['deliveriesCount'] ?? 0,
    );
  }
}