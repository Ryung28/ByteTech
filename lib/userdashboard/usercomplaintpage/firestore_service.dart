import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/admin_notification_service.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _complaints = _firestore.collection('complaints');
  static final CollectionReference _counters = _firestore.collection('counters');
  static final CollectionReference _userNotifications = _firestore.collection('user_notifications');

  // counter for firestore
  static Future<int> _getNextComplaintNumber() async {
    final DocumentReference counterDoc = _counters.doc('complaints');
    
    try {
      return await _firestore.runTransaction<int>((transaction) async {
        final snapshot = await transaction.get(counterDoc);
        
        final int currentCount = snapshot.exists ? (snapshot.data() as Map<String, dynamic>)['count'] ?? 0 : 0;
        final int nextCount = currentCount + 1;
        
        transaction.set(counterDoc, {
          'count': nextCount,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        return nextCount;
      });
    } catch (e) {
      throw Exception('Failed to generate complaint number: $e');
    }
  }

  // Create a new complaint/report with organized ID
  static Future<String> createComplaint({
    required String name,
    required DateTime dateOfBirth,
    required String phone,
    required String email,
    required String address,
    required String complaint,
    required List<String> attachedFiles,
    Map<String, double>? location,
  }) async {
    try {
    
      final int complaintNumber = await _getNextComplaintNumber();
      final String documentId = 'report#$complaintNumber';

      await _complaints.doc(documentId).set({
        'reportId': documentId,
        'name': name,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'email': email,
        'phone': phone,
        'address': address,
        'complaint': complaint,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
        'attachedFiles': attachedFiles,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'complaintNumber': complaintNumber,
        'location': location,
      });

      // Create notification for admin
      await AdminNotificationService.createNotification(
        title: 'New Complaint Submitted',
        message: 'A new complaint has been submitted by $name',
        type: 'complaint',
        referenceId: documentId,
      );
      
      return documentId;
    } catch (e) {
      throw Exception('Failed to create complaint: $e');
    }
  }

  // Initialize counter if it doesn't exist
  static Future<void> initializeCounter() async {
    try {
      final DocumentReference counterDoc = _counters.doc('complaints');
      
      final snapshot = await counterDoc.get();
      
      if (!snapshot.exists) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();
              
          if (userDoc.exists && (userDoc.data()?['isAdmin'] == true)) {
            await counterDoc.set({
              'count': 0,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          }
        }
      }
    } catch (e) {
      print('Error initializing counter: $e');
      // Add more detailed error logging
      if (e is FirebaseException) {
        print('Firebase Error Code: ${e.code}');
        print('Firebase Error Message: ${e.message}');
      }
    }
  }

  // Get all reports (for admin) with ordered IDs
  static Stream<QuerySnapshot> getComplaints() {
    return _complaints
        .orderBy('complaintNumber', descending: true)
        .snapshots();
  }

  // Get reports for a specific user with ordered IDs
  static Stream<QuerySnapshot> getUserComplaints(String email) {
    return _complaints
        .where('email', isEqualTo: email)
        .orderBy('complaintNumber', descending: true)
        .snapshots();
  }

  // Update complaint status
  static Future<void> updateComplaintStatus(String complaintId, String newStatus) async {
    try {
      // Get the complaint data first
      final complaintDoc = await _complaints.doc(complaintId).get();
      final complaintData = complaintDoc.data() as Map<String, dynamic>;
      final userId = complaintData['userId'];
      final userName = complaintData['name'];

      // Update the complaint status
      await _complaints.doc(complaintId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create notification for the user
      await _userNotifications.add({
        'userId': userId,
        'title': 'Complaint Status Updated',
        'message': 'Your complaint (ID: $complaintId) has been updated to: $newStatus',
        'type': 'status_update',
        'complaintId': complaintId,
        'status': newStatus,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create notification for admin
      await AdminNotificationService.createNotification(
        title: 'Status Updated',
        message: 'Complaint status for $userName has been updated to $newStatus',
        type: 'status_update',
        referenceId: complaintId,
      );
    } catch (e) {
      throw Exception('Failed to update complaint status: $e');
    }
  }

  // Get user notifications stream
  static Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _userNotifications
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .orderBy(FieldPath.documentId, descending: true)
        .snapshots();
  }

  // Mark user notification as read
  static Future<void> markUserNotificationAsRead(String notificationId) async {
    try {
      await _userNotifications.doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Get unread user notifications count
  static Stream<int> getUnreadUserNotificationsCount(String userId) {
    return _userNotifications
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Delete report
  static Future<void> deleteComplaint(String reportId) async {
    try {
      await _complaints.doc(reportId).delete();
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  // Get report statistics
  static Future<Map<String, dynamic>> getComplaintStatistics() async {
    try {
      final QuerySnapshot snapshot = await _complaints.get();
      final total = snapshot.size;
      
      final pendingQuery = await _complaints
          .where('status', isEqualTo: 'Pending')
          .get();
      final inProgressQuery = await _complaints
          .where('status', isEqualTo: 'In Progress')
          .get();
      final resolvedQuery = await _complaints
          .where('status', isEqualTo: 'Resolved')
          .get();

      return {
        'total': total,
        'pending': pendingQuery.size,
        'inProgress': inProgressQuery.size,
        'resolved': resolvedQuery.size,
      };
    } catch (e) {
      throw Exception('Failed to get report statistics: $e');
    }
  }
}
