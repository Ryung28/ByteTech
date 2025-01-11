import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/firestore_service.dart';

class UserNotificationBell extends StatelessWidget {
  const UserNotificationBell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<int>(
      stream: FirestoreService.getUnreadUserNotificationsCount(user.uid),
      builder: (context, snapshot) {
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.black87,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                onPressed: () => _showNotificationsDialog(context, user.uid),
                tooltip: 'Notifications',
              ),
              if (snapshot.hasData && snapshot.data! > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 10,
                      minHeight: 10,
                    ),
                    child: Text(
                      '${snapshot.data}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationsDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => NotificationsDialog(userId: userId),
    );
  }
}

class NotificationsDialog extends StatelessWidget {
  final String userId;

  const NotificationsDialog({
    Key? key,
    required this.userId,
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
                stream: FirestoreService.getUserNotifications(userId),
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
                            FirestoreService.markUserNotificationAsRead(notificationId);
                          }
                          // Handle notification tap (e.g., navigate to the complaint details)
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
      case 'status_update':
        return Icons.update;
      case 'complaint':
        return Icons.report_problem;
      case 'system':
        return Icons.system_update;
      default:
        return Icons.notifications;
    }
  }
}
