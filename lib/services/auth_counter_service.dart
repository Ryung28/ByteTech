import 'package:cloud_firestore/cloud_firestore.dart';

class AuthCounterService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _counterCollection = 'auth_counters';
  static const String _googleLoginDoc = 'google_logins';

  /// Increments the Google login counter for a specific user
  static Future<void> incrementGoogleLoginCount(String userId) async {
    if (userId.isEmpty) {
      print('Error: userId is empty');
      return;
    }

    try {
      // Get the user's counter document reference
      final userCounterRef = _firestore
          .collection(_counterCollection)
          .doc(_googleLoginDoc)
          .collection('users')
          .doc(userId);

      // Update user's personal counter
      await userCounterRef.set({
        'count': FieldValue.increment(1),
        'lastLogin': FieldValue.serverTimestamp(),
        'firstLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Get the global counter document reference
      final globalCounterRef = _firestore
          .collection(_counterCollection)
          .doc(_googleLoginDoc);

      // Update global counter
      await globalCounterRef.set({
        'totalLogins': FieldValue.increment(1),
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Successfully updated login counters for user: $userId');
    } catch (e, stackTrace) {
      print('Error incrementing Google login count: $e');
      print('Stack trace: $stackTrace');
      // Don't rethrow the error - just log it
    }
  }

  /// Get the login count for a specific user
  static Future<Map<String, dynamic>> getUserLoginStats(String userId) async {
    try {
      if (userId.isEmpty) {
        return {
          'count': 0,
          'firstLogin': null,
          'lastLogin': null,
        };
      }

      final doc = await _firestore
          .collection(_counterCollection)
          .doc(_googleLoginDoc)
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) {
        return {
          'count': 0,
          'firstLogin': null,
          'lastLogin': null,
        };
      }

      return doc.data() ?? {
        'count': 0,
        'firstLogin': null,
        'lastLogin': null,
      };
    } catch (e) {
      print('Error getting user login stats: $e');
      return {
        'count': 0,
        'firstLogin': null,
        'lastLogin': null,
      };
    }
  }

  /// Get global Google login statistics
  static Future<Map<String, dynamic>> getGlobalLoginStats() async {
    try {
      final doc = await _firestore
          .collection(_counterCollection)
          .doc(_googleLoginDoc)
          .get();

      if (!doc.exists) {
        return {
          'totalLogins': 0,
          'uniqueUsers': 0,
          'lastLogin': null,
        };
      }

      return doc.data() ?? {
        'totalLogins': 0,
        'uniqueUsers': 0,
        'lastLogin': null,
      };
    } catch (e) {
      print('Error getting global login stats: $e');
      return {
        'totalLogins': 0,
        'uniqueUsers': 0,
        'lastLogin': null,
      };
    }
  }
}
