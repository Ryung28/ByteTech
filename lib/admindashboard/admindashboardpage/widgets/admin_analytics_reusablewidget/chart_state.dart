import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/analytic_model.dart';

enum TimeRange { today, week, month }

class ChartState extends ChangeNotifier {
  TimeRange _selectedRange = TimeRange.today;
  TimeRange get selectedRange => _selectedRange;

  List<AnalyticsData> _data = [];
  List<AnalyticsData> get filteredData => _filterDataByRange();

  void updateData(List<AnalyticsData> newData) {
    _data = List.from(newData);
    notifyListeners();
  }

  void updateTimeRange(TimeRange range) {
    _selectedRange = range;
    notifyListeners();
  }

  List<AnalyticsData> _filterDataByRange() {
    if (_data.isEmpty) return [];

    final now = DateTime.now();
    DateTime cutoffDate;

    switch (_selectedRange) {
      case TimeRange.today:
        cutoffDate = DateTime(now.year, now.month, now.day);
        break;
      case TimeRange.week:
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case TimeRange.month:
        cutoffDate = now.subtract(const Duration(days: 30));
        break;
    }

    // Get the last known count before cutoff
    int lastKnownCount = 0;
    for (var data in _data) {
      if (data.date.isBefore(cutoffDate)) {
        lastKnownCount = data.reportCount;
      }
    }

    // Filter and sort data
    var filteredData = _data
        .where((data) => data.date.isAfter(cutoffDate) || 
                        data.date.isAtSameMomentAs(cutoffDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Add starting point if needed
    if (filteredData.isEmpty || filteredData.first.date.isAfter(cutoffDate)) {
      filteredData.insert(0, AnalyticsData(
        date: cutoffDate,
        reportCount: lastKnownCount,
        userCount: 0,
        activeBanCount: 0,
        regularUserCount: 0,
        googleUserCount: 0,
      ));
    }

    // Add current point if needed
    if (filteredData.isEmpty || filteredData.last.date.isBefore(now)) {
      final lastCount = filteredData.isNotEmpty ? filteredData.last.reportCount : lastKnownCount;
      filteredData.add(AnalyticsData(
        date: now,
        reportCount: lastCount,
        userCount: filteredData.last.userCount,
        activeBanCount: filteredData.last.activeBanCount,
        regularUserCount: filteredData.last.regularUserCount,
        googleUserCount: filteredData.last.googleUserCount,
      ));
    }

    return filteredData;
  }
}
