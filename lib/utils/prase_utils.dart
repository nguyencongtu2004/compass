import 'package:flutter/foundation.dart';

class PraseUtils {
  static DateTime parseDateTime(dynamic value) {
    try {
      if (value == null) {
        debugPrint('DateTime value is null, using current time');
        return DateTime.now();
      }

      // If it's already a DateTime object
      if (value is DateTime) {
        return value;
      }

      // If it's a Firestore Timestamp - handle both direct call and reflection
      if (value.runtimeType.toString() == 'Timestamp' ||
          value.toString().contains('Timestamp')) {
        try {
          return (value as dynamic).toDate();
        } catch (e) {
          debugPrint('Failed to convert Timestamp to DateTime: $e');
          return DateTime.now();
        }
      }

      // If it has a toDate method (alternative Timestamp check)
      if (value.runtimeType.toString().contains('Timestamp')) {
        try {
          final method = value.runtimeType.toString();
          debugPrint('Attempting toDate() on type: $method');
          return (value as dynamic).toDate();
        } catch (e) {
          debugPrint('toDate() method failed: $e');
          return DateTime.now();
        }
      }

      // If it's a string, try to parse it
      if (value is String) {
        if (value.isEmpty) {
          debugPrint('Empty string for DateTime, using current time');
          return DateTime.now();
        }
        return DateTime.parse(value);
      }

      // If it's an int (milliseconds since epoch)
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }

      // If it's a double (seconds since epoch, convert to milliseconds)
      if (value is double) {
        return DateTime.fromMillisecondsSinceEpoch((value * 1000).round());
      }

      // Default fallback with detailed logging
      debugPrint(
        'Unhandled DateTime type: ${value.runtimeType}, value: $value',
      );
      return DateTime.now();
    } catch (e) {
      // Log the error for debugging but don't crash the app
      debugPrint(
        'Warning: Failed to parse DateTime from value: $value, type: ${value.runtimeType}, error: $e. Using current time instead.',
      );
      return DateTime.now();
    }
  }
}