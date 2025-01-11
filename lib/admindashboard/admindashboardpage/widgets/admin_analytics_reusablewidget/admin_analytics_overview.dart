import 'package:flutter/material.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/modern_loading_animation.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/providers/analytics_provider.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/providers/reports_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/active_bans_chart.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/reportanalytics/reports_chart.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/user_activity_chart.dart';
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
  void initState() {
    super.initState();
    print('Initializing AnalyticsOverview');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProxyProvider<AnalyticsProvider, ReportsProvider>(
          create: (_) => ReportsProvider(),
          update: (_, analyticsProvider, previousReportsProvider) {
            final reportsProvider = previousReportsProvider ?? ReportsProvider();
            if (analyticsProvider.hasData && analyticsProvider.analyticsData != null) {
              reportsProvider.updateChartData(analyticsProvider.analyticsData!);
            }
            return reportsProvider;
          },
        ),
      ],
      child: Consumer<AnalyticsProvider>(
        builder: (context, provider, _) {
          print('Building AnalyticsOverview. Loading: ${provider.isLoading}, HasData: ${provider.hasData}, Error: ${provider.error}');

          if (provider.error != null) {
            print('Error in AnalyticsOverview: ${provider.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.retry(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.isLoading) {
            return const Center(child: ModernLoadingAnimation());
          }

          return Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    provider.setCurrentPage(index);
                  },
                  children: [
                    if (provider.analyticsData != null) ...[
                      UserActivityChart(data: provider.analyticsData!),
                      const ReportsChart(),
                      ActiveBansChart(data: provider.analyticsData!),
                    ] else ...[
                      const Center(child: Text('No data available')),
                      const Center(child: Text('No data available')),
                      const Center(child: Text('No data available')),
                    ],
                  ],
                ),
              ),
              AnalyticsBottomNav(
                pageController: _pageController,
              ),
            ],
          );
        },
      ),
    );
  }
}
