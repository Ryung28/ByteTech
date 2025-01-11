import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/analytic_model.dart';

class ReportsFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AnalyticsData>> fetchReportsAnalytics({String? timeRange}) async {
    try {
      final now = DateTime.now();
      DateTime startDate;

      // Calculate start date based on time range
      switch (timeRange) {
        case 'Day':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'Week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'Month':
          startDate = now.subtract(const Duration(days: 30));
          break;
        default:
          startDate = now.subtract(const Duration(days: 7)); // Default to week
      }

      print('=== REPORTS ANALYTICS DEBUG ===');
      print('Time Range: $timeRange');
      print('Start Date: $startDate');
      print('End Date: $now');

      // Query complaints collection
      final reportsSnapshot = await _firestore
          .collection('complaints')
          .get();

      print('Retrieved ${reportsSnapshot.docs.length} reports');

      // Process reports data
      final reportsByDate = <DateTime, int>{};
      
      // Initialize all dates in range with 0
      if (timeRange == 'Day') {
        // For Day view, initialize hours
        for (int hour = 0; hour < 24; hour++) {
          final hourDate = DateTime(startDate.year, startDate.month, startDate.day, hour);
          reportsByDate[hourDate] = 0;
        }
      } else {
        // For Week and Month views, initialize days
        for (var date = startDate;
            date.isBefore(now.add(const Duration(days: 1)));
            date = date.add(const Duration(days: 1))) {
          final normalizedDate = DateTime(date.year, date.month, date.day);
          reportsByDate[normalizedDate] = 0;
        }
      }

      // Count reports by date
      for (var doc in reportsSnapshot.docs) {
        final data = doc.data();
        DateTime? timestamp;

        // Check createdAt first since that's what we're using
        if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
          timestamp = (data['createdAt'] as Timestamp).toDate();
          print('Processing report with createdAt: $timestamp');
        }

        if (timestamp != null) {
          if (timeRange == 'Day') {
            // For Day view, check if it's today and use hours
            if (timestamp.year == startDate.year &&
                timestamp.month == startDate.month &&
                timestamp.day == startDate.day) {
              final hourDate = DateTime(
                timestamp.year,
                timestamp.month,
                timestamp.day,
                timestamp.hour,
              );
              if (reportsByDate.containsKey(hourDate)) {
                reportsByDate[hourDate] = (reportsByDate[hourDate] ?? 0) + 1;
                print('Added report for hour: ${timestamp.hour}:00');
              }
            }
          } else {
            // For Week and Month views, use days
            if (!timestamp.isBefore(startDate) && !timestamp.isAfter(now)) {
              final normalizedDate = DateTime(
                timestamp.year,
                timestamp.month,
                timestamp.day,
              );
              if (reportsByDate.containsKey(normalizedDate)) {
                reportsByDate[normalizedDate] = (reportsByDate[normalizedDate] ?? 0) + 1;
                print('Added report for date: $normalizedDate');
              }
            }
          }
        }
      }

      // Convert to analytics data (without cumulative counts)
      final analyticsData = reportsByDate.entries.map((entry) {
        return AnalyticsData(
          date: entry.key,
          reportCount: entry.value, // Use actual count, not cumulative
          userCount: 0,
          activeBanCount: 0,
          regularUserCount: 0,
          googleUserCount: 0,
        );
      }).toList();

      // Sort by date
      analyticsData.sort((a, b) => a.date.compareTo(b.date));

      print('\nFinal Report Counts:');
      analyticsData.forEach((data) {
        if (timeRange == 'Day') {
          print('Hour ${data.date.hour}:00 - ${data.reportCount} reports');
        } else {
          print('Date ${data.date.toString().split(' ')[0]} - ${data.reportCount} reports');
        }
      });

      return analyticsData;
    } catch (e, stackTrace) {
      print('Error fetching reports analytics: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, int>> getReportStatusCounts() async {
    try {
      final snapshot = await _firestore.collection('complaints').get();
      
      final statusCounts = {
        'Pending': 0,
        'In Progress': 0,
        'Resolved': 0,
        'Total': 0,
      };

      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] as String? ?? 'Pending';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        statusCounts['Total'] = (statusCounts['Total'] ?? 0) + 1;
      }

      return statusCounts;
    } catch (e) {
      print('Error getting report status counts: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getReportsStream() {
    return _firestore
        .collection('complaints')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getLatestReports({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('complaints')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error getting latest reports: $e');
      rethrow;
    }
  }
}
