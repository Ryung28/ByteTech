import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/analytic_model.dart';
import '../services/reports_firestore_service.dart';

class ReportsProvider extends ChangeNotifier {
  final ReportsFirestoreService _service = ReportsFirestoreService();
  List<AnalyticsData> _data = [];
  bool _isLoading = false;
  String? _error;
  String _selectedTimeRange = 'Week';
  bool _initialized = false;
  DateTime? _lastFetchTime;
  static const _cacheValidDuration = Duration(minutes: 5);

  List<AnalyticsData> get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedTimeRange => _selectedTimeRange;
  bool get initialized => _initialized;

  ReportsProvider() {
    initializeData();
  }

  Future<void> initializeData() async {
    if (_initialized && _lastFetchTime != null) {
      final now = DateTime.now();
      if (now.difference(_lastFetchTime!) < _cacheValidDuration) {
        // Data is still valid, no need to fetch
        print('Using cached reports data from ${_lastFetchTime}');
        return;
      }
    }
    await fetchReportsData();
    _initialized = true;
  }

  Future<void> fetchReportsData() async {
    if (_isLoading) return;
    
    try {
      setLoading(true);
      print('Fetching reports data with timeRange: $_selectedTimeRange');
      final newData = await _service.fetchReportsAnalytics(
        timeRange: _selectedTimeRange,
      );
      print('Fetched ${newData.length} data points');
      _lastFetchTime = DateTime.now();
      updateChartData(newData);
    } catch (e, stackTrace) {
      print('Error fetching reports data: $e');
      print('Stack trace: $stackTrace');
      setError(e.toString());
    }
  }

  void updateChartData(List<AnalyticsData> newData) {
    if (newData.isEmpty && _data.isNotEmpty) {
      // Don't update if new data is empty but we have existing data
      print('Keeping existing data instead of updating with empty data');
      _isLoading = false;
      notifyListeners();
      return;
    }
    _data = newData;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void setTimeRange(String timeRange) {
    if (_selectedTimeRange != timeRange) {
      _selectedTimeRange = timeRange;
      // Force a refresh when time range changes
      _lastFetchTime = null;
      fetchReportsData();
    }
  }

  List<FlSpot> getChartSpots() {
    if (_data.isEmpty) return [];
    
    return _data.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.reportCount.toDouble(),
      );
    }).toList();
  }

  double getMaxY() {
    if (_data.isEmpty) return 10;
    return _data.map((d) => d.reportCount).reduce((a, b) => a > b ? a : b).toDouble() + 5;
  }

  int getTotalReports() {
    if (_data.isEmpty) return 0;
    return _data.last.reportCount;
  }

  void clear() {
    // Don't clear the data, just reset the loading state
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
