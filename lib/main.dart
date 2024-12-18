import 'package:Rappido/screens/ClientsPage.dart';
import 'package:Rappido/screens/HomePage.dart';
import 'package:Rappido/screens/SettingsPage.dart';
import 'package:Rappido/screens/ProductList.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures that Flutter bindings are initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RapidoApp());
}

class RapidoApp extends StatelessWidget {
  const RapidoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rapido',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/home',
      routes: {
        '/clients': (context) => const ClientsPage(),
        '/settings': (context) => const SettingsPage(),
        '/products': (context) => const StockManagementPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
