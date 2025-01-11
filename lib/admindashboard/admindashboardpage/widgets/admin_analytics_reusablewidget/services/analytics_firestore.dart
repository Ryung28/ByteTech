import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/analytic_model.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/chart_state.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore;
  List<AnalyticsData>? _cachedData;
  DateTime? _lastFetch;
  static const _cacheValidDuration = Duration(minutes: 5);
  bool _initialized = false;

  AnalyticsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> initializeAnalytics() async {
    if (_initialized) return;
    print('Initializing AnalyticsService');
    await fetchAnalyticsData();
    _initialized = true;
  }

  Stream<List<AnalyticsData>> getAnalyticsStream() {
    return _firestore
        .collection('users')
        .snapshots()
        .asyncMap((_) => _getAnalyticsWithCache());
  }

  Future<List<AnalyticsData>> _getAnalyticsWithCache() async {
    if (_cachedData != null && _lastFetch != null) {
      final now = DateTime.now();
      if (now.difference(_lastFetch!) < _cacheValidDuration) {
        return _cachedData!;
      }
    }

    final data = await fetchAnalyticsData();
    _cachedData = data;
    _lastFetch = DateTime.now();
    return data;
  }

  Future<Map<String, int>> getUserCounts() async {
    print('Getting user counts...');
    final usersSnapshot = await _firestore.collection('users').get();

    int googleUsers = 0;
    int regularUsers = 0;

    for (var doc in usersSnapshot.docs) {
      final data = doc.data();
      // Check multiple fields that might indicate Google auth
      final isGoogleUser = data['isGoogleUser'] == true ||
          data['provider'] == 'google' ||
          (data['email'] as String?)?.endsWith('@gmail.com') == true;

      if (isGoogleUser) {
        googleUsers++;
      } else {
        regularUsers++;
      }
    }

    print('Found $googleUsers Google users and $regularUsers regular users');
    return {
      'googleUsers': googleUsers,
      'regularUsers': regularUsers,
    };
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      try {
        // Handle string format like "December 7, 2024 at 6:07:23 PM UTC+8"
        final dateStr = value.split(' at ')[0];
        final timeStr = value.split(' at ')[1].split(' UTC')[0];
        final dateTimeStr = '$dateStr $timeStr';
        return DateTime.parse(dateTimeStr);
      } catch (e) {
        print('Error parsing date string: $value');
        print('Error details: $e');
        return null;
      }
    }
    return null;
  }

  Future<List<AnalyticsData>> fetchAnalyticsData() async {
    try {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      print('Fetching analytics data from $thirtyDaysAgo to $now');

      // Get all user documents
      final usersSnapshot = await _firestore.collection('users').get();
      final reportsSnapshot = await _firestore.collection('reports').get();
      final bansSnapshot = await _firestore
          .collection('bans')
          .where('active', isEqualTo: true)
          .get();

      // Process user documents to track growth over time
      final userGrowthMap = <DateTime, Map<String, int>>{};

      // Initialize the map with zero counts for each day
      for (var i = 0; i <= 30; i++) {
        final date = startOfToday.subtract(Duration(days: i));
        userGrowthMap[date] = {'google': 0, 'regular': 0};
      }

      // Process each user document
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'] as Timestamp?;

        if (createdAt != null) {
          final creationDate = DateTime(
            createdAt.toDate().year,
            createdAt.toDate().month,
            createdAt.toDate().day,
          );

          // Only count users created within the last 30 days
          if (creationDate.isAfter(thirtyDaysAgo)) {
            final isGoogleUser = data['provider'] == 'google';

            // Add to all dates from creation date to today
            for (var date in userGrowthMap.keys) {
              if (!date.isBefore(creationDate)) {
                if (isGoogleUser) {
                  userGrowthMap[date]!['google'] =
                      (userGrowthMap[date]!['google'] ?? 0) + 1;
                } else {
                  userGrowthMap[date]!['regular'] =
                      (userGrowthMap[date]!['regular'] ?? 0) + 1;
                }
              }
            }
          }
        }
      }

      // Convert the map to sorted list of data points
      final dataPoints = userGrowthMap.entries.map((entry) {
        final date = entry.key;
        final counts = entry.value;
        final googleUsers = counts['google'] ?? 0;
        final regularUsers = counts['regular'] ?? 0;

        return AnalyticsData(
          date: date,
          userCount: googleUsers + regularUsers,
          reportCount: reportsSnapshot.size,
          activeBanCount: bansSnapshot.size,
          regularUserCount: regularUsers,
          googleUserCount: googleUsers,
        );
      }).toList();

      // Sort by date
      dataPoints.sort((a, b) => a.date.compareTo(b.date));

      print('Generated ${dataPoints.length} data points');
      return dataPoints;
    } catch (e) {
      print('Error fetching analytics data: $e');
      return [];
    }
  }

  Future<void> initializeAnalyticsOld() async {
    try {
      final analyticsRef =
          FirebaseFirestore.instance.collection('analytics').doc('default');
      final snapshot = await analyticsRef.get();

      if (!snapshot.exists) {
        await analyticsRef.set({
          'lastUpdated': FieldValue.serverTimestamp(),
          'totalComplaints': 0,
          'resolvedComplaints': 0,
          // Add other default analytics fields as needed
        });
        print('Analytics initialized successfully');
      }
    } catch (e) {
      print('Error initializing analytics service: $e');
      if (e is FirebaseException) {
        print('Firebase Error Code: ${e.code}');
        print('Firebase Error Message: ${e.message}');
      }
    }
  }

  Future<List<AnalyticsData>> fetchAnalyticsDataForPeriod(
      TimeRange range) async {
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

      // Get all users collection
      final usersCollection = _firestore.collection('users');
      final usersSnapshot = await usersCollection.get();

      // Count total users (this includes all documents in the users collection)
      final totalUsers = usersSnapshot.docs.length;

      // Get users with timestamps for growth tracking
      final usersWithTimestamps = usersSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['createdAt'] != null;
      }).toList();

      // Sort users by creation time
      usersWithTimestamps.sort((a, b) {
        final aTime = (a.data()['createdAt'] as Timestamp).toDate();
        final bTime = (b.data()['createdAt'] as Timestamp).toDate();
        return aTime.compareTo(bTime);
      });

      // Create growth data points
      List<MapEntry<DateTime, int>> userGrowth = [];
      int cumulativeUsers = 0;

      // Add users with timestamps to growth data
      for (var doc in usersWithTimestamps) {
        final timestamp = doc.data()['createdAt'] as Timestamp;
        cumulativeUsers++;
        userGrowth.add(MapEntry(timestamp.toDate(), cumulativeUsers));
      }

      // Get other analytics data
      final reportsSnapshot = await _firestore.collection('reports').get();
      final bansSnapshot = await _firestore
          .collection('bans')
          .where('active', isEqualTo: true)
          .get();

      // Generate data points
      List<AnalyticsData> dataPoints = [];
      if (userGrowth.isNotEmpty) {
        DateTime currentTime = startDate;
        Duration interval;

        // Set appropriate intervals based on time range
        switch (range) {
          case TimeRange.today:
            interval = const Duration(hours: 1);
            break;
          case TimeRange.week:
            interval = const Duration(days: 1);
            break;
          case TimeRange.month:
            interval = const Duration(days: 2);
            break;
        }

        // Generate points at regular intervals
        while (currentTime.isBefore(now)) {
          final usersAtThisPoint = userGrowth
              .where((entry) => entry.key.isBefore(currentTime))
              .fold(0, (prev, entry) => entry.value);

          dataPoints.add(AnalyticsData(
            date: currentTime,
            userCount: usersAtThisPoint,
            reportCount: reportsSnapshot.size,
            activeBanCount: bansSnapshot.size,
          ));

          currentTime = currentTime.add(interval);
        }

        // Add the final point with total users
        dataPoints.add(AnalyticsData(
          date: now,
          userCount: totalUsers, // Use total users count for the final point
          reportCount: reportsSnapshot.size,
          activeBanCount: bansSnapshot.size,
        ));
      } else {
        // If no growth data, show flat line with total users
        dataPoints.add(AnalyticsData(
          date: startDate,
          userCount: totalUsers,
          reportCount: reportsSnapshot.size,
          activeBanCount: bansSnapshot.size,
        ));
        dataPoints.add(AnalyticsData(
          date: now,
          userCount: totalUsers,
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

  Future<Map<String, List<DocumentSnapshot>>>
      getUsersByRegistrationType() async {
    try {
      final usersCollection = _firestore.collection('users');
      print('Fetching users from Firestore...');
      final usersSnapshot = await usersCollection.get();
      print('Total users found: ${usersSnapshot.docs.length}');

      // Separate users by registration type
      final regularUsers = <DocumentSnapshot>[];
      final googleUsers = <DocumentSnapshot>[];

      for (var doc in usersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('Processing user document: ${doc.id}');
        print('Document data: $data');

        // Check multiple possible fields for Google authentication
        bool isGoogleUser = false;

        if (data['provider'] == 'google') {
          isGoogleUser = true;
        } else if (data['providerData'] != null) {
          // Check provider data array if it exists
          final providerData = data['providerData'] as List?;
          if (providerData != null && providerData.isNotEmpty) {
            isGoogleUser = providerData.any((provider) =>
                provider['providerId'] == 'google.com' ||
                provider['providerId'] == 'google');
          }
        } else if (data['email']?.toString().endsWith('@gmail.com') == true &&
            data['photoURL']?.toString().contains('googleusercontent.com') ==
                true) {
          // Fallback check for Google-specific email and photo URL
          isGoogleUser = true;
        }

        if (isGoogleUser) {
          print('Found Google user: ${data['email']}');
          googleUsers.add(doc);
        } else {
          print('Found regular user: ${data['email']}');
          regularUsers.add(doc);
        }
      }

      print(
          'Found ${googleUsers.length} Google users and ${regularUsers.length} regular users');

      // Print details of Google users for debugging
      for (var doc in googleUsers) {
        final data = doc.data() as Map<String, dynamic>;
        print('Google User Details:');
        print('- Email: ${data['email']}');
        print('- Name: ${data['displayName']}');
        print('- PhotoURL: ${data['photoURL']}');
        print('- Provider: ${data['provider']}');
        print('- ProviderData: ${data['providerData']}');
      }

      return {
        'regularUsers': regularUsers,
        'googleUsers': googleUsers,
      };
    } catch (e, stackTrace) {
      print('Error fetching users by registration type: $e');
      print('Stack trace: $stackTrace');
      return {
        'regularUsers': [],
        'googleUsers': [],
      };
    }
  }

  Future<Map<String, int>> getUserCountsOld() async {
    try {
      final usersByType = await getUsersByRegistrationType();
      return {
        'regularUsers': usersByType['regularUsers']?.length ?? 0,
        'googleUsers': usersByType['googleUsers']?.length ?? 0,
        'totalUsers': (usersByType['regularUsers']?.length ?? 0) +
            (usersByType['googleUsers']?.length ?? 0),
      };
    } catch (e) {
      print('Error getting user counts: $e');
      return {
        'regularUsers': 0,
        'googleUsers': 0,
        'totalUsers': 0,
      };
    }
  }

  List<AnalyticsData> _generateDataPoints(
    List<MapEntry<DateTime, int>> userGrowth,
    DateTime now,
    DateTime startOfToday,
    int reportsCount,
    int bansCount,
    int regularUserCount,
    int googleUserCount,
  ) {
    if (userGrowth.isEmpty) return [];

    final timeInterval = const Duration(minutes: 30);
    final dataPoints = <AnalyticsData>[];
    var currentTime = userGrowth.first.key;
    var currentIndex = 0;

    while (currentTime.isBefore(now)) {
      while (currentIndex < userGrowth.length &&
          userGrowth[currentIndex].key.isBefore(currentTime)) {
        currentIndex++;
      }

      dataPoints.add(AnalyticsData(
        date: currentTime,
        userCount: currentIndex > 0 ? userGrowth[currentIndex - 1].value : 0,
        reportCount: reportsCount,
        activeBanCount: bansCount,
        regularUserCount: regularUserCount,
        googleUserCount: googleUserCount,
      ));

      currentTime = currentTime.add(timeInterval);
    }

    return dataPoints;
  }

  List<MapEntry<DateTime, int>> _processUserGrowth(QuerySnapshot snapshot) {
    final growth = <MapEntry<DateTime, int>>[];
    var cumulativeUsers = 0;

    // Sort documents by timestamp (createdAt, lastLogin, or lastUpdated)
    final sortedDocs = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['createdAt'] != null ||
          data['lastLogin'] != null ||
          data['lastUpdated'] != null;
    }).toList()
      ..sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;

        final aTimestamp = aData['createdAt'] as Timestamp? ??
            aData['lastLogin'] as Timestamp? ??
            aData['lastUpdated'] as Timestamp;

        final bTimestamp = bData['createdAt'] as Timestamp? ??
            bData['lastLogin'] as Timestamp? ??
            bData['lastUpdated'] as Timestamp;

        return aTimestamp.compareTo(bTimestamp);
      });

    print('Found ${sortedDocs.length} documents with timestamps');

    // Process each document
    for (var doc in sortedDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['createdAt'] as Timestamp? ??
          data['lastLogin'] as Timestamp? ??
          data['lastUpdated'] as Timestamp;

      cumulativeUsers++;
      final date = timestamp.toDate();
      print('Adding growth point: $date with $cumulativeUsers users');
      growth.add(MapEntry(date, cumulativeUsers));
    }

    // Add the total count for users without any timestamp
    final totalUsers = snapshot.docs.length;
    if (growth.isEmpty && totalUsers > 0) {
      final now = DateTime.now();
      print(
          'No timestamps found, adding single point at $now with $totalUsers users');
      growth.add(MapEntry(now, totalUsers));
    } else if (growth.isNotEmpty && totalUsers > growth.last.value) {
      final now = DateTime.now();
      print('Adding final point at $now with $totalUsers total users');
      growth.add(MapEntry(now, totalUsers));
    }

    return growth;
  }
}
