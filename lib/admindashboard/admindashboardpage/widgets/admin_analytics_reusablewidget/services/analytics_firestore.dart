import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/analytic_model.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore;

  AnalyticsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<AnalyticsData>> getAnalyticsStream() {
    return Stream.periodic(const Duration(seconds: 30)).asyncMap((_) => fetchAnalyticsData());
  }

  Future<List<AnalyticsData>> fetchAnalyticsData() async {
    try {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final startOfWeek = now.subtract(Duration(days: 7));
      final startOfMonth = now.subtract(Duration(days: 30));

      // Get all users with their creation timestamps
      final usersSnapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: false)
          .get();

      final reportsSnapshot = await _firestore.collection('reports').get();
      final bansSnapshot = await _firestore
          .collection('bans')
          .where('active', isEqualTo: true)
          .get();

      // Convert timestamps to DateTime and count cumulative users
      List<MapEntry<DateTime, int>> userGrowth = [];
      int cumulativeUsers = 0;

      for (var doc in usersSnapshot.docs) {
        final timestamp = (doc.data()['createdAt'] as Timestamp?)?.toDate();
        if (timestamp != null) {
          cumulativeUsers++;
          userGrowth.add(MapEntry(timestamp, cumulativeUsers));
        }
      }

      // Generate data points based on the selected time range
      List<AnalyticsData> dataPoints = [];
      if (userGrowth.isNotEmpty) {
        final timeInterval = Duration(minutes: 30); // 30-minute intervals
        DateTime currentTime = userGrowth.first.key;
        final lastTime = now;

        while (currentTime.isBefore(lastTime)) {
          final usersAtThisPoint = userGrowth
              .where((entry) => entry.key.isBefore(currentTime))
              .fold(0, (prev, entry) => entry.value);

          dataPoints.add(AnalyticsData(
            date: currentTime,
            userCount: usersAtThisPoint,
            reportCount: reportsSnapshot.size,
            activeBanCount: bansSnapshot.size,
          ));

          currentTime = currentTime.add(timeInterval);
        }

        // Add the final point
        dataPoints.add(AnalyticsData(
          date: lastTime,
          userCount: cumulativeUsers,
          reportCount: reportsSnapshot.size,
          activeBanCount: bansSnapshot.size,
        ));
      }

      // If no data points were generated (no users), create a single point
      if (dataPoints.isEmpty) {
        dataPoints.add(AnalyticsData(
          date: now,
          userCount: 0,
          reportCount: reportsSnapshot.size,
          activeBanCount: bansSnapshot.size,
        ));
      }

      return dataPoints;
    } catch (e) {
      print('Error fetching analytics data: $e');
      rethrow;
    }
  }

  Future<void> initializeAnalytics() async {
    // Perform any necessary initialization for analytics
    // For example, you might want to:
    // - Check Firestore connection
    // - Perform initial data fetch
    // - Set up any required configurations
    try {
      // Simple check to ensure Firestore is accessible
      await _firestore.collection('users').limit(1).get();
      print('Analytics service initialized successfully');
    } catch (e) {
      print('Error initializing analytics service: $e');
    }
  }

  Future<List<AnalyticsData>> fetchAnalyticsDataForPeriod(TimeRange range) async {
    try {
      final now = DateTime.now();
      DateTime startDate;

      switch (range) {
        case TimeRange.today:
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case TimeRange.week:
          startDate = now.subtract(const Duration(days: 7));
          break;
        case TimeRange.month:
          startDate = now.subtract(const Duration(days: 30));
          break;
      }

      // Get all users
      final allUsersSnapshot = await _firestore.collection('users').get();
      final totalUserCount = allUsersSnapshot.size;

      // Get users with timestamps in the selected period
      final usersWithTimestampSnapshot = await _firestore
          .collection('users')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('createdAt', descending: false)
          .get();

      final reportsSnapshot = await _firestore.collection('reports').get();
      final bansSnapshot = await _firestore
          .collection('bans')
          .where('active', isEqualTo: true)
          .get();

      // Get users with timestamps before the start date
      final previousUsersWithTimestampSnapshot = await _firestore
          .collection('users')
          .where('createdAt', isLessThan: Timestamp.fromDate(startDate))
          .get();
      
      // Calculate users without timestamps
      final usersWithoutTimestamps = totalUserCount - 
          (usersWithTimestampSnapshot.size + previousUsersWithTimestampSnapshot.size);
      
      // Base count includes users without timestamps and users from before start date
      int baseUserCount = previousUsersWithTimestampSnapshot.size + usersWithoutTimestamps;

      // Convert timestamps to DateTime and count cumulative users
      List<MapEntry<DateTime, int>> userGrowth = [];
      int cumulativeUsers = baseUserCount;

      for (var doc in usersWithTimestampSnapshot.docs) {
        final timestamp = (doc.data()['createdAt'] as Timestamp?)?.toDate();
        if (timestamp != null) {
          cumulativeUsers++;
          userGrowth.add(MapEntry(timestamp, cumulativeUsers));
        }
      }

      // Generate data points
      List<AnalyticsData> dataPoints = [];
      if (userGrowth.isNotEmpty || baseUserCount > 0) {
        DateTime currentTime = startDate;

        // Determine the interval based on the time range
        Duration interval;
        int maxPoints;
        switch (range) {
          case TimeRange.today:
            interval = const Duration(hours: 2); // Every 2 hours
            maxPoints = 12;
            break;
          case TimeRange.week:
            interval = const Duration(hours: 12); // Every 12 hours
            maxPoints = 14;
            break;
          case TimeRange.month:
            interval = const Duration(days: 2); // Every 2 days
            maxPoints = 15;
            break;
        }

        // Generate evenly spaced data points
        List<DateTime> timePoints = [];
        while (currentTime.isBefore(now)) {
          timePoints.add(currentTime);
          currentTime = currentTime.add(interval);
        }
        timePoints.add(now); // Add the current time as the last point

        // If we have more points than desired, reduce them
        if (timePoints.length > maxPoints) {
          final step = timePoints.length ~/ maxPoints;
          timePoints = [
            for (var i = 0; i < timePoints.length; i += step) 
              if (i < timePoints.length) timePoints[i]
          ];
          if (!timePoints.contains(now)) {
            timePoints.add(now);
          }
        }

        // Generate data points for each time point
        for (var time in timePoints) {
          final usersAtThisPoint = baseUserCount + userGrowth
              .where((entry) => entry.key.isBefore(time))
              .length;

          dataPoints.add(AnalyticsData(
            date: time,
            userCount: usersAtThisPoint,
            reportCount: reportsSnapshot.size,
            activeBanCount: bansSnapshot.size,
          ));
        }
      } else {
        // If no data points were generated, create points showing the total user count
        dataPoints.add(AnalyticsData(
          date: startDate,
          userCount: totalUserCount,
          reportCount: reportsSnapshot.size,
          activeBanCount: bansSnapshot.size,
        ));
        dataPoints.add(AnalyticsData(
          date: now,
          userCount: totalUserCount,
          reportCount: reportsSnapshot.size,
          activeBanCount: bansSnapshot.size,
        ));
      }

      return dataPoints;
    } catch (e) {
      print('Error fetching analytics data: $e');
      rethrow;
    }
  }
}

enum TimeRange { today, week, month }
