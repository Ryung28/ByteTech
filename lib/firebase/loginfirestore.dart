import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      print('Starting login process for email: $email');

     
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      print('Firestore query result: ${result.docs.length} documents found');

      if (result.docs.isEmpty) {
        print('No user found in Firestore');
        return null;
      }

      
      final userData = result.docs.first.data() as Map<String, dynamic>;
      userData['id'] = result.docs.first.id;

      print('Found user in Firestore: ${userData['username']}');

      
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('Firebase Auth login successful');
      } catch (firebaseError) {
        print('Firebase Auth login failed (non-critical): $firebaseError');
       
      }

      return userData;
    } catch (e) {
      print('Login failed: $e');
      return null;
    }
  }

 
  Future<bool> checkFirebaseUser(String email) async {
    try {
      var methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print('Error checking Firebase user: $e');
      return false;
    }
  }
}