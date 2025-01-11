import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboardFirestore {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final AdminDashboardFirestore _instance = AdminDashboardFirestore._internal();

  factory AdminDashboardFirestore() {
    return _instance;
  }

  AdminDashboardFirestore._internal();

  Future<Map<String, dynamic>> getAdminData() async {
    try {
      User? user = _auth.currentUser;
      print('Getting admin data for ID: ${user?.uid}');
      
      if (user != null) {
        // First try to find user by Firebase UID
        var userQuery = await _firestore
            .collection('users')
            .where('firebaseUID', isEqualTo: user.uid)
            .get();

        if (userQuery.docs.isEmpty) {
          // Try to find by email
          userQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: user.email)
              .get();
        }

        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data();
          print('Found admin data: $userData');
          
          return {
            'name': _getDisplayName(userData),
            'photoURL': userData['photoURL'] ?? user.photoURL,
            'lastLogin': userData['lastLogin'] ?? DateTime.now().toString(),
            'isAdmin': userData['isAdmin'] ?? false,
          };
        }
      }
      
      // Return default data if nothing found
      return {
        'name': 'Admin',
        'photoURL': null,
        'lastLogin': DateTime.now().toString(),
        'isAdmin': true,
      };
    } catch (e) {
      print('Error getting admin data: $e');
      return {
        'name': 'Admin',
        'photoURL': null,
        'lastLogin': DateTime.now().toString(),
        'isAdmin': true,
      };
    }
  }

  String _getDisplayName(Map<String, dynamic> userData) {
    // Try firstName + lastName first
    final firstName = userData['firstName']?.toString() ?? '';
    final lastName = userData['lastName']?.toString() ?? '';
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    
    // Try displayName
    if (userData['displayName'] != null) {
      return userData['displayName'].toString();
    }
    
    // Try username
    if (userData['username'] != null) {
      return userData['username'].toString();
    }
    
    // Default fallback
    return 'Admin';
  }

  Future<void> updateAdminOnlineStatus(bool isOnline) async {
    try {
      // Update the admin's online status in Firestore
      await _firestore
          .collection('admins')
          .doc('current_admin') // Use the actual admin document ID
          .update({'isOnline': isOnline});
    } catch (e) {
      throw Exception('Failed to update online status: $e');
    }
  }
}
