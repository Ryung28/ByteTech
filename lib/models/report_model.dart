import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String username;
  final String fullName;
  final String address;
  final String complaint;
  final List<String> attachments;
  final String status;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.username,
    required this.fullName,
    required this.address,
    required this.complaint,
    required this.attachments,
    required this.status,
    required this.createdAt,
  });

  factory Report.fromMap(Map<String, dynamic> data, String id) {
    return Report(
      id: id,
      username: data['username'] ?? '',
      fullName: data['fullName'] ?? '',
      address: data['address'] ?? '',
      complaint: data['complaint'] ?? '',
      attachments: List<String>.from(data['attachments'] ?? []),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'fullName': fullName,
      'address': address,
      'complaint': complaint,
      'attachments': attachments,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}