// ignore_for_file: avoid_print

import 'package:WOD_Book/auth/auth_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final String _baseUrl;

  // Private constructor
  NotificationService._internal(this._baseUrl);

  /// Factory constructor to initialize the NotificationService with the base URL.
  factory NotificationService.create() {
    final String? baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('API base URL is not set. Please check your .env file.');
    }

    return NotificationService._internal(baseUrl);
  }

  /// Initializes the notification service.
  Future<void> initialize() async {
    // Request notification permissions from the user.
    await requestPermission();

    // Initialize local notifications.
    await _initializeLocalNotifications();

    // Get the FCM token and send it to your server.
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
      await sendTokenToBackend(token);
    }

    // Listen for foreground messages and handle them.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Sends the FCM token to the backend.
  Future<void> sendTokenToBackend(String token) async {
    try {
      final userId = AuthProvider().userId;
      final response = await http.post(
        Uri.parse('$_baseUrl/users/$userId/fcm-token'),
        body: {'token': token},
      );
      if (response.statusCode == 200) {
        print("Token sent to backend successfully.");
      } else {
        print("Failed to send token to backend: ${response.body}");
      }
    } catch (e) {
      print("Error sending token to backend: $e");
    }
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
}
