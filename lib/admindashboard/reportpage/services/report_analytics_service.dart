import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReportAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getReportsData(String timeRange) async {
    try {
      final now = DateTime.now();
      DateTime startDate;

      // Calculate the start date based on the time range
      switch (timeRange) {
        case 'Day':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'Week':
          startDate = now.subtract(const Duration(days: 6));
          break;
        case 'Month':
          startDate = now.subtract(const Duration(days: 29));
          break;
        default:
          startDate = now.subtract(const Duration(days: 6));
      }

      print('Fetching reports from $startDate to $now');

      // Query the complaints collection
      final QuerySnapshot querySnapshot = await _firestore
          .collection('complaints')
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: now)
          .get();

      // Initialize data points map
      final Map<String, int> dataPoints = {};

      // Initialize time slots based on the selected range
      if (timeRange == 'Day') {
        for (int hour = 0; hour < 24; hour++) {
          final timeKey = '$hour:00';
          dataPoints[timeKey] = 0;
        }
      } else {
        var current = startDate;
        while (current.isBefore(now.add(const Duration(days: 1)))) {
          final dateKey = DateFormat('MM/dd').format(current);
          dataPoints[dateKey] = 0;
          current = current.add(const Duration(days: 1));
        }
      }

      // Process the reports
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['createdAt'] != null) {
          final timestamp = (data['createdAt'] as Timestamp).toDate();
          
          if (timeRange == 'Day') {
            if (timestamp.year == now.year && 
                timestamp.month == now.month && 
                timestamp.day == now.day) {
              final timeKey = '${timestamp.hour}:00';
              dataPoints[timeKey] = (dataPoints[timeKey] ?? 0) + 1;
            }
          } else {
            final dateKey = DateFormat('MM/dd').format(timestamp);
            dataPoints[dateKey] = (dataPoints[dateKey] ?? 0) + 1;
          }
        }
      }

      // Convert to list format for the chart
      return dataPoints.entries.map((entry) {
        return {
          'label': entry.key,
          'value': entry.value,
        };
      }).toList();
    } catch (e) {
      print('Error fetching reports data: $e');
      rethrow;
    }
  }

  Future<int> getTotalReports() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('complaints')
          .get();
      return querySnapshot.size;
    } catch (e) {
      print('Error getting total reports: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> getReportStatusCounts() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('complaints')
          .get();

      final Map<String, int> statusCounts = {
        'Pending': 0,
        'In Progress': 0,
        'Resolved': 0,
      };

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String? ?? 'Pending';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      return statusCounts;
    } catch (e) {
      print('Error getting status counts: $e');
      rethrow;
    }
  }
}
