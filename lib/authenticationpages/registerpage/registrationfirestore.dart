import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobileapplication/authenticationpages/registerpage/email_verification_service.dart';

class Firestore {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final EmailVerificationService _verificationService = EmailVerificationService();

  Future<int> _getNextUserCounter() async {
    final counterRef = _firestore.collection('documentCounters').doc('users');
    
    try {
      return await _firestore.runTransaction<int>((transaction) async {
        final counterDoc = await transaction.get(counterRef);
        
        if (!counterDoc.exists) {
          // Initialize counter if it doesn't exist
          transaction.set(counterRef, {'count': 1});
          return 1;
        } else {
          final int currentCount = counterDoc.data()?['count'] ?? 0;
          final int nextCount = currentCount + 1;
          transaction.update(counterRef, {'count': nextCount});
          return nextCount;
        }
      });
    } catch (e) {
      debugPrint('Error getting next user counter: $e');
      throw Exception('Failed to generate user ID');
    }
  }

  Future<Map<String, dynamic>> addUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Check for existing account and clean up if necessary
      final existingMethods = await _auth.fetchSignInMethodsForEmail(email);
      if (existingMethods.isNotEmpty) {
        try {
          // Try to sign in with the provided credentials
          final existingUserCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          
          // If sign in successful, delete the existing account
          if (existingUserCredential.user != null) {
            // First delete any existing Firestore data
            var existingUsers = await _firestore
                .collection('users')
                .where('email', isEqualTo: email)
                .get();

            for (var doc in existingUsers.docs) {
              await _firestore.collection('users').doc(doc.id).delete();
            }
            
            // Then delete the Auth account
            await existingUserCredential.user!.delete();
          }
        } catch (e) {
          // If we can't sign in, the user probably used a different password
          throw Exception('An account with this email already exists. Please use a different email or try logging in.');
        }
      }

      // Ensure we're starting fresh
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }

      // Create new Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user account.');
      }

      // Get next user counter
      final userCount = await _getNextUserCounter();
      final userDocId = 'user$userCount';

      // Generate OTP
      final otp = _verificationService.generateOTP();

      // Create Firestore document
      await _firestore.collection('users').doc(userDocId).set({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'isAdmin': false,
        'firebaseUID': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'fullName': '$firstName $lastName',
        'emailVerified': false,
        'userNumber': userCount,
        'photoUrl': 'https://www.gravatar.com/avatar/${userCredential.user!.uid}?d=identicon',
        'verification': {
          'otp': otp,
          'createdAt': FieldValue.serverTimestamp(),
          'verified': false,
          'attempts': 0
        }
      });

      return {
        'user': userCredential,
        'otp': otp,
        'userDocId': userDocId,
      };
    } catch (e) {
      // Ensure cleanup on error
      try {
        if (_auth.currentUser != null) {
          // First clean up Firestore data
          var existingUsers = await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

          for (var doc in existingUsers.docs) {
            await _firestore.collection('users').doc(doc.id).delete();
          }
          
          // Then delete the Auth account
          await _auth.currentUser!.delete();
        }
      } catch (cleanupError) {
        debugPrint('Error during cleanup: $cleanupError');
      }
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            throw Exception('This email is already registered. Please use a different email.');
          case 'invalid-email':
            throw Exception('The email address is not valid.');
          case 'operation-not-allowed':
            throw Exception('Email/password accounts are not enabled. Please contact support.');
          case 'weak-password':
            throw Exception('The password is too weak. Please choose a stronger password.');
          default:
            throw Exception('Registration failed: ${e.message}');
        }
      }
      rethrow;
    }
  }
}