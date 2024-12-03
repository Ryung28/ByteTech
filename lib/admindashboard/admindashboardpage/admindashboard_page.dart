import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/admin_analytics_overview.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/reusable_admindashboardwidget.dart';
import 'package:mobileapplication/admindashboard/usermanagementpage/usermanagement_page.dart';
import 'package:mobileapplication/config/theme_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:mobileapplication/admindashboard/providers/admindashboard_provider.dart';

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

class AdmindashboardPage extends StatefulWidget {
  const AdmindashboardPage({super.key});

  @override
  State<AdmindashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdmindashboardPage> {
  late final List<Widget> _webPages;
  late final List<DashboardItem> dashboardItems;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isReportsExpanded = false;
  bool _isBansExpanded = false;
  bool _isEducationExpanded = false;

  final List<Map<String, dynamic>> _reportsData = [
    {
      'title': 'Illegal Fishing Report',
      'date': '2 hours ago',
      'status': 'Pending',
      'statusColor': Colors.orange,
      'description': 'Reported illegal fishing activity near coral reef area',
    },
    {
      'title': 'Water Pollution Alert',
      'date': '5 hours ago',
      'status': 'Resolved',
      'statusColor': Colors.green,
      'description': 'Oil spill detected and cleaned up in harbor area',
    },
    {
      'title': 'Unauthorized Vessel',
      'date': '1 day ago',
      'status': 'In Progress',
      'statusColor': Colors.blue,
      'description': 'Unidentified vessel spotted in protected waters',
    },
  ];

  final List<Map<String, dynamic>> _bansData = [
    {
      'title': 'Vessel XYZ-123',
      'date': 'Active since: 3 days ago',
      'status': 'Banned',
      'statusColor': Colors.red,
      'description': 'Multiple violations of fishing regulations',
    },
    {
      'title': 'Company ABC Ltd',
      'date': 'Active since: 1 week ago',
      'status': 'Temporary Ban',
      'statusColor': Colors.orange,
      'description': 'Environmental safety violations',
    },
  ];

  final List<Map<String, dynamic>> _educationData = [
    {
      'title': 'Marine Conservation Guidelines',
      'date': 'Published: Yesterday',
      'status': 'New',
      'statusColor': Colors.green,
      'description': 'Updated guidelines for protected marine areas',
    },
    {
      'title': 'Sustainable Fishing Practices',
      'date': 'Published: 3 days ago',
      'status': 'Updated',
      'statusColor': Colors.blue,
      'description': 'Best practices for sustainable fishing methods',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeDashboardItems();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeWebPages();
  }

  void _initializeDashboardItems() {
    dashboardItems = _createDashboardItems();
  }

  List<DashboardItem> _createDashboardItems() => [
        DashboardItem(
          title: "Manage Users",
          icon: Icons.people_alt_outlined,
          gradientColors: [
            ThemeConfig.lightAccentBlue,
            ThemeConfig.lightDeepBlue
          ],
          onNavigate: () => _navigateToPage(const ManageUserPage()),
        ),
        DashboardItem(
          title: "Manage Reports",
          icon: Icons.assessment_outlined,
          gradientColors: [
            ThemeConfig.lightSurfaceBlue,
            ThemeConfig.lightAccentBlue
          ],
          onNavigate: () => _navigateToPage(const ManageUserPage()),
        ),
        DashboardItem(
          title: "Manage Bans",
          icon: Icons.gavel_outlined,
          gradientColors: [Colors.red.shade300, Colors.red.shade700],
          onNavigate: () => _navigateToPage(const ManageUserPage()),
        ),
        DashboardItem(
          title: "Educational Info",
          icon: Icons.school_outlined,
          gradientColors: [Colors.orange.shade300, Colors.orange.shade700],
          onNavigate: () => _navigateToPage(const ManageUserPage()),
        ),
        DashboardItem(
          title: "Settings",
          icon: Icons.settings_outlined,
          gradientColors: [Colors.purple.shade300, Colors.purple.shade700],
          onNavigate: () => _navigateToPage(const ManageUserPage()),
        ),
      ];

  void _navigateToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void _initializeWebPages() {
    _webPages = [
      _buildDashboardContent(),
      const ManageUserPage(),
      const Center(child: Text('Reports')),
      const Center(child: Text('Bans')),
      const Center(child: Text('Educational Info')),
      const Center(child: Text('Settings')),
    ];
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(DashboardConstants.kPadding),
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DashboardConstants.kBorderRadius),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(DashboardConstants.kPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics Overview',
              style: TextStyle(
                color: ThemeConfig.textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DashboardConstants.kGridSpacing),
            const SizedBox(
              height: DashboardConstants.kAnalyticsHeight,
              child: AnalyticsOverview(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySections() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardSectionTitle(title: "Recent Activities"),
        const SizedBox(height: DashboardConstants.kGridSpacing),
        DashboardExpandableSection(
          title: "Reports Overview",
          isExpanded: _isReportsExpanded,
          onToggle: () =>
              setState(() => _isReportsExpanded = !_isReportsExpanded),
          content: DashboardSectionContent(items: _reportsData),
          icon: Icons.assessment_outlined,
          color: ThemeConfig.lightAccentBlue,
        ),
        const SizedBox(height: DashboardConstants.kGridSpacing),
        DashboardExpandableSection(
          title: "Bans Overview",
          isExpanded: _isBansExpanded,
          onToggle: () => setState(() => _isBansExpanded = !_isBansExpanded),
          content: DashboardSectionContent(items: _bansData),
          icon: Icons.gavel_outlined,
          color: Colors.red.shade400,
        ),
        const SizedBox(height: DashboardConstants.kGridSpacing),
        DashboardExpandableSection(
          title: "Educational Content",
          isExpanded: _isEducationExpanded,
          onToggle: () =>
              setState(() => _isEducationExpanded = !_isEducationExpanded),
          content: DashboardSectionContent(items: _educationData),
          icon: Icons.school_outlined,
          color: Colors.green.shade400,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: kIsWeb ? _buildWebLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildWebLayout() {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return Row(
          children: [
            _buildSidebar(dashboardProvider),
            _buildResizeHandle(dashboardProvider),
            Expanded(child: _webPages[dashboardProvider.currentIndex]),
          ],
        );
      },
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ThemeConfig.lightPrimary.withOpacity(0.9),
                ThemeConfig.lightSurface,
                ThemeConfig.lightBackground,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _initializeDashboardItems();
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                child: _buildDashboardContent(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar(DashboardProvider dashboardProvider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: dashboardProvider.isExpanded
          ? dashboardProvider.sidebarWidth
          : DashboardProvider.minSidebarWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.3, 0.6, 1.0],
          colors: [
            const Color.fromARGB(255, 13, 73, 153).withOpacity(0.95),
            const Color.fromARGB(255, 5, 125, 190).withOpacity(0.85),
            const Color.fromARGB(255, 54, 119, 192).withOpacity(0.9),
            ThemeConfig.lightDeepBlue.withOpacity(1.0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeConfig.lightDeepBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSidebarHeader(dashboardProvider),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3, 0.7, 1.0],
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                    Colors.white.withOpacity(0.02),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: _buildNavigationItems(dashboardProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(DashboardProvider dashboardProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.5, 1.0],
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dashboardProvider.isExpanded) ...[
            Center(
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/MarineGuard-Logo-light.jpg',
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome back,',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              'Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ThemeConfig.lightAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last login: Today, 9:30 AM',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ] else
            Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/MarineGuard-Logo-light.jpg',
                      height: 45,
                      width: 45,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: dashboardProvider.toggleSidebar,
                      child: Icon(
                        dashboardProvider.isExpanded
                            ? Icons.chevron_left
                            : Icons.chevron_right,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResizeHandle(DashboardProvider dashboardProvider) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) =>
          dashboardProvider.updateSidebarWidth(details.delta.dx),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: Container(
          width: 8,
          color: Colors.transparent,
          child: const VerticalDivider(
            thickness: 1,
            width: 1,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavigationItems(DashboardProvider dashboardProvider) {
    final navItems = <Widget>[
      _buildNavItem(context, 0, 'Dashboard', Icons.dashboard_outlined),
      _buildNavItem(context, 1, 'Users', Icons.people_alt_outlined),
      _buildNavItem(context, 2, 'Reports', Icons.assessment_outlined),
      _buildNavItem(context, 3, 'Bans', Icons.gavel_outlined),
      _buildNavItem(context, 4, 'Education', Icons.school_outlined),
      const Divider(
        color: Colors.white24,
        thickness: 1,
        indent: 16,
        endIndent: 16,
      ),
      _buildNavItem(context, 5, 'Settings', Icons.settings_outlined),
    ];
    return navItems;
  }

  Widget _buildNavItem(
      BuildContext context, int index, String title, IconData icon) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        final isSelected = dashboardProvider.currentIndex == index;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: dashboardProvider.isExpanded
                ? ListTile(
                    onTap: () => dashboardProvider.setCurrentIndex(index),
                    selected: isSelected,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    selectedTileColor:
                        ThemeConfig.lightAccent.withOpacity(0.15),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isSelected
                              ? [
                                  ThemeConfig.lightAccentBlue.withOpacity(0.3),
                                  ThemeConfig.lightAccentBlue.withOpacity(0.1),
                                ]
                              : [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                        size: 22,
                      ),
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    hoverColor: ThemeConfig.lightAccent.withOpacity(0.1),
                  )
                : InkWell(
                    onTap: () => dashboardProvider.setCurrentIndex(index),
                    borderRadius: BorderRadius.circular(10),
                    hoverColor: ThemeConfig.lightAccent.withOpacity(0.1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isSelected
                              ? [
                                  ThemeConfig.lightAccentBlue.withOpacity(0.3),
                                  ThemeConfig.lightAccentBlue.withOpacity(0.1),
                                ]
                              : [
                                  Colors.transparent,
                                  Colors.transparent,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                        size: 24,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
