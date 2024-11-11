// lib/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final String name;
  final String phoneNumber;
  final String address;
  final String profilePictureUrl; // URL to store profile picture if needed

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.address,
    this.profilePictureUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      profilePictureUrl: map['profilePictureUrl'] ?? '',
    );
  }
}
