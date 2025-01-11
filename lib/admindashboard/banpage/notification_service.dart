import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package for DateFormat

class NotificationService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Request notification permissions first
      await requestPermissions();

      // Initialize awesome_notifications
      final initialized = await AwesomeNotifications().initialize(
        'resource://mipmap/ic_launcher',
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

      // Set up action stream
      AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
      );

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
      print('Attempting to show notification:');
      print('Title: $title');
      print('Body: $body');

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
      print('Notification created successfully');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  static Future<void> listenToBanPeriodChanges() async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Listen to changes in banPeriod collection
      FirebaseFirestore.instance
          .collection('banPeriod')
          .doc('schedule')
          .snapshots()
          .listen((snapshot) async {
        if (snapshot.exists) {
          final data = snapshot.data();
          if (data != null) {
            final startDate = (data['startDate'] as Timestamp?)?.toDate();
            final endDate = (data['endDate'] as Timestamp?)?.toDate();
            
            if (startDate != null && endDate != null) {
              final startFormatted = DateFormat('MMM d, yyyy').format(startDate);
              final endFormatted = DateFormat('MMM d, yyyy').format(endDate);
              
              await showBanPeriodNotification(
                title: '🚫 New Fishing Ban Period',
                body: '📅 A new ban period has been set:\n\n'
                    '▶️ Start: $startFormatted\n'
                    '▶️ End: $endFormatted\n\n'
                    'Please take note of these dates. Fishing is prohibited during this period.',
              );
              debugPrint('Ban period notification sent successfully');
            }
          }
        }
      }, onError: (error) {
        debugPrint('Error listening to ban period changes: $error');
      });
    } catch (e) {
      debugPrint('Error setting up ban period listener: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    debugPrint('Notification action received: ${receivedAction.toMap().toString()}');
    // Handle notification actions here
  }
}
