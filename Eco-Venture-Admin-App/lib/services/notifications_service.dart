import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Logic: Using dynamic dispatch as requested to bypass version conflicts
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
      debugPrint("✅ Notifications Initialized Successfully");
    } catch (e) {
      debugPrint("❌ Notification Initialization Error: $e");
    }

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
        importance: Importance.max,
        priority: Priority.high,
        icon: 'ic_launcher',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      );

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
        android: AndroidNotificationDetails('high_importance_channel', 'High Importance Notifications', importance: Importance.max, priority: Priority.high, icon: 'ic_launcher'),
        iOS: DarwinNotificationDetails(),
      );
      final dynamic plugin = _notificationsPlugin;
      await plugin.show(id, title, body, details, payload: payload);
    } catch (e) {
      debugPrint("❌ ERROR showing manual notification: $e");
    }
  }
}