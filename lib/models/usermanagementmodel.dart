// User Model
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final bool isAdmin;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.isAdmin = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'isAdmin': isAdmin,
    };
  }
}

// cloudinary cloud name ;dkmnhtlew
//572972636154881
//lPAEKSpSI8PuX91tVPg1HvHuICk