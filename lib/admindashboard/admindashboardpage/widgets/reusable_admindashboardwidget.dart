import 'package:flutter/material.dart';
import 'package:mobileapplication/config/theme_config.dart';

class DashboardConstants {
  static const double kPadding = 24.0;
  static const double kGridSpacing = 16.0;
  static const double kIconSize = 32.0;
  static const double kBorderRadius = 12.0;
  static const double kAnalyticsHeight = 300.0;
}

class DashboardSectionTitle extends StatelessWidget {
  final String title;

  const DashboardSectionTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: ThemeConfig.textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class DashboardExpandableSection extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget content;
  final IconData icon;
  final Color color;

  const DashboardExpandableSection({
    Key? key,
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.content,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DashboardConstants.kBorderRadius),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: ThemeConfig.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: ThemeConfig.textDark.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: ThemeConfig.textDark.withOpacity(0.1),
                  ),
                ),
              ),
              child: content,
            ),
        ],
      ),
    );
  }
}

class DashboardSectionContent extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const DashboardSectionContent({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Column(
            children: [
              DashboardListItem(
                title: item['title'] as String,
                date: item['date'] as String,
                status: item['status'] as String,
                statusColor: item['statusColor'] as Color,
                description: item['description'] as String,
              ),
              if (items.last != item) const Divider(),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class DashboardListItem extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  final Color statusColor;
  final String description;

  const DashboardListItem({
    Key? key,
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              color: ThemeConfig.textDark.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: ThemeConfig.textDark.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
