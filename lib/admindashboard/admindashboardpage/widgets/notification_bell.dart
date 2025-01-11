import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/admindashboard_provider.dart';
import 'package:intl/intl.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => _showNotificationsDialog(context, provider),
            ),
            if (provider.unreadNotifications > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    '${provider.unreadNotifications}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showNotificationsDialog(BuildContext context, DashboardProvider provider) {
    showDialog(
      context: context,
      builder: (context) => NotificationsDialog(provider: provider),
    );
  }
}

class NotificationsDialog extends StatelessWidget {
  final DashboardProvider provider;

  const NotificationsDialog({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            SizedBox(
              height: 400,
              child: StreamBuilder<QuerySnapshot>(
                stream: provider.notificationsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final notifications = snapshot.data?.docs ?? [];

                  if (notifications.isEmpty) {
                    return const Center(child: Text('No notifications'));
                  }

                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index].data() as Map<String, dynamic>;
                      final notificationId = notifications[index].id;
                      final timestamp = notification['createdAt'] as Timestamp?;
                      final isRead = notification['isRead'] as bool? ?? false;

                      return ListTile(
                        title: Text(
                          notification['title'] as String? ?? '',
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification['message'] as String? ?? ''),
                            if (timestamp != null)
                              Text(
                                DateFormat.yMMMd().add_jm().format(timestamp.toDate()),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                        leading: CircleAvatar(
                          backgroundColor: isRead ? Colors.grey[200] : Colors.blue[100],
                          child: Icon(
                            _getNotificationIcon(notification['type'] as String? ?? ''),
                            color: isRead ? Colors.grey : Colors.blue,
                          ),
                        ),
                        onTap: () {
                          if (!isRead) {
                            provider.markNotificationAsRead(notificationId);
                          }
                          // Handle notification tap (e.g., navigate to the complaint)
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'complaint':
        return Icons.report_problem;
      case 'user':
        return Icons.person;
      case 'system':
        return Icons.system_update;
      default:
        return Icons.notifications;
    }
  }
}
