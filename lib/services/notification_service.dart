import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize awesome_notifications
      final initialized = await AwesomeNotifications().initialize(
        'resource://mipmap/ic_launcher', // Use the launcher icon
        [
          NotificationChannel(
            channelKey: 'ban_period_channel',
            channelName: 'Ban Period Updates',
            channelDescription: 'Notifications for fishing ban period updates',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: const Color(0xFF9D50DD),
            importance: NotificationImportance.High,
            playSound: true,
            enableVibration: true,
            defaultRingtoneType: DefaultRingtoneType.Notification,
            criticalAlerts: true,
            defaultPrivacy: NotificationPrivacy.Public,
            enableLights: true,
          )
        ],
      );

      if (!initialized) {
        debugPrint('Failed to initialize awesome_notifications');
        return;
      }

      _initialized = true;
      debugPrint('Notification service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      _initialized = false;
    }
  }

  static Future<void> requestPermissions() async {
    try {
      final status = await Permission.notification.request();
      if (status.isDenied) {
        debugPrint('System notification permission denied');
        return;
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  static Future<void> showBanPeriodNotification({
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      debugPrint('Attempting to show notification:');
      debugPrint('Title: $title');
      debugPrint('Body: $body');

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'ban_period_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.BigText,
          criticalAlert: true,
          displayOnForeground: true,
          displayOnBackground: true,
          wakeUpScreen: true,
          autoDismissible: false,
          showWhen: true,
          category: NotificationCategory.Reminder,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'VIEW_BAN_PERIOD',
            label: 'View Details',
            enabled: true,
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'DISMISS',
            label: 'Dismiss',
            enabled: true,
            autoDismissible: true,
          ),
        ],
      );
      debugPrint('Notification created successfully');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  static Future<void> listenToBanPeriodChanges() async {
    if (!_initialized) {
      await initialize();
    }

    // Listen to changes in banPeriod collection
    FirebaseFirestore.instance
        .collection('banPeriod')
        .doc('schedule')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          final startDate = (data['startDate'] as Timestamp?)?.toDate();
          final endDate = (data['endDate'] as Timestamp?)?.toDate();
          
          if (startDate != null && endDate != null) {
            final startFormatted = DateFormat('MMMM d, yyyy').format(startDate);
            final endFormatted = DateFormat('MMMM d, yyyy').format(endDate);
            
            showBanPeriodNotification(
              title: '🚫 New Fishing Ban Period Alert',
              body: '📢 Important Notice:\n\n'
                  '🗓️ A new fishing ban period has been scheduled:\n\n'
                  '📅 Start Date: $startFormatted\n'
                  '📅 End Date: $endFormatted\n\n'
                  '⚠️ REMINDER: Fishing activities are strictly prohibited during this period.\n\n'
                  '🌊 Help protect our marine resources by observing the ban period.\n'
                  '📱 Check the app for more details.',
            );
          }
        }
      }
    });
  }
}
