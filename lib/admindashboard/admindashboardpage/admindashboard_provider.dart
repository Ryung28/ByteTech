import 'package:flutter/material.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/services/analytics_firestore.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/recent_activities_service.dart';
import 'package:mobileapplication/config/theme_config.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/admin_notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardProvider extends ChangeNotifier {
  int _currentIndex = 0;
  double _sidebarWidth = 280;
  bool _isExpanded = true;
  bool _isOnline = true;
  static const double minSidebarWidth = 80;
  static const double maxSidebarWidth = 400;
  
  final RecentActivitiesService _activitiesService = RecentActivitiesService();
  List<Map<String, dynamic>> _recentReports = [];
  bool _isLoadingActivities = false;
  int _unreadNotifications = 0;
  Stream<QuerySnapshot>? _notificationsStream;

  int get currentIndex => _currentIndex;
  double get sidebarWidth => _sidebarWidth;
  bool get isExpanded => _isExpanded;
  bool get isOnline => _isOnline;
  List<Map<String, dynamic>> get recentReports => _recentReports;
  bool get isLoadingActivities => _isLoadingActivities;
  int get unreadNotifications => _unreadNotifications;
  Stream<QuerySnapshot>? get notificationsStream => _notificationsStream;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void toggleSidebar() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  void updateSidebarWidth(double delta) {
    _sidebarWidth = (_sidebarWidth + delta).clamp(minSidebarWidth, maxSidebarWidth);
    notifyListeners();
  }

  void updateOnlineStatus(bool status) {
    _isOnline = status;
    notifyListeners();
  }

  List<DashboardItem> getDashboardItems(BuildContext context) {
    return [
      DashboardItem(
        title: "Manage Users",
        icon: Icons.people_alt_outlined,
        gradientColors: [ThemeConfig.lightAccentBlue, ThemeConfig.lightDeepBlue],
        onNavigate: () => Navigator.pushNamed(context, '/manage-users'),
      ),
      DashboardItem(
        title: "Manage Reports",
        icon: Icons.assessment_outlined,
        gradientColors: [ThemeConfig.lightSurfaceBlue, ThemeConfig.lightAccentBlue],
        onNavigate: () => Navigator.pushNamed(context, '/manage-reports'),
      ),
      DashboardItem(
        title: "Manage Bans",
        icon: Icons.gavel_outlined,
        gradientColors: [Colors.red.shade300, Colors.red.shade700],
        onNavigate: () => Navigator.pushNamed(context, '/manage-bans'),
      ),
      DashboardItem(
        title: "Educational Info",
        icon: Icons.school_outlined,
        gradientColors: [Colors.orange.shade300, Colors.orange.shade700],
        onNavigate: () => Navigator.pushNamed(context, '/educational-info'),
      ),
      DashboardItem(
        title: "Settings",
        icon: Icons.settings_outlined,
        gradientColors: [Colors.purple.shade300, Colors.purple.shade700],
        onNavigate: () => Navigator.pushNamed(context, '/settings'),
      ),
    ];
  }

  Future<void> initializeData() async {
    try {
      _isLoadingActivities = true;
      notifyListeners();

      final analyticsService = AnalyticsService();
      
      // Initialize notifications stream
      _notificationsStream = AdminNotificationService.getNotifications();
      _updateUnreadCount();

      await Future.wait([
        analyticsService.initializeAnalytics(),
        analyticsService.getUserCounts(),
        analyticsService.fetchAnalyticsData(),
        _fetchRecentActivities(),
      ]);

      _isLoadingActivities = false;
      notifyListeners();
    } catch (e) {
      _isLoadingActivities = false;
      notifyListeners();
      // Handle error silently or through a proper error handling mechanism
    }
  }

  Future<void> _fetchRecentActivities() async {
    try {
      final reports = await _activitiesService.getRecentReports();
      _recentReports = reports;
    } catch (e) {
      print('Error fetching recent activities: $e');
      _recentReports = [];
    }
  }

  Future<void> refreshRecentActivities() async {
    await _fetchRecentActivities();
    notifyListeners();
  }

  Future<void> _updateUnreadCount() async {
    try {
      _unreadNotifications = await AdminNotificationService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      print('Error updating unread count: $e');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await AdminNotificationService.markAsRead(notificationId);
      await _updateUnreadCount();
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
}

class DashboardItem {
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onNavigate;

  DashboardItem({
    required this.title,
    required this.icon,
    required this.gradientColors,
    required this.onNavigate,
  });
}
