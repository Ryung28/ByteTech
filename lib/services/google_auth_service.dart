import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  /// Find or create user document ID
  static Future<String> _getUserDocumentId(
      User user, GoogleSignInAccount googleUser) async {
    try {
      print('Searching for existing user document...');
      print('Firebase UID: ${user.uid}');
      print('Google Email: ${googleUser.email}');

      // First try to find user by Firebase UID
      var userQuery = await _firestore
          .collection('users')
          .where('firebaseUID', isEqualTo: user.uid)
          .get();

      // If found by UID, return that document ID
      if (userQuery.docs.isNotEmpty) {
        print('Found existing user by UID: ${userQuery.docs.first.id}');
        return userQuery.docs.first.id;
      }

      // Then try to find by email
      userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: googleUser.email)
          .get();

      // If found by email, return that document ID
      if (userQuery.docs.isNotEmpty) {
        print('Found existing user by email: ${userQuery.docs.first.id}');
        return userQuery.docs.first.id;
      }

      print('No existing user found, creating new document ID');
      // If no existing user found, create new ID
      final googleUsersQuery = await _firestore
          .collection('users')
          .where('provider', isEqualTo: 'google')
          .get();

      int maxNumber = 0;
      for (var doc in googleUsersQuery.docs) {
        final match = RegExp(r'googleauth(\d+)').firstMatch(doc.id);
        if (match != null) {
          final number = int.parse(match.group(1)!);
          if (number > maxNumber) maxNumber = number;
        }
      }

      final newDocId = 'googleauth${maxNumber + 1}';
      print('Created new document ID: $newDocId');
      return newDocId;
    } catch (e) {
      print('Error getting user document ID: $e');
      final fallbackId = 'googleauth${DateTime.now().millisecondsSinceEpoch}';
      print('Using fallback document ID: $fallbackId');
      return fallbackId;
    }
  }

  /// Create or update user document
  static Future<void> _updateUserDocument({
    required String docId,
    required User user,
    required GoogleSignInAccount googleUser,
    required bool isAdmin,
  }) async {
    try {
      print('Updating user document...');
      print('Document ID: $docId');
      print('Google Display Name: ${googleUser.displayName}');

      // Handle display name parsing
      String firstName = '', lastName = '';
      if (googleUser.displayName != null &&
          googleUser.displayName!.isNotEmpty) {
        final nameParts = googleUser.displayName!.trim().split(' ');
        firstName = nameParts[0];
        lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      }

      // Create user data map
      final userData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': googleUser.email,
        'username': googleUser.email.split('@')[0],
        'isAdmin': isAdmin,
        'firebaseUID': user.uid,
        'provider': 'google',
        'photoURL': googleUser.photoUrl ?? '',
        'displayName': googleUser.displayName ?? '',
        'lastLogin': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // Check if document exists to determine if this is first login
      final docSnapshot = await _firestore.collection('users').doc(docId).get();
      if (!docSnapshot.exists) {
        // Add createdAt timestamp only on first login
        userData['createdAt'] = FieldValue.serverTimestamp();
      }

      print('Saving user data: $userData');

      // Use set with merge to update the document
      await _firestore.collection('users').doc(docId).set(
            userData,
            SetOptions(merge: true),
          );

      print('User document updated successfully');
    } catch (e) {
      print('Error updating user document: $e');
      throw 'Failed to update user profile: $e';
    }
  }

  /// Check existing admin status
  static Future<bool> _checkAdminStatus(String docId) async {
    try {
      final doc = await _firestore.collection('users').doc(docId).get();
      return doc.exists ? (doc.data()?['isAdmin'] ?? false) : false;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  /// Sign in with Google
  static Future<({User user, bool isAdmin, String docId})> signIn() async {
    try {
      print('Starting Google Sign-In process...');

      // Sign out first to ensure a fresh sign-in
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Attempt to sign in with Google
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Sign in cancelled by user');
        throw 'Sign in cancelled by user';
      }

      print('Google Sign-In successful');
      print('Email: ${googleUser.email}');
      print('Display Name: ${googleUser.displayName}');

      // Get auth credentials
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw 'Failed to sign in with Firebase';

      print('Firebase Sign-In successful');
      print('Firebase UID: ${user.uid}');

      // Get or create document ID
      final docId = await _getUserDocumentId(user, googleUser);
      print('Document ID: $docId');

      // Check admin status using document ID
      final isAdmin = await _checkAdminStatus(docId);
      print('Admin Status: $isAdmin');

      // Update user document
      await _updateUserDocument(
        docId: docId,
        user: user,
        googleUser: googleUser,
        isAdmin: isAdmin,
      );

      print('Sign-In process completed successfully');
      return (
        user: user,
        isAdmin: isAdmin,
        docId: docId,
      );
    } catch (e) {
      print('Google sign in error: $e');
      throw e.toString();
    }
  }
}
