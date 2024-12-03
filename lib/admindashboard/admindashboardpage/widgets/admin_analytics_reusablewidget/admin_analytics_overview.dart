import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/active_bans_chart.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/reports_chart.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/user_activity_chart.dart';
import 'package:mobileapplication/reusable_widget/loading_animation_admin_analytics.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/providers/analytics_provider.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/analytics_bottom_nav.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/analytics_error_view.dart';

class AnalyticsOverview extends StatefulWidget {
  const AnalyticsOverview({super.key});

  @override
  State<AnalyticsOverview> createState() => _AnalyticsOverviewState();
}

class _AnalyticsOverviewState extends State<AnalyticsOverview> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalyticsProvider(),
      child: Consumer<AnalyticsProvider>(
        builder: (context, provider, _) {
          if (provider.error != null) {
            return const AnalyticsErrorView();
          }

          if (provider.isLoading) {
            return const ModernLoadingAnimation();
          }

          if (!provider.hasData) {
            return const Center(child: Text('No data available'));
          }

          return Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: PageView(
                    physics: const BouncingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (page) => provider.setCurrentPage(page),
                    children: [
                      UserActivityChart(data: provider.analyticsData!),
                      ReportsChart(data: provider.analyticsData!),
                      ActiveBansChart(data: provider.analyticsData!),
                    ],
                  ),
                ),
              ),
              AnalyticsBottomNav(pageController: _pageController),
            ],
          );
        },
      ),
    );
  }
}
