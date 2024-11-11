// lib/service/authentication_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'model/UserModel.dart';


class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('users');

  AuthenticationService(this._firebaseAuth);

  // Sign-up function
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String address,
  }) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    final String userId = userCredential.user!.uid;

    // Create a new user model and save it to Firebase
    UserModel userModel = UserModel(
      id: userId,
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      address: address,
    );
    await _databaseRef.child(userId).set(userModel.toMap());
  }

  // Sign-in function
  Future<User?> signIn({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  // Sign-out function
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
