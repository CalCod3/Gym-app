// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initializes the notification service.
  Future<void> initialize() async {
    // Request notification permissions from the user.
    await requestPermission();

    // Initialize local notifications.
    await _initializeLocalNotifications();

    // Get the FCM token and send it to your server if needed.
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
      // TODO: Send this token to your server.
    }

    // Listen for foreground messages and handle them.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Requests notification permissions from the user.
  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  /// Initializes local notifications for Android and iOS.
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      // Add any iOS-specific initialization settings here if needed.
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Handles incoming foreground messages.
  void _handleForegroundMessage(RemoteMessage message) {
    print('Received a foreground message: ${message.messageId}');
    if (message.notification != null) {
      _showLocalNotification(message);
    }
  }

  /// Displays a local notification based on the received [RemoteMessage].
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Replace with your channel ID
      'Your Channel Name', // Replace with your channel name
      channelDescription: 'Your Channel Description', // Replace with your channel description
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID (can be unique per notification)
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }
}

/// Handles background messages. This must be a top-level function.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // Optionally, display a local notification or perform other tasks.
  // Example:
  // await NotificationService()._showLocalNotification(message);
}
