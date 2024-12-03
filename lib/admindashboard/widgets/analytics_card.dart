// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:mobileapplication/config/theme_config.dart';

// class AnalyticsCard extends StatelessWidget {
//   const AnalyticsCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('analytics')
//           .doc('latest')
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return const Text('Something went wrong');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final data = snapshot.data?.data() as Map<String, dynamic>?;
        
//         final List<FlSpot> spots = [
//           FlSpot(0, data?['userCount']?.toDouble() ?? 0),
//           FlSpot(1, data?['reportCount']?.toDouble() ?? 0),
//           FlSpot(2, data?['activeBanCount']?.toDouble() ?? 0),
//         ];

//         return Column(
//           children: [
//             SizedBox(
//               height: 200,
//               child: LineChart(
//                 LineChartData(
//                   gridData: FlGridData(show: false),
//                   titlesData: FlTitlesData(
//                     leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
//                     bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
//                   ),
//                   borderData: FlBorderData(show: true),
//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: spots,
//                       isCurved: true,
//                       color: ThemeConfig.lightDeepBlue,
//                       belowBarData: BarAreaData(show: false),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildAnalyticItem(
//                   icon: Icons.people_outline,
//                   label: 'Total Users',
//                   value: '${data?['userCount'] ?? 0}',
//                   color: ThemeConfig.lightAccentBlue,
//                 ),
//                 _buildAnalyticItem(
//                   icon: Icons.report_outlined,
//                   label: 'Reports',
//                   value: '${data?['reportCount'] ?? 0}',
//                   color: ThemeConfig.lightDeepBlue,
//                 ),
//                 _buildAnalyticItem(
//                   icon: Icons.block_outlined,
//                   label: 'Active Bans',
//                   value: '${data?['activeBanCount'] ?? 0}',
//                   color: Colors.red.shade400,
//                   subtitle: 'Breeding Season',
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildAnalyticItem({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//     String? subtitle,
//   }) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(
//             icon,
//             color: color,
//             size: 24,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         if (subtitle != null)
//           Text(
//             subtitle,
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[600],
//             ),
//           ),
//       ],
//     );
//   }
// }