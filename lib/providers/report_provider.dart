import 'package:flutter/material.dart'; // Core Flutter framework
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore package
import '../models/report_model.dart'; // Local Report model class

class ReportProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Report> _reports = [];
  bool _isLoading = false;

  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;

  Future<void> fetchReports() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('reports').get();
      _reports = snapshot.docs
          .map((doc) => Report.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching reports: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> approveReport(String reportId) async {
    try {
      await _firestore
          .collection('reports')
          .doc(reportId)
          .update({'status': 'approved'});
      await fetchReports();
    } catch (e) {
      print('Error approving report: $e');
    }
  }

  // Future<void> rejectReport(String reportId) async {
}
