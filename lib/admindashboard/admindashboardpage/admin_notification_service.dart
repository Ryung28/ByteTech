import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _notifications = _firestore.collection('admin_notifications');

  static Future<void> createNotification({
    required String title,
    required String message,
    required String type,
    required String referenceId,
    bool isRead = false,
  }) async {
    try {
      await _notifications.add({
        'title': title,
        'message': message,
        'type': type,
        'referenceId': referenceId,
        'isRead': isRead,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  static Stream<QuerySnapshot> getNotifications() {
    return _notifications
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> markAsRead(String notificationId) async {
    try {
      await _notifications.doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  static Future<int> getUnreadCount() async {
    try {
      final querySnapshot = await _notifications
          .where('isRead', isEqualTo: false)
          .get();
      return querySnapshot.size;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }
}
