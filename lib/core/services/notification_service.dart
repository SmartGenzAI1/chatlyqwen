/// @file lib/core/services/notification_service.dart
/// @brief Notification service for handling local and push notifications
/// @author Chatly Development Team
/// @date 2025-12-08
///
/// This file implements a comprehensive notification service that handles both
/// local notifications and Firebase Cloud Messaging (FCM) push notifications.
/// It includes smart notification timing algorithms, battery optimization,
/// and user preference management. The service integrates with Firebase
/// Messaging and provides a unified interface for notification management.

import 'dart:async';
import 'package:chatly/core/constants/app_constants.dart';
import 'package:chatly/core/providers/auth_provider.dart';
import 'package:chatly/core/utils/handlers/preference_handler.dart';
import 'package:chatly/core/utils/handlers/toast_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  late AndroidInitializationSettings _androidInitSettings;
  late IOSInitializationSettings _iOSInitSettings;
  late InitializationSettings _initializationSettings;
  StreamController<String> _messageStreamController = StreamController<String>.broadcast();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();

  Future<void> init() async {
    _setupLocalNotifications();
    _setupFirebaseMessaging();
    _setupNotificationPreferences();
  }

  void _setupLocalNotifications() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    _androidInitSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    
    _iOSInitSettings = const IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    _initializationSettings = InitializationSettings(
      android: _androidInitSettings,
      iOS: _iOSInitSettings,
    );
    
    _flutterLocalNotificationsPlugin.initialize(_initializationSettings);
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });
    
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessageTap(message);
    });
    
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    // Handle background message
  }

  void _setupNotificationPreferences() {
    // Setup default preferences if not set
    final preferenceHandler = PreferenceHandler();
    preferenceHandler.getEnableSmartNotifications().then((enabled) {
      if (enabled == null) {
        preferenceHandler.saveEnableSmartNotifications(true);
      }
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final preferenceHandler = PreferenceHandler();
    final enableSmartNotifications = await preferenceHandler.getEnableSmartNotifications();
    
    if (!enableSmartNotifications) return;
    
    try {
      await _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title ?? 'New Message',
        message.notification?.body ?? 'You have a new message',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'chatly_channel',
            'Chatly Messages',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            channelShowBadge: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to show notification: $e');
      }
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    int? id,
    String? payload,
    bool highPriority = false,
  }) async {
    final preferenceHandler = PreferenceHandler();
    final enableSmartNotifications = await preferenceHandler.getEnableSmartNotifications();
    
    if (!enableSmartNotifications) return;
    
    // Smart notification timing algorithm
    if (highPriority) {
      await _showImmediateNotification(title, body, id, payload);
    } else {
      await _scheduleSmartNotification(title, body, id, payload);
    }
  }

  Future<void> _showImmediateNotification(String title, String body, int? id, String? payload) async {
    try {
      await _flutterLocalNotificationsPlugin.show(
        id ?? DateTime.now().millisecondsSinceEpoch,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'chatly_channel_immediate',
            'Chatly Important',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
            channelShowBadge: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            criticalAlert: true,
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to show immediate notification: $e');
      }
    }
  }

  Future<void> _scheduleSmartNotification(String title, String body, int? id, String? payload) async {
    final now = DateTime.now();
    final hour = now.hour;
    final batteryLevel = 0.5; // Placeholder - would get actual battery level
    
    // Smart timing algorithm
    DateTime scheduledTime;
    
    if (hour >= 22 || hour < 6) {
      // Night time - schedule for morning
      scheduledTime = DateTime(now.year, now.month, now.day + 1, 9, 0);
    } else if (batteryLevel < 0.2) {
      // Low battery - batch notifications
      scheduledTime = now.add(const Duration(minutes: 30));
    } else {
      // Normal hours - show immediately
      scheduledTime = now;
    }
    
    if (scheduledTime.isBefore(now.add(const Duration(minutes: 1)))) {
      await _showImmediateNotification(title, body, id, payload);
    } else {
      try {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id ?? DateTime.now().millisecondsSinceEpoch,
          title,
          body,
          scheduledTime,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'chatly_channel_scheduled',
              'Chatly Scheduled',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              playSound: true,
              enableVibration: true,
              channelShowBadge: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Failed to schedule smart notification: $e');
        }
      }
    }
  }

  void _handleMessageTap(RemoteMessage message) {
    // Handle notification tap - navigate to appropriate screen
    _messageStreamController.add(message.data.toString());
  }

  Stream<String> get notificationStream {
    return _messageStreamController.stream;
  }

  Future<void> requestNotificationPermissions(BuildContext context) async {
    final preferenceHandler = PreferenceHandler();
    final hasAskedForPermissions = await preferenceHandler.getNotificationPermissions();
    
    if (hasAskedForPermissions == true) return;
    
    // Show permission dialog
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Notification Permissions'),
          content: const Text(
            'Chatly can send you notifications for new messages and important updates. Would you like to enable notifications?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('No thanks'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Enable'),
            ),
          ],
        );
      },
    ).then((enable) {
      if (enable == true) {
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestPermissions();
        
        // Save preference
        preferenceHandler.saveNotificationPermissions(true);
      } else {
        preferenceHandler.saveNotificationPermissions(false);
      }
    });
  }

  Future<bool> checkNotificationPermissions() async {
    final preferenceHandler = PreferenceHandler();
    return preferenceHandler.getNotificationPermissions() ?? false;
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Smart notification features for premium users
  Future<void> setupSmartNotificationPreferences(String tier) async {
    final preferenceHandler = PreferenceHandler();
    
    if (tier == 'free') {
      await preferenceHandler.saveEnableSmartNotifications(false);
    } else {
      await preferenceHandler.saveEnableSmartNotifications(true);
    }
  }

  // Battery optimization check
  bool shouldBatchNotifications(double batteryLevel) {
    return batteryLevel < 0.2;
  }

  // TODO: Implement notification grouping for Android
  // TODO: Add notification snooze functionality
  // TODO: Implement notification settings per chat
  // WARNING: Handle sensitive data carefully in notification payloads
}
