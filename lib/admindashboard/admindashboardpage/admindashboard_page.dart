import 'package:flutter/material.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/admindashboard_provider.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/services/admindashboard_firestore.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/user_analytics_chart.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/reusable_admindashboardwidget.dart';
import 'package:mobileapplication/admindashboard/banpage/banperiodsched.dart';
import 'package:mobileapplication/admindashboard/banpage/ban_period_activity.dart';
import 'package:mobileapplication/admindashboard/educationpage/admin_education_page.dart';
import 'package:mobileapplication/admindashboard/educationpage/education_activity.dart';
import 'package:mobileapplication/admindashboard/reportpage/reportpage.dart';
import 'package:mobileapplication/admindashboard/reportpage/widgets/report_analytics_chart.dart';
import 'package:mobileapplication/admindashboard/settingspage/admin_settings_page.dart';
import 'package:mobileapplication/admindashboard/usermanagementpage/usermanagement_page.dart';
import 'package:mobileapplication/config/theme_config.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/notification_bell.dart';

class AdmindashboardPage extends StatefulWidget {
  const AdmindashboardPage({super.key});

  @override
  State<AdmindashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdmindashboardPage> with SingleTickerProviderStateMixin {
  late final List<Widget> _webPages;
  final AdminDashboardFirestore _dashboardFirestore = AdminDashboardFirestore();
  String _adminName = 'Admin';
  String? _adminPhotoUrl;
  String _lastLogin = 'Today';
  final List<Map<String, dynamic>> _activitySections = [
    {
      'title': 'Reports Overview',
      'icon': Icons.assessment_outlined,
      'color': const Color(0xFF2196F3),
      'items': [
        {
          'title': 'Latest Report',
          'time': '2 hours ago',
          'description': 'Illegal fishing activity near coral reef area',
          'type': 'report',
        },
        {
          'title': 'Active Reports',
          'time': 'Current Status',
          'description': '3 pending reports require review',
          'type': 'report',
        },
      ],
    },
    {
      'title': 'Bans Overview',
      'icon': Icons.gavel_outlined,
      'color': const Color(0xFF2196F3),
      'items': [
        {
          'title': 'Recent Ban',
          'time': '3 days ago',
          'description': 'Vessel XYZ-123: Multiple violations',
          'type': 'ban',
        },
        {
          'title': 'Active Restrictions',
          'time': 'Current Status',
          'description': '2 vessels under temporary restrictions',
          'type': 'ban',
        },
      ],
    },
    {
      'title': 'Educational Content',
      'icon': Icons.school_outlined,
      'color': const Color(0xFF2196F3),
      'items': [
        {
          'title': 'Latest Update',
          'time': 'Yesterday',
          'description': 'Marine Conservation Guidelines revised',
          'type': 'education',
        },
        {
          'title': 'Recent Addition',
          'time': '3 days ago',
          'description': 'New sustainable fishing practices documentation',
          'type': 'education',
        },
      ],
    },
  ];

  final PageController _pageController = PageController();
  late final ValueNotifier<int> _currentPageNotifier;

  @override
  void initState() {
    super.initState();
    _currentPageNotifier = ValueNotifier<int>(0);
    _initializeWebPages();
    _initializeData();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().initializeData();
      _loadAdminData();
    });
  }

  Future<void> _loadAdminData() async {
    try {
      final adminData = await _dashboardFirestore.getAdminData();
      if (mounted) {
        setState(() {
          _adminName = adminData['name'] ?? 'Admin';
          _adminPhotoUrl = adminData['photoURL'];
          _lastLogin = _formatLastLogin(adminData['lastLogin']);
        });
      }
    } catch (e) {
      // Handle error silently or through a proper error handling mechanism
    }
  }

  String _formatLastLogin(String? lastLogin) {
    if (lastLogin == null) return 'Today';
    try {
      final loginDate = DateTime.parse(lastLogin);
      final now = DateTime.now();
      final difference = now.difference(loginDate);

      if (difference.inDays == 0) {
        return 'Today, ${loginDate.hour}:${loginDate.minute.toString().padLeft(2, '0')} ${loginDate.hour >= 12 ? 'PM' : 'AM'}';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return 'Today';
    }
  }

  void _initializeWebPages() {
    _webPages = [
      _buildDashboardContent(),
      const ManageUserPage(),
      const ReportPage(),
      const BanPeriodSchedulePage(),
      const AdminEducationPage(),
      const AdminSettingsPage(),
    ];
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      key: const PageStorageKey('dashboard_content'),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 16.0,
          left: DashboardConstants.kPadding,
          right: DashboardConstants.kPadding,
          bottom: DashboardConstants.kPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnalyticsCard(),
            const SizedBox(height: DashboardConstants.kGridSpacing * 1.5),
            _buildActivitySections(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics Overview',
              style: TextStyle(
                color: ThemeConfig.textDark,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  // Side by side on larger screens
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const UserAnalyticsChart(),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const ReportAnalyticsChart(),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Stack vertically on smaller screens
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 400,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const UserAnalyticsChart(),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        height: 400,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const ReportAnalyticsChart(),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySections() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const DashboardSectionTitle(title: "Recent Activities"),
          const SizedBox(height: DashboardConstants.kGridSpacing),
          ValueListenableBuilder<int>(
            valueListenable: _currentPageNotifier,
            builder: (context, currentPage, _) {
              return SizedBox(
                height: 400,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DashboardConstants.kBorderRadius),
                  ),
                  child: Column(
                    children: [
                      _buildNavigationHeader(currentPage),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: _handlePageChanged,
                          itemCount: _activitySections.length,
                          itemBuilder: (context, index) {
                            final section = _activitySections[index];
                            return SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: _buildActivitySection(section),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationHeader(int currentPage) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: _activitySections.asMap().entries.map((entry) {
              return _buildTabButton(
                index: entry.key,
                section: entry.value,
                isSelected: currentPage == entry.key,
              );
            }).toList(),
          ),
          Row(
            children: [
              _buildNavigationArrow(
                icon: Icons.arrow_back_ios,
                onTap: currentPage > 0 ? () => _animateToPage(currentPage - 1) : null,
                isEnabled: currentPage > 0,
                color: _activitySections[currentPage]['color'],
              ),
              _buildNavigationArrow(
                icon: Icons.arrow_forward_ios,
                onTap: currentPage < _activitySections.length - 1 
                    ? () => _animateToPage(currentPage + 1) 
                    : null,
                isEnabled: currentPage < _activitySections.length - 1,
                color: _activitySections[currentPage]['color'],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required Map<String, dynamic> section,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _animateToPage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? section['color'].withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? section['color'] : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  section['icon'],
                  color: isSelected ? section['color'] : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  section['title'].toString().split(' ')[0],
                  style: TextStyle(
                    color: isSelected ? section['color'] : Colors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationArrow({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
    required Color color,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        size: 20,
        color: isEnabled ? color : Colors.grey.shade300,
      ),
      onPressed: onTap,
    );
  }

  void _handlePageChanged(int page) {
    _currentPageNotifier.value = page;
  }

  void _animateToPage(int index) {
    _currentPageNotifier.value = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildActivitySection(Map<String, dynamic> section) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (section['title'] == 'Reports Overview') {
          if (provider.isLoadingActivities) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final recentReports = provider.recentReports;
          if (recentReports.isEmpty) {
            return const Center(
              child: Text('No recent reports available'),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(section['icon'], color: section['color'], size: 24),
                    const SizedBox(width: 8),
                    Text(
                      section['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: section['color'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...recentReports.map((report) => _buildActivityItem(
                  {
                    'title': report['title'],
                    'time': report['time'],
                    'description': report['description'],
                    'type': report['type'],
                  },
                  section['color'],
                )).toList(),
              ],
            ),
          );
        } else if (section['title'] == 'Bans Overview') {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(section['icon'], color: section['color'], size: 24),
                    const SizedBox(width: 8),
                    Text(
                      section['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: section['color'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BanPeriodActivityWidget(),
              ],
            ),
          );
        } else if (section['title'] == 'Educational Content') {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(section['icon'], color: section['color'], size: 24),
                    const SizedBox(width: 8),
                    Text(
                      section['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: section['color'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                EducationActivityWidget(),
              ],
            ),
          );
        }

        // Return original layout for other sections
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(section['icon'], color: section['color'], size: 24),
                  const SizedBox(width: 8),
                  Text(
                    section['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: section['color'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(
                section['items'].length,
                (index) => _buildActivityItem(
                  section['items'][index],
                  section['color'],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> item, Color color) {
    return InkWell(
      onTap: () {
        // Navigate based on activity type
        switch (item['type']) {
          case 'report':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportPage()),
            );
            break;
          case 'ban':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BanPeriodSchedulePage()),
            );
            break;
          case 'education':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminEducationPage()),
            );
            break;
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  item['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item['description'],
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  Widget _buildNavItem(BuildContext context, int index, String title, IconData icon) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        final isSelected = dashboardProvider.currentIndex == index;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8), // Increased vertical margin
          width: double.infinity,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => dashboardProvider.setCurrentIndex(index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Increased padding
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? Colors.white : Colors.white70,
                      size: 28, // Increased icon size
                    ),
                    if (dashboardProvider.isExpanded) ...[
                      const SizedBox(width: 16), // Increased spacing
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 16, // Increased font size
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 6, // Slightly larger dot
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildNavigationItems(DashboardProvider dashboardProvider) {
    final navItems = <Widget>[
      _buildNavItem(context, 0, 'Dashboard', Icons.dashboard_outlined),
      _buildNavItem(context, 1, 'Users', Icons.people_alt_outlined),
      _buildNavItem(context, 2, 'Reports', Icons.assessment_outlined),
      _buildNavItem(context, 3, 'Bans', Icons.gavel_outlined),
      _buildNavItem(context, 4, 'Education', Icons.school_outlined),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Divider(
          color: Colors.white24,
          thickness: 1,
        ),
      ),
      _buildNavItem(context, 5, 'Settings', Icons.settings_outlined),
    ];
    return navItems;
  }

  Widget _buildSidebar(DashboardProvider dashboardProvider) {
    final fullWidth = dashboardProvider.sidebarWidth;
    return Container(
      width: dashboardProvider.isExpanded
          ? fullWidth
          : DashboardProvider.minSidebarWidth,
      color: const Color(0xFF1A237E),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: dashboardProvider.isExpanded
                ? Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _adminPhotoUrl != null
                            ? NetworkImage(_adminPhotoUrl!)
                            : null,
                        child: _adminPhotoUrl == null
                            ? Icon(
                                Icons.person,
                                color: Colors.grey[700],
                                size: 30,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _adminName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              softWrap: true,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: dashboardProvider.isOnline ? Colors.green : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  dashboardProvider.isOnline ? 'Online' : 'Offline',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _adminPhotoUrl != null
                          ? NetworkImage(_adminPhotoUrl!)
                          : null,
                      child: _adminPhotoUrl == null
                          ? Icon(
                              Icons.person,
                              color: Colors.grey[700],
                              size: 24,
                            )
                          : null,
                    ),
                  ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _buildNavigationItems(dashboardProvider),
              ),
            ),
          ),
          if (dashboardProvider.isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF003366),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const SizedBox(width: 8),
          Image.asset(
            'assets/MarineGuard-Logo-launcher-icon.png',
            height: 89,
          ),
          const SizedBox(width: 8),
          const Text(
            'Marine Guard',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: const [
        NotificationBell(),
        SizedBox(width: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Consumer<DashboardProvider>(
            builder: (context, dashboardProvider, child) {
              return _buildSidebar(dashboardProvider);
            },
          ),
          Expanded(
            child: Column(
              children: [
                PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: _buildAppBar(context),
                ),
                Expanded(
                  child: Consumer<DashboardProvider>(
                    builder: (context, dashboardProvider, child) {
                      return Container(
                        color: const Color(0xFFF5F6FA),
                        child: _webPages[dashboardProvider.currentIndex],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
