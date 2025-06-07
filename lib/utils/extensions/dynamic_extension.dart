import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

extension DynamicExtension on dynamic {
  DateTime parseDateTime() {
    try {
      if (this == null) {
        return DateTime.now();
      }

      // If it's already a DateTime object
      if (this is DateTime) {
        return this;
      }

      // If it's a Firestore Timestamp
      if (this is Timestamp) {
        return (this as Timestamp).toDate();
      }

      // If it's a string, try to parse it
      if (this is String) {
        return DateTime.parse(this);
      }

      // If it's an int (milliseconds since epoch)
      if (this is int) {
        return DateTime.fromMillisecondsSinceEpoch(this);
      }

      // If it's a double (milliseconds since epoch)
      if (this is double) {
        return DateTime.fromMillisecondsSinceEpoch(this.toInt());
      }

      // Default fallback
      return DateTime.now();
    } catch (e) {
      // Log the error for debugging but don't crash the app
      debugPrint(
        'Warning: Failed to parse DateTime from value: $this, type: $runtimeType. Using current time instead.',
      );
      return DateTime.now();
    }
  }
}
