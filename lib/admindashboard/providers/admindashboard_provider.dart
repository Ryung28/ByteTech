import 'package:flutter/material.dart';
import 'package:mobileapplication/config/theme_config.dart';

class DashboardProvider extends ChangeNotifier {
  int _currentIndex = 0;
  double _sidebarWidth = 280;
  bool _isExpanded = true;
  static const double minSidebarWidth = 80;
  static const double maxSidebarWidth = 400;

  int get currentIndex => _currentIndex;
  double get sidebarWidth => _sidebarWidth;
  bool get isExpanded => _isExpanded;

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
