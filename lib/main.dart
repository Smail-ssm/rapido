import 'package:Rappido/screens/ClientsPage.dart';
import 'package:Rappido/screens/HomePage.dart';
import 'package:Rappido/screens/SettingsPage.dart';
import 'package:Rappido/screens/ProductList.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter bindings are initialized
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
      debugShowCheckedModeBanner: false, // Removes the debug banner
      theme: _buildThemeData(), // Custom theme
      initialRoute: '/home',
      routes: _buildRoutes(),
    );
  }

  // Define the routes in a separate method for better readability and maintainability
  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/clients': (context) => const ClientsPage(),
      '/settings': (context) => const SettingsPage(),
      '/products': (context) => const StockManagementPage(),
      '/home': (context) => const HomePage(),
    };
  }

  // Define a custom theme for the app
  ThemeData _buildThemeData() {
    return ThemeData(
      primarySwatch: Colors.blue,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.grey[100],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
    );
  }
}
