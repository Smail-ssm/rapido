import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapido/screens/HomePage.dart';
import 'package:rapido/screens/RegisterPage.dart';
import 'AuthenticationService.dart';
import 'AuthenticationWrapper.dart';
import 'firebase_options.dart';
 import 'screens/login_page.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RapidoApp());
}

class RapidoApp extends StatelessWidget {
  const RapidoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(),
        ),
        StreamProvider(
          create: (context) => context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Rapido',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthenticationWrapper(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}
