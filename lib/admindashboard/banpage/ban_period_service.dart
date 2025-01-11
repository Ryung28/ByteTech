import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';

class BanPeriodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current ban period
  Stream<DocumentSnapshot> getCurrentBanPeriod() {
    return _firestore.collection('banPeriod').doc('schedule').snapshots();
  }

  // Check if user is admin
  Future<bool> _isUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No user logged in');
        return false;
      }

      print('Checking admin status for user: ${user.uid}');
      // First try to find by email
      var userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (userQuery.docs.isEmpty) {
        print('No user document found by email');
        return false;
      }

      final userDoc = userQuery.docs.first;
      print('User document data: ${userDoc.data()}');
      
      // Try to get isAdmin value, defaulting to false if not found
      final isAdmin = userDoc.get('isAdmin') ?? false;
      print('User admin status: $isAdmin');
      return isAdmin;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Update ban period
  Future<void> updateBanPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      print('Current user email: ${user.email}');
      final isAdmin = await _isUserAdmin();
      if (!isAdmin) {
        throw Exception('User does not have admin privileges');
      }

      print('Updating ban period for admin user: ${user.uid}');
      
      // Get the current ban period before updating
      final currentDoc = await _firestore.collection('banPeriod').doc('schedule').get();
      
      // Save to history first
      if (currentDoc.exists) {
        final currentData = currentDoc.data();
        if (currentData != null) {
          await _firestore.collection('banPeriodHistory').add({
            'startDate': currentData['startDate'],
            'endDate': currentData['endDate'],
            'updatedAt': currentData['updatedAt'],
            'updatedBy': currentData['updatedBy'],
            'archivedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Update current ban period
      await _firestore.collection('banPeriod').doc('schedule').set({
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': user.uid,
      });

      // Show notification
      final startFormatted = DateFormat('MMM d, yyyy').format(startDate);
      final endFormatted = DateFormat('MMM d, yyyy').format(endDate);
      
      try {
        await NotificationService.showBanPeriodNotification(
          title: '🚫 New Fishing Ban Period',
          body: '📅 A new ban period has been set:\n\n'
              '▶️ Start: $startFormatted\n'
              '▶️ End: $endFormatted\n\n'
              'Please take note of these dates. Fishing is prohibited during this period.',
        );
        print('Notification sent successfully');
      } catch (e) {
        print('Failed to show notification: $e');
        // Continue execution even if notification fails
      }

      print('Ban period updated successfully');
    } catch (e) {
      print('Error updating ban period: $e');
      rethrow;
    }
  }

  // Get ban period history
  Stream<QuerySnapshot> getBanPeriodHistory() {
    return _firestore
        .collection('banPeriodHistory')
        .orderBy('archivedAt', descending: true)
        .snapshots();
  }

  // Get formatted dates from Timestamp
  static DateTime? getDateFromTimestamp(Timestamp? timestamp) {
    return timestamp?.toDate();
  }
}
