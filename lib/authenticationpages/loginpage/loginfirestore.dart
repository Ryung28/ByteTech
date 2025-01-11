import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileapplication/authenticationpages/registerpage/email_verification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EmailVerificationService _verificationService = EmailVerificationService();

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting to sign in user: $email');
      // First, find the user document by email
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      print('Firestore query completed. Found ${userQuery.docs.length} documents');

      if (userQuery.docs.isEmpty) {
        print('No user document found for email: $email');
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found with this email',
        );
      }

      print('Attempting Firebase Auth sign in');
      // Attempt sign in
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Firebase Auth sign in successful');

      // Get the user document
      final userDoc = userQuery.docs.first;
      final userData = userDoc.data();

      // Check if email is verified using the verification field in the user document
      final verification = userData['verification'] as Map<String, dynamic>?;
      final isVerified = verification?['verified'] ?? false;
      
      if (!isVerified) {
        await _auth.signOut();
        throw Exception('Please verify your email before logging in.');
      }

      // Update the firebaseUID if it's different
      if (userData['firebaseUID'] != userCredential.user!.uid) {
        await _firestore.collection('users').doc(userDoc.id).update({
          'firebaseUID': userCredential.user!.uid,
        });
      }

      return userCredential;
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            throw Exception('No user found with this email');
          case 'wrong-password':
            throw Exception('Invalid password');
          case 'invalid-email':
            throw Exception('Invalid email format');
          case 'network-request-failed':
            throw Exception('Network error. Please check your connection.');
          case 'too-many-requests':
            throw Exception('Too many login attempts. Please try again later.');
          default:
            throw Exception('Authentication failed: ${e.message}');
        }
      }
      throw Exception(e.toString());
    }
  }

  Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      // First try to find user by Firebase UID
      var userQuery = await _firestore
          .collection('users')
          .where('firebaseUID', isEqualTo: uid)
          .get();

      if (userQuery.docs.isEmpty) {
        // If not found, try to find by current user's email
        final currentUser = _auth.currentUser;
        if (currentUser?.email != null) {
          userQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: currentUser!.email)
              .get();
          
          if (userQuery.docs.isEmpty) {
            throw 'User data not found';
          }
        } else {
          throw 'User data not found';
        }
      }

      return userQuery.docs.first;
    } catch (e) {
      if (e is TimeoutException) {
        throw 'Connection timeout. Please check your internet connection.';
      }
      throw 'Failed to fetch user data: ${e.toString()}';
    }
  }

  Exception _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found with this email');
        case 'wrong-password':
          return Exception('Invalid password');
        case 'invalid-email':
          return Exception('Invalid email format');
        case 'network-request-failed':
          return Exception('Network error. Please check your connection.');
        default:
          return Exception('Authentication failed: ${e.message}');
      }
    }
    return Exception(e.toString());
  }
}