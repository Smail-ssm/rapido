// lib/utils/utils.dart
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
 static Future<String?> getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userID');
  }

  static Future<String> generateLocalBillId() async {
    final prefs = await SharedPreferences.getInstance();

    // Get the current counter value; default to 1000 if not set
    int currentId = prefs.getInt('billCounter') ?? 0;

    // Increment the counter
    currentId += 1;

    // Save the new value back to SharedPreferences
    await prefs.setInt('billCounter', currentId);

    // Return the new `billId` as a string
    return currentId.toString();
  }
}
