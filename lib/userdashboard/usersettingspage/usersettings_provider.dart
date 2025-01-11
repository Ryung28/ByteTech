import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  String username = '';
  String email = '';
  String? profilePictureUrl;
  Color deepBlue = const Color(0xFF1A237E);
  Color surfaceBlue = const Color(0xFF1565C0);
  Color lightBlue = const Color(0xFF42A5F5);
  Color whiteWater = Colors.white;

  Future<void> loadUserData() async {
    try {
      isLoading = true;
      notifyListeners();

      User? user = _auth.currentUser;
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
          username = userData['displayName']?.toString() ?? '';
          email = userData['email']?.toString() ?? '';
          profilePictureUrl = userData['photoURL']?.toString();
          
          // If username is empty, try other fields
          if (username.isEmpty) {
            final firstName = userData['firstName']?.toString() ?? '';
            final lastName = userData['lastName']?.toString() ?? '';
            if (firstName.isNotEmpty || lastName.isNotEmpty) {
              username = '$firstName $lastName'.trim();
            } else {
              username = userData['username']?.toString() ?? 'User';
            }
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfilePicture(String imageUrl) async {
    try {
      User? user = _auth.currentUser;
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
          final docRef = userQuery.docs.first.reference;
          await docRef.update({
            'photoURL': imageUrl,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          
          profilePictureUrl = imageUrl;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error updating profile picture: $e');
      rethrow;
    }
  }

  Color getDeepBlue(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : deepBlue;
  }

  Color getSurfaceBlue(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.8)
        : surfaceBlue;
  }

  Color getWhiteWater(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]!
        : whiteWater;
  }
}