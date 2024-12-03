import 'package:flutter/material.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/analytic_model.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/services/analytics_firestore.dart';

class AnalyticsProvider with ChangeNotifier {
  final AnalyticsService _analyticsService;
  List<AnalyticsData>? _analyticsData;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;

  AnalyticsProvider() : _analyticsService = AnalyticsService() {
    _initializeAnalyticsStream();
  }

  // Getters
  List<AnalyticsData>? get analyticsData => _analyticsData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasData => _analyticsData != null && _analyticsData!.isNotEmpty;
  int? get currentUserCount => _analyticsData?.lastOrNull?.userCount;

  void _initializeAnalyticsStream() {
    _analyticsService.getAnalyticsStream().listen(
      (data) {
        _analyticsData = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setCurrentPage(int page) {
    if (_currentPage != page) {
      _currentPage = page;
      notifyListeners();
    }
  }

  void retry() {
    _isLoading = true;
    _error = null;
    notifyListeners();
    _initializeAnalyticsStream();
  }
}
