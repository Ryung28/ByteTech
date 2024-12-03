import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsData {
  final DateTime date;
  final int userCount;
  final int reportCount;
  final int activeBanCount;

  AnalyticsData({
    required this.date,
    required this.userCount,
    required this.reportCount,
    required this.activeBanCount,
  });

  factory AnalyticsData.fromFirestore(Map<String, dynamic> data) {
    return AnalyticsData(
      date: (data['date'] as Timestamp).toDate(),
      userCount: data['userCount'] ?? 0,
      reportCount: data['reportCount'] ?? 0,
      activeBanCount: data['activeBanCount'] ?? 0,
    );
  }

  AnalyticsData copyWith({
    DateTime? date,
    int? userCount,
    int? reportCount,
    int? activeBanCount,
  }) {
    return AnalyticsData(
      date: date ?? this.date,
      userCount: userCount ?? this.userCount,
      reportCount: reportCount ?? this.reportCount,
      activeBanCount: activeBanCount ?? this.activeBanCount,
    );
  }
}