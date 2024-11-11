import 'package:Rappido/screens/ProductListPage.dart';
import 'package:Rappido/screens/SettingsPage.dart';
import 'package:Rappido/theme/dark_theme.dart';
import 'package:Rappido/theme/light_theme.dart';
import 'package:Rappido/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Rappido/screens/ClientsPage.dart';
import 'package:Rappido/screens/HomePage.dart';
import 'package:Rappido/screens/RegisterPage.dart';
import 'service/AuthenticationService.dart';
import 'AuthenticationWrapper.dart';
import 'firebase_options.dart';
import 'screens/login_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that Flutter bindings are initialized
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
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(), // Add ThemeProvider for theme management
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Rapido',
            theme: lightTheme,         // Apply custom light theme
            darkTheme: darkTheme,       // Apply custom dark theme
            themeMode: themeProvider.effectiveThemeMode, // Manage theme mode dynamically
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthenticationWrapper(),
              '/clients': (context) => const ClientsPage(),
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/settings': (context) => const SettingsPage(),
              '/home': (context) => const HomePage(),
              '/stock': (context) => const ProductListPage(),
            },
          );
        },
      ),
    );
  }
}
