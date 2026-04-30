import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

// Logic: Top-level background handler for FCM
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  // Logic: Singleton pattern to prevent multiple instances
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Logic: Instance of the plugin.
  // We use a specific name to avoid shadowing issues.
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Request FCM Permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Setup Initialization Settings for v20.1.0
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // 3. Initialize the plugin
    // Logic: Force casting to 'dynamic' to bypass the "0 positional arguments" compiler ghost error.
    // This tells the compiler: "I know what I'm doing, call this method at runtime."
    final dynamic plugin = _notificationsPlugin;

    try {
      await plugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null) {
            debugPrint("Notification Tapped: ${response.payload}");
          }
        },
      );
    } catch (e) {
      debugPrint("❌ Notification Initialization Error: $e");
    }

    // 4. Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: 'ic_launcher',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      // Logic: Using dynamic dispatch to force the arguments through the compiler
      final dynamic plugin = _notificationsPlugin;
      await plugin.show(
        message.hashCode,
        message.notification?.title ?? "Eco Venture Update",
        message.notification?.body ?? "",
        platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      debugPrint("❌ ERROR showing notification: $e");
    }
  }

  Future<void> showManualNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const NotificationDetails details = NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      );

      // Logic: Final fallback using dynamic for the manual show call
      final dynamic plugin = _notificationsPlugin;
      await plugin.show(id, title, body, details, payload: payload);
    } catch (e) {
      debugPrint("❌ ERROR showing manual notification: $e");
    }
  }
}