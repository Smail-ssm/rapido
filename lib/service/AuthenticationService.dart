import 'package:Rappido/util/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child(Utils.getDatabasePath())
        .child('users')
        .child(Utils.getDatabasePath()).child('users');

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return "Signed in";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After the user is created, save their details to Realtime Database
      final String userId = userCredential.user!.uid;
      await _databaseRef.child(userId).set({
        'id': userId,
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber,
        'address': address,
      });

      return "Signed up";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
