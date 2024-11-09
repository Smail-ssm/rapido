// lib/utils/utils.dart
import 'dart:math';
import 'package:flutter/foundation.dart';

class Utils {
  /// Generates a unique ID by combining a timestamp with random numbers.
  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = Random().nextInt(999999).toString().padLeft(6, '0');
    return '$timestamp$random';
  }

  /// Returns the appropriate Firebase Realtime Database path based on the environment.
  static String getDatabasePath() {
    if (kDebugMode) {
      return 'preprod';
    } else {
      return 'prod';
    }
  }
}
