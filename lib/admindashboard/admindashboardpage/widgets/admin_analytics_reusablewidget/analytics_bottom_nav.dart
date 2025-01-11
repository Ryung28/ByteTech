import 'package:flutter/material.dart';
import 'package:mobileapplication/config/theme_config.dart';
import 'package:provider/provider.dart';
import 'providers/analytics_provider.dart';

class AnalyticsBottomNav extends StatelessWidget {
  final PageController pageController;

  const AnalyticsBottomNav({
    super.key,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      margin: const EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              label: 'User Activity',
              icon: Icons.trending_up,
              page: 0,
              pageController: pageController,
            ),
            _NavItem(
              label: 'Reports',
              icon: Icons.report_problem_outlined,
              page: 1,
              pageController: pageController,
            ),
            _NavItem(
              label: 'Active Bans',
              icon: Icons.block_outlined,
              page: 2,
              pageController: pageController,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final int page;
  final PageController pageController;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.page,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final currentPage = context.select((AnalyticsProvider p) => p.currentPage);
    final isSelected = currentPage == page;

    return InkWell(
      onTap: () {
        pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? ThemeConfig.lightDeepBlue : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? ThemeConfig.lightDeepBlue : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
