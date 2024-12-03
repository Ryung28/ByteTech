import 'package:flutter/material.dart';
import 'package:mobileapplication/userdashboard/ocean_educations_hub.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/reusable_userdashboard.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/userdashboard_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/config/theme_config.dart';
import 'package:mobileapplication/reusable_widget/bottom_nav_bar.dart';
import 'package:flutter/services.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<DashboardProvider>(context, listen: false);
        provider.setAnimationController(_animationController);
        provider.initializeData();
      }
    });
  }

  @override
  void dispose() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission granted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        // Set SystemUiOverlayStyle based on app theme
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          // Adapt status bar icons based on theme
          statusBarIconBrightness: Theme.of(context).brightness == Brightness.light 
              ? Brightness.dark 
              : Brightness.light,
          statusBarBrightness: Theme.of(context).brightness == Brightness.light 
              ? Brightness.light 
              : Brightness.dark,
          // Adapt navigation bar based on theme
          systemNavigationBarColor: Theme.of(context).brightness == Brightness.light
              ? const Color.fromARGB(255, 72, 167, 255)  // Your light theme blue
              : ThemeConfig.darkBackground,               // Your dark theme color
          systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.light
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ));

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).brightness == Brightness.light
                          ? const Color.fromARGB(255, 72, 167, 255)
                          : ThemeConfig.darkBackground,
                      Theme.of(context).brightness == Brightness.light
                          ? const Color.fromARGB(255, 158, 201, 253)
                          : ThemeConfig.darkSurface,
                      Theme.of(context).brightness == Brightness.light
                          ? const Color.fromARGB(255, 72, 167, 255)
                          : ThemeConfig.darkCard,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await provider.loadUserData();
                    await provider.updateMarineData();
                  },
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(), 
                    child: Stack(
                      children: [

                        Container(
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color.fromARGB(255, 72, 167, 255)
                                    : ThemeConfig.darkBackground,
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color.fromARGB(255, 158, 201, 253)
                                    : ThemeConfig.darkSurface,
                                Theme.of(context).brightness == Brightness.light
                                    ? const Color.fromARGB(255, 72, 167, 255)
                                    : ThemeConfig.darkCard,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with modern styling
                              UserDashboardWidgets.navbarHeader(
                                provider.userName,
                                provider.isLoading,
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : provider.getDeepBlue(context),
                                provider.getSurfaceBlue(context),
                                provider.getWhiteWater(context),
                                _requestNotificationPermission,
                              ),

                              const SizedBox(height: 12),

                              // Ban Period Schedule Card
                              UserDashboardWidgets.buildBanPeriodCard(
                                provider.startDate,
                                provider.endDate,
                                provider.getSurfaceBlue(context),
                                provider.getAccentBlue(context),
                                provider.getWhiteWater(context),
                                context,
                              ),

                              const SizedBox(height: 12),

                              // Marine Conditions Card
                              UserDashboardWidgets.buildMarineConditionsCard(
                                provider.marineData,
                                Theme.of(context).brightness == Brightness.dark
                                    ? ThemeConfig.darkCard
                                    : provider.getWhiteWater(context),
                                provider.getAccentBlue(context),
                                provider.getAccentBlue(context),
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : provider.getSurfaceBlue(context),
                                () => provider.updateMarineData(),
                              ),

                              const SizedBox(height: 12),

                              // Educational Hub Section
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? ThemeConfig.darkCard
                                      : provider.getWhiteWater(context),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: provider
                                          .getDeepBlue(context)
                                          .withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.school_rounded,
                                              color: provider
                                                  .getAccentBlue(context),
                                              size: 28,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Ocean Education Hub',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : provider
                                                        .getDeepBlue(context),
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.arrow_forward_ios,
                                            color:
                                                provider.getAccentBlue(context),
                                            size: 20,
                                          ),
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OceanEducationHub(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          _buildEducationCard(
                                            'Marine Life',
                                            Icons.pets_rounded,
                                            'Learn about local marine species',
                                          ),
                                          const SizedBox(width: 15),
                                          _buildEducationCard(
                                            'Conservation',
                                            Icons.eco_rounded,
                                            'Discover ways to protect our ocean',
                                          ),
                                          const SizedBox(width: 15),
                                          _buildEducationCard(
                                            'Regulations',
                                            Icons.gavel_rounded,
                                            'Know your marine laws',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: FloatingNavBar(
                    currentIndex: provider.currentIndex,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEducationCard(String title, IconData icon, String description) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return UserDashboardWidgets.buildEducationCard(
            title,
            icon,
            description,
            provider.getSurfaceBlue(context),
            provider.getAccentBlue(context),
            provider.getDeepBlue(context),
            context);
      },
    );
  }
}
