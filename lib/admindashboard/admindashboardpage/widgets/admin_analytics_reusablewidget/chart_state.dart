import 'package:flutter/material.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/analytic_model.dart';

enum TimeRange { today, week, month }

class ChartState extends ChangeNotifier {
  TimeRange _selectedRange = TimeRange.today;
  TimeRange get selectedRange => _selectedRange;

  List<AnalyticsData> _data = [];
  List<AnalyticsData> get filteredData => filterData(_data);

  void updateTimeRange(TimeRange range) {
    _selectedRange = range;
    notifyListeners();
  }

  void updateData(List<AnalyticsData> newData) {
    _data = List.from(newData);
    notifyListeners();
  }

  List<AnalyticsData> filterData(List<AnalyticsData> data) {
    final now = DateTime.now();
    final sortedData = List<AnalyticsData>.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sortedData.isEmpty) return [];

    final latestCount = sortedData.last.userCount;

    switch (_selectedRange) {
      case TimeRange.today:
        return sortedData
            .where((d) =>
                d.date.year == now.year &&
                d.date.month == now.month &&
                d.date.day == now.day)
            .toList();
      case TimeRange.week:
        final weekAgo = now.subtract(const Duration(days: 7));
        var weekData = _aggregateData(
            sortedData.where((d) => d.date.isAfter(weekAgo)).toList(),
            const Duration(hours: 12));
        if (weekData.isNotEmpty) {
          weekData.last = weekData.last.copyWith(userCount: latestCount);
        }
        return weekData;
      case TimeRange.month:
        final monthAgo = now.subtract(const Duration(days: 30));
        var monthData = _aggregateData(
            sortedData.where((d) => d.date.isAfter(monthAgo)).toList(),
            const Duration(days: 1));
        if (monthData.isNotEmpty) {
          monthData.last = monthData.last.copyWith(userCount: latestCount);
        }
        return monthData;
    }
  }

  List<AnalyticsData> _aggregateData(
      List<AnalyticsData> data, Duration interval) {
    if (data.isEmpty) return [];

    final aggregated = <AnalyticsData>[];
    var currentInterval = data.first.date;
    final lastDate = data.last.date;

    while (currentInterval.isBefore(lastDate) ||
        currentInterval.isAtSameMomentAs(lastDate)) {
      final nextInterval = currentInterval.add(interval);
      final pointData = data.where((d) =>
          d.date
              .isAfter(currentInterval.subtract(const Duration(minutes: 1))) &&
          d.date.isBefore(nextInterval));

      if (pointData.isNotEmpty) {
        try {
          final avgCount =
              pointData.map((d) => d.userCount).reduce((a, b) => a + b) ~/
                  pointData.length;
          final avgReportCount =
              pointData.map((d) => d.reportCount).reduce((a, b) => a + b) ~/
                  pointData.length;
          final avgActiveBanCount =
              pointData.map((d) => d.activeBanCount).reduce((a, b) => a + b) ~/
                  pointData.length;
          aggregated.add(AnalyticsData(
            date: currentInterval,
            userCount: avgCount,
            reportCount: avgReportCount,
            activeBanCount: avgActiveBanCount,
          ));
        } catch (e) {
          print('Error aggregating analytics data: $e');
          aggregated.add(AnalyticsData(
            date: currentInterval,
            userCount: 0,
            reportCount: 0,
            activeBanCount: 0,
          ));
        }
      }
      currentInterval = nextInterval;
    }
    return aggregated;
  }
}
