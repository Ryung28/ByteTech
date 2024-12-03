import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Firestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> addUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // First create the Firebase Auth user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Then create the Firestore document
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'isAdmin': false,
        'firebaseUID': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'fullName': '$firstName $lastName',
      });

      return userCredential;
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }
}