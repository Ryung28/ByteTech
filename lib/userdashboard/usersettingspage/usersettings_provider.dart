import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsProvider extends ChangeNotifier {
  bool isLoading = false;
  String username = '';
  String email = '';
  String profilePictureUrl = '';

  // Theme colors
  final deepBlue = const Color(0xFF1A237E);
  final surfaceBlue = const Color.fromARGB(255, 25, 135, 231);
  final lightBlue = const Color.fromARGB(255, 118, 193, 255);
  final accentBlue = const Color(0xFF0277BD);
  final whiteWater = const Color(0xFFE3F2FD);

  Future<void> updateProfilePicture(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) {
        throw Exception('Invalid image URL');
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profilePicture': imageUrl});
        
        profilePictureUrl = imageUrl;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating profile picture: $e');
      throw Exception('Failed to update profile picture: $e');
    }
  }

  Future<void> loadUserData() async {
    isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        username = userData.data()?['username'] ?? 'User';
        email = user.email ?? '';
        profilePictureUrl = userData.data()?['profilePicture'] ?? '';
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Add other necessary methods for user data management
}