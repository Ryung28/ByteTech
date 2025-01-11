import 'package:flutter/material.dart';
import 'package:mobileapplication/userdashboard/ocean_educations_hub.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/reusable_userdashboard.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/userdashboard_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/config/theme_config.dart';
import 'package:mobileapplication/services/back_handler_service.dart';
import 'package:mobileapplication/reusable_widget/bottom_nav_bar.dart';
import 'package:flutter/services.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/help_support_widget.dart';

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
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize the provider once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<UserDashboardProvider>(context, listen: false);
        provider.setAnimationController(_animationController);
        provider.initializeData();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh(UserDashboardProvider provider) async {
    await provider.loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDashboardProvider>(
      builder: (context, provider, _) {
        // Set SystemUiOverlayStyle based on app theme
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Theme.of(context).brightness == Brightness.light 
              ? Brightness.dark 
              : Brightness.light,
          statusBarBrightness: Theme.of(context).brightness == Brightness.light 
              ? Brightness.light 
              : Brightness.dark,
          systemNavigationBarColor: Theme.of(context).brightness == Brightness.light
              ? const Color.fromARGB(255, 72, 167, 255)
              : ThemeConfig.darkBackground,
          systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.light
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ));

        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) async {
            if (didPop) {
              return;
            }
            final shouldPop = await BackHandlerService.handleBackPress(context);
            if (shouldPop) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: const HelpSupportWidget(),
            body: Stack(
              children: [
                _buildBackground(context),
                SafeArea(
                  bottom: false,
                  child: RefreshIndicator(
                    onRefresh: () => _handleRefresh(provider),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserDashboardWidgets.navbarHeader(
                              provider.userName,
                              provider.isLoading,
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : provider.getDeepBlue(context),
                              provider.getSurfaceBlue(context),
                              provider.getWhiteWater(context),
                              provider.userPhotoUrl,
                              provider.currentQuote,
                            ),
                            const SizedBox(height: 12),
                            _buildBanPeriodSection(context, provider),
                            const SizedBox(height: 12),
                            _buildMarineConditionsSection(context, provider),
                            const SizedBox(height: 12),
                            _buildEducationHubSection(context, provider),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _buildNavigationBar(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildNavigationBar(UserDashboardProvider provider) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: FloatingNavBar(
          currentIndex: provider.currentIndex,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildBanPeriodSection(BuildContext context, UserDashboardProvider provider) {
    return UserDashboardWidgets.buildBanPeriodCard(
      provider.startDate,
      provider.endDate,
      provider.getSurfaceBlue(context),
      provider.getAccentBlue(context),
      provider.getWhiteWater(context),
      context,
    );
  }

  Widget _buildMarineConditionsSection(BuildContext context, UserDashboardProvider provider) {
    return UserDashboardWidgets.buildMarineConditionsCard(
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
    );
  }

  Widget _buildEducationHubSection(BuildContext context, UserDashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ThemeConfig.darkCard
            : provider.getWhiteWater(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: provider.getDeepBlue(context).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEducationHubHeader(context, provider),
          const SizedBox(height: 15),
          _buildEducationCards(),
        ],
      ),
    );
  }

  Widget _buildEducationHubHeader(BuildContext context, UserDashboardProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.school_rounded,
              color: provider.getAccentBlue(context),
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Ocean Education Hub',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : provider.getDeepBlue(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            color: provider.getAccentBlue(context),
            size: 20,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OceanEducationHub(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEducationCards() {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildEducationCard(String title, IconData icon, String description) {
    return Consumer<UserDashboardProvider>(
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
