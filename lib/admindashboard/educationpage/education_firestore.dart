import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EducationFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'ocean_education';

  // Get content for a specific category
  Stream<QuerySnapshot> getEducationContent(String category) {
    return _firestore
        .collection(collectionName)
        .where('category', isEqualTo: category)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Helper method to sort documents by timestamp
  List<QueryDocumentSnapshot> sortDocumentsByTimestamp(List<QueryDocumentSnapshot> docs) {
    return List.from(docs)..sort((a, b) {
      final aTimestamp = a.get('timestamp') as Timestamp?;
      final bTimestamp = b.get('timestamp') as Timestamp?;
      if (aTimestamp == null || bTimestamp == null) return 0;
      return bTimestamp.compareTo(aTimestamp); // Descending order
    });
  }

  // Add new content
  Future<String> addContent({
    required String category,
    required String title,
    required String content,
  }) async {
    try {
      return 'Content added successfully';
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        return 'Error: Only administrators can add educational content. Please contact an administrator if you need access.';
      }
      return 'Error adding content: ${e.toString()}';
    }
  }

  // Update existing content
  Future<String> updateContent({
    required String docId,
    required String title,
    required String content,
  }) async {
    try {
      await _firestore.collection(collectionName).doc(docId).update({
        'title': title,
        'content': content,
        'lastModified': FieldValue.serverTimestamp(),
        'lastModifiedBy': FirebaseAuth.instance.currentUser?.uid,
      });
      return 'Content updated successfully';
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        return 'Error: Only administrators can update educational content. Please contact an administrator if you need access.';
      }
      return 'Error updating content: ${e.toString()}';
    }
  }

  // Delete content
  Future<String> deleteContent(String docId) async {
    try {
      await _firestore.collection(collectionName).doc(docId).delete();
      return 'Content deleted successfully';
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        return 'Error: Only administrators can delete educational content. Please contact an administrator if you need access.';
      }
      return 'Error deleting content: ${e.toString()}';
    }
  }

  // Get single content document
  Future<DocumentSnapshot> getContentById(String docId) async {
    try {
      return await _firestore.collection(collectionName).doc(docId).get();
    } catch (e) {
      if (e.toString().contains('permission-denied')) {
        throw Exception('Error: You do not have permission to access this content. Please make sure you are logged in as an admin.');
      }
      throw Exception('Error getting content: ${e.toString()}');
    }
  }
}
