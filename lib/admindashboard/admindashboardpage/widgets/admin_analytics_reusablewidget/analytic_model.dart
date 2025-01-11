import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsData {
  final DateTime date;
  final int userCount;
  final int reportCount;
  final int activeBanCount;
  final int regularUserCount;
  final int googleUserCount;

  AnalyticsData({
    required this.date,
    required this.userCount,
    required this.reportCount,
    required this.activeBanCount,
    this.regularUserCount = 0,
    this.googleUserCount = 0,
  });

  factory AnalyticsData.fromFirestore(Map<String, dynamic> data) {
    return AnalyticsData(
      date: (data['date'] as Timestamp).toDate(),
      userCount: data['userCount'] ?? 0,
      reportCount: data['reportCount'] ?? 0,
      activeBanCount: data['activeBanCount'] ?? 0,
      regularUserCount: data['regularUserCount'] ?? 0,
      googleUserCount: data['googleUserCount'] ?? 0,
    );
  }

  AnalyticsData copyWith({
    DateTime? date,
    int? userCount,
    int? reportCount,
    int? activeBanCount,
    int? regularUserCount,
    int? googleUserCount,
  }) {
    return AnalyticsData(
      date: date ?? this.date,
      userCount: userCount ?? this.userCount,
      reportCount: reportCount ?? this.reportCount,
      activeBanCount: activeBanCount ?? this.activeBanCount,
      regularUserCount: regularUserCount ?? this.regularUserCount,
      googleUserCount: googleUserCount ?? this.googleUserCount,
    );
  }
}