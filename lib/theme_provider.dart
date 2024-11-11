import 'package:flutter/material.dart';

enum ThemeModeOption { system, light, dark }

class ThemeProvider with ChangeNotifier {
  ThemeModeOption _themeMode = ThemeModeOption.system;

  ThemeModeOption get themeMode => _themeMode;

  void setThemeMode(ThemeModeOption mode) {
    _themeMode = mode;
    notifyListeners();
  }

  ThemeMode get effectiveThemeMode {
    switch (_themeMode) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
