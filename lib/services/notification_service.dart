// ignore_for_file: unused_field, avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void initialize() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.messageId}');
      if (message.notification != null) {
        // Show notification or update UI as needed
        print('Notification Title: ${message.notification!.title}');
        print('Notification Body: ${message.notification!.body}');
      }
    });

    // Handle background messages when the app is in the background or terminated
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}
