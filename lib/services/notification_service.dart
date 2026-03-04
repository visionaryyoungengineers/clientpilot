import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  int _unreadCount = 0;

  Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Configure foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground!');
    });

    // Configure background/terminated handler (usually defined top-level in main)
    // This allows us to handle taps on notifications
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });

    // Optional: Get token
    // String? token = await _firebaseMessaging.getToken();
    // print('FCM Token: \$token');
  }

  void resetBadges() {
    _unreadCount = 0;
  }
}
