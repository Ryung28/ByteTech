import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileapplication/models/usermanagementmodel.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch all users
  Future<List<UserModel>> fetchUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  // Create new user
  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required bool isAdmin,
  }) async {
    try {
      // Create auth user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user data
      Map<String, dynamic> userData = {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'isAdmin': isAdmin,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Update existing user
  Future<void> updateUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required bool isAdmin,
    String? password,
  }) async {
    try {
      Map<String, dynamic> userData = {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'isAdmin': isAdmin,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userId).update(userData);

      if (password != null && password.isNotEmpty) {
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          await currentUser.updatePassword(password);
        }
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }
}