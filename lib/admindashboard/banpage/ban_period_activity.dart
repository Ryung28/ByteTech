import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'ban_period_service.dart';

class BanPeriodActivityWidget extends StatelessWidget {
  final BanPeriodService _banPeriodService = BanPeriodService();

  BanPeriodActivityWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _banPeriodService.getBanPeriodHistory(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading ban period history');
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final history = snapshot.data!.docs;
        if (history.isEmpty) {
          return const Text('No recent ban period updates');
        }

        // Show only the last 5 updates
        final recentHistory = history.take(5).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentHistory.length,
          itemBuilder: (context, index) {
            final record = recentHistory[index].data() as Map<String, dynamic>;
            final startDate = (record['startDate'] as Timestamp).toDate();
            final endDate = (record['endDate'] as Timestamp).toDate();
            final archivedAt = (record['archivedAt'] as Timestamp).toDate();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ban Period Updated',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'From ${DateFormat('MMM d, yyyy').format(startDate)} to ${DateFormat('MMM d, yyyy').format(endDate)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          DateFormat('MMM d, yyyy • HH:mm').format(archivedAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
