import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/analytic_model.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/chart_state.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/time_formatter_mixin.dart';
import 'package:mobileapplication/config/theme_config.dart';
import 'package:mobileapplication/reusable_widget/reusable_widget.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:ui';
import 'admin_analytics_reusablewidget/chart_styles.dart';

class UserActivityChart extends StatelessWidget {
  final List<AnalyticsData> data;

  const UserActivityChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => ChartState()..updateData(data),
        child: const _ChartContent(),
      );
}

class _ChartContent extends StatelessWidget {
  const _ChartContent();

  @override
  Widget build(BuildContext context) {
    final data = context.select((ChartState state) => state.filteredData);

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, data),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 8, 4),
              child: _ChartBody(data: data),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<AnalyticsData> data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Users',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                myText(
                  data.last.userCount.toString(),
                  labelstyle: const TextStyle(
                    fontSize: 24,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: _TimeRangeSelector(),
          ),
        ],
      ),
    );
  }
}

class _TimeRangeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentRange =
        context.select((ChartState state) => state.selectedRange);

    return PopupMenuButton<TimeRange>(
      initialValue: currentRange,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: _buildSelectorButton(currentRange),
      onSelected: (TimeRange range) =>
          context.read<ChartState>().updateTimeRange(range),
      itemBuilder: (context) => [
        _buildPopupItem(TimeRange.today, Icons.today, 'Today'),
        _buildPopupItem(TimeRange.week, Icons.view_week, 'Week'),
        _buildPopupItem(TimeRange.month, Icons.calendar_month, 'Month'),
      ],
    );
  }

  Widget _buildSelectorButton(TimeRange currentRange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconForRange(currentRange),
            size: 16,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 4),
          Text(
            _getLabelForRange(currentRange),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            size: 16,
            color: Colors.grey[700],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<TimeRange> _buildPopupItem(
          TimeRange range, IconData icon, String label) =>
      PopupMenuItem(
        value: range,
        child: Row(
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      );

  IconData _getIconForRange(TimeRange range) {
    switch (range) {
      case TimeRange.today:
        return Icons.today;
      case TimeRange.week:
        return Icons.view_week;
      case TimeRange.month:
        return Icons.calendar_month;
    }
  }

  String _getLabelForRange(TimeRange range) {
    switch (range) {
      case TimeRange.today:
        return 'Today';
      case TimeRange.week:
        return 'Week';
      case TimeRange.month:
        return 'Month';
    }
  }
}

class _ChartBody extends StatelessWidget with TimeFormatterMixin {
  final List<AnalyticsData> data;

  const _ChartBody({required this.data});

  @override
  Widget build(BuildContext context) => LineChart(
        LineChartData(
          gridData: _buildGrid(),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 0.8),
              left: BorderSide(color: Colors.grey[300]!, width: 0.8),
            ),
          ),
          titlesData: _buildTitlesData(context),
          lineTouchData: _buildTouchData(context),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: data.isEmpty
              ? 10
              : (data.map((e) => e.userCount).reduce(max) * 1.2),
          lineBarsData: [_buildLineChartBarData()],
          backgroundColor: Colors.white,
        ),
        duration: const Duration(milliseconds: 250),
      );

  FlGridData _buildGrid() {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: 5,
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey[200]!,
          strokeWidth: 0.5,
          dashArray: value % 10 == 0 ? null : [5, 5],
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: Colors.grey[200]!,
          strokeWidth: 0.5,
          dashArray: [5, 5],
        );
      },
    );
  }

  double calculateInterval(TimeRange selectedRange) {
    final dataLength = data.length;
    
    if (selectedRange == TimeRange.today) {
      return dataLength <= 8 ? 1 : (dataLength <= 12 ? 2 : 3);
    } else if (selectedRange == TimeRange.week) {
      return dataLength <= 7 ? 1 : 2;
    }
    return dataLength <= 15 ? 2 : 3;  // For month view
  }

  FlTitlesData _buildTitlesData(BuildContext context) {
    final chartState = context.read<ChartState>();

    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: _buildBottomTitles(context, chartState),
      leftTitles: _buildLeftTitles(),
    );
  }

  AxisTitles _buildBottomTitles(BuildContext context, ChartState chartState) {
    return AxisTitles(
      axisNameWidget: Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Text('Time', style: ChartStyles.axisNameStyle),
      ),
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 35, // Increased from 15 to give more space
        interval: calculateInterval(chartState.selectedRange),
        getTitlesWidget: (value, meta) {
          if (value.toInt() >= 0 && value.toInt() < data.length) {
            return Container(
              padding: const EdgeInsets.only(top: 1),
              width: 35,
              child: Text(
                formatTimeLabel(data[value.toInt()].date, chartState.selectedRange),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  fontFeatures: [
                    const FontFeature.enable('sups'), // Makes AM/PM text larger
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  AxisTitles _buildLeftTitles() {
    return AxisTitles(
      axisNameWidget: Container(
        margin: const EdgeInsets.only(right: 25),
        child: Text(
          'Users',
          style: ChartStyles.axisNameStyle,
          textAlign: TextAlign.center,
        ),
      ),
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 45,
        interval: 10,
        getTitlesWidget: (value, meta) {
          return Container(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              value.toInt().toString(),
              style: ChartStyles.labelStyle,
              textAlign: TextAlign.right,
            ),
          );
        },
      ),
    );
  }

  LineTouchData _buildTouchData(BuildContext context) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: const Color(0xFF1A1F36),
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.all(12),
        tooltipMargin: 8,
        getTooltipItems: (spots) {
          if (spots.isEmpty) return [];
          
          return List.generate(spots.length, (i) {
            final spot = spots[i];
            final index = spot.x.toInt();
            if (index < 0 || index >= data.length) {
              // Return a dummy tooltip to maintain size consistency
              return LineTooltipItem(
                '0 Users\n',
                ChartStyles.tooltipTitleStyle,
                children: [
                  TextSpan(
                    text: 'No data',
                    style: ChartStyles.tooltipSubtitleStyle,
                  ),
                ],
              );
            }
            
            final pointData = data[index];
            final chartState = context.read<ChartState>();
            final formattedTime = formatTooltipTime(pointData.date, chartState.selectedRange);
            
            return LineTooltipItem(
              '${spot.y.toInt()} Users\n',
              ChartStyles.tooltipTitleStyle,
              children: [
                TextSpan(
                  text: formattedTime,
                  style: ChartStyles.tooltipSubtitleStyle,
                ),
              ],
            );
          });
        },
      ),
      touchSpotThreshold: 20,
      handleBuiltInTouches: true,
      getTouchedSpotIndicator: (barData, spotIndexes) {
        return spotIndexes.map((spotIndex) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: ThemeConfig.lightDeepBlue.withOpacity(0.2),
              strokeWidth: 2,
              dashArray: [3, 3],
            ),
            FlDotData(
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: ThemeConfig.lightDeepBlue,
                );
              },
            ),
          );
        }).toList();
      },
    );
  }

  LineChartBarData _buildLineChartBarData() {
    final gradientColors = [
      ThemeConfig.lightDeepBlue,
      ThemeConfig.lightDeepBlue.withOpacity(0.8),
    ];

    return LineChartBarData(
      spots: List.generate(
        data.length,
        (i) => FlSpot(i.toDouble(), data[i].userCount.toDouble()),
      ),
      isCurved: true,
      curveSmoothness: 0.35,
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      barWidth: 2.0,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final isLast = index == data.length - 1;
          if (isLast) {
            return FlDotCirclePainter(
              radius: 3,
              strokeWidth: 2,
              color: Colors.white,
              strokeColor: ThemeConfig.lightDeepBlue,
            );
          }
          return FlDotCirclePainter(
            radius: 1.2,
            color: Colors.white,
            strokeWidth: 1.5,
            strokeColor: ThemeConfig.lightDeepBlue.withOpacity(0.5),
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ThemeConfig.lightDeepBlue.withOpacity(0.12),
            ThemeConfig.lightDeepBlue.withOpacity(0.01),
          ],
          stops: const [0.2, 0.9],
        ),
      ),
    );
  }
}
