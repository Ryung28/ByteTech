import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardFirestore {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final DashboardFirestore _instance = DashboardFirestore._internal();

  factory DashboardFirestore() {
    return _instance;
  }

  DashboardFirestore._internal();

  Future<String> getUserName() async {
    try {
      User? user = _auth.currentUser;
      print('Current User ID: ${user?.uid}');

      if (user != null) {
        DocumentSnapshot userData = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        print('Document exists: ${userData.exists}');
        
        if (userData.exists) {
          final data = userData.data() as Map<String, dynamic>;
          print('Document data: $data');
          
          final username = data['username'] ?? 
                         data['userName'] ?? 
                         data['name'] ?? 
                         data['fullName'] ?? 
                         'User';
          
          print('Found username: $username');
          return username;
        } else {
          print('Document does not exist for user: ${user.uid}');
        }
      } else {
        print('No user is currently logged in');
      }
      return 'User';
    } catch (e) {
      print('Error in getUserName: $e');
      return 'User';
    }
  }

  bool isUserLoggedIn() {
    final user = _auth.currentUser;
    print('Is user logged in: ${user != null}');
    return user != null;
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = _auth.currentUser;
      print('Getting user data for ID: ${user?.uid}');
      
      if (user != null) {
        DocumentSnapshot userData = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        print('Full user data: ${userData.data()}');
        
        if (userData.exists) {
          return userData.data() as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Error loading user data: $e');
      return null;
    }
  }
}