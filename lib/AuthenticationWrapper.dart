
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapido/screens/HomePage.dart';
 import 'screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return const HomePage(); // User is signed in
    }
    return const LoginPage(); // User is not signed in
  }
}
