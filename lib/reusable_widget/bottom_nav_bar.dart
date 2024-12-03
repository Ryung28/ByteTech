import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/providers/navigation_provider.dart';

// User Dashboard Imports
import 'package:mobileapplication/userdashboard/usercomplaintpage/complaint_page.dart';
import 'package:mobileapplication/userdashboard/ocean_educations_hub.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/user_dashboard.dart';
import 'package:mobileapplication/userdashboard/usersettingspage/usersettings_page.dart';

// Admin Dashboard Imports
import 'package:mobileapplication/admindashboard/admindashboardpage/admindashboard_page.dart';
import 'package:mobileapplication/admindashboard/usermanagementpage/usermanagement_page.dart';
import 'package:mobileapplication/admindashboard/managereport_page.dart';

// Base Navigation Bar Widget
abstract class BaseNavBar extends StatefulWidget {
  final int currentIndex;
  final bool isAdmin;

  const BaseNavBar({
    Key? key,
    required this.currentIndex,
    required this.isAdmin,
    required Color backgroundColor,
  }) : super(key: key);
}

// Main Navigation Bar Widget
class FloatingNavBar extends BaseNavBar {
  const FloatingNavBar({
    Key? key,
    required int currentIndex,
    required Color backgroundColor,
    bool isAdmin = false,
  }) : super(
          key: key,
          currentIndex: currentIndex,
          isAdmin: isAdmin,
          backgroundColor: backgroundColor,
        );

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  // Page configurations for User and Admin
  late final List<Widget> _pages;
  late final List<NavItemConfig> _navItems;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeNavigation();
  }

  void _initializeNavigation() {
    if (widget.isAdmin) {
      _initializeAdminNavigation();
    } else {
      _initializeUserNavigation();
    }
  }

  // User Navigation Configuration
  void _initializeUserNavigation() {
    _pages = const [
      UserDashboard(),
      OceanEducationHub(),
      ComplaintPage(),
      UsersettingsPage(),
    ];

    _navItems = [
      NavItemConfig(Icons.home_rounded, 'Home'),
      NavItemConfig(Icons.school_rounded, 'Education'),
      NavItemConfig(Icons.warning_rounded, 'Report'),
      NavItemConfig(Icons.settings_rounded, 'Settings'),
    ];
  }

  // Admin Navigation Configuration
  void _initializeAdminNavigation() {
    _pages = const [
      AdmindashboardPage(),
      ManageUserPage(),
      // ManageReportPage(),
      OceanEducationHub(),
    ];

    _navItems = [
      NavItemConfig(Icons.dashboard_rounded, 'Dashboard'),
      NavItemConfig(Icons.people_rounded, 'Users'),
      NavItemConfig(Icons.assessment_rounded, 'Reports'),
      NavItemConfig(Icons.school_rounded, 'Education'),
    ];
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.value = 1.0;

    if (mounted) {
      Provider.of<NavigationProvider>(context, listen: false)
          .setAnimationController(_animationController);
    }
  }

  void _handleNavigation(int index) {
    if (index == widget.currentIndex) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, provider, _) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final selectedColor =
            NavBarTheme.getSelectedColor(isDarkMode, widget.isAdmin);
        final unselectedColor = NavBarTheme.getUnselectedColor(isDarkMode);

        return Container(
          height: 100,
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                bottom: provider.isVisible ? 20 : -80,
                left: 16,
                right: 16,
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: selectedColor.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(Icons.home_rounded, 'Home', 0,
                          selectedColor, unselectedColor),
                      _buildNavItem(Icons.school_rounded, 'Education', 1,
                          selectedColor, unselectedColor),
                      const SizedBox(width: 40),
                      _buildNavItem(Icons.warning_rounded, 'Report', 2,
                          selectedColor, unselectedColor),
                      _buildNavItem(Icons.settings_rounded, 'Settings', 3,
                          selectedColor, unselectedColor),
                    ],
                  ),
                ),
              ),

              // Toggle Button (Centered)
              Positioned(
                bottom: provider.isVisible ? 50 : 15,
                child: GestureDetector(
                  onTap: provider.toggleNavBar,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          selectedColor,
                          selectedColor
                              .withBlue(min(selectedColor.blue + 30, 255)),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: selectedColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      provider.isVisible
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index,
      Color selectedColor, Color unselectedColor) {
    final isSelected = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => _handleNavigation(index),
      child: TweenAnimationBuilder<double>(
        tween: Tween(
          begin: 0.0,
          end: isSelected ? 1.0 : 0.0,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 1.0 + (0.1 * value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color.lerp(
                    Colors.transparent, selectedColor.withOpacity(0.15), value),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: Color.lerp(unselectedColor, selectedColor, value),
                    size: 22,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      color: Color.lerp(unselectedColor, selectedColor, value),
                      fontSize: 11,
                      fontWeight: FontWeight.lerp(
                        FontWeight.w400,
                        FontWeight.w600,
                        value,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Helper class for navigation item configuration
class NavItemConfig {
  final IconData icon;
  final String label;

  NavItemConfig(this.icon, this.label);
}

// Theme configurations
class NavBarTheme {
  static Color getSelectedColor(bool isDarkMode, bool isAdmin) {
    if (isAdmin) {
      return isDarkMode ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32);
    }
    return isDarkMode ? const Color(0xFF64B5F6) : const Color(0xFF1E88E5);
  }

  static Color getUnselectedColor(bool isDarkMode) {
    return isDarkMode ? Colors.white70 : const Color(0xFF90A4AE);
  }
}
