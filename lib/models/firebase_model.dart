import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('ic_notification');
    const DarwinInitializationSettings iosInitializationSettings = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<String> getTokenAndRefresh() async {
    String? token = await _firebaseMessaging.getToken();
    if (token == null) {
      throw Exception("FCM Token is null");
    }
    return token;
  }

  static Future<void> storeTokenOnbackend() async {
    try {
      String? jwt = await _storage.read(key: 'backendJwt');
      if (jwt == null || jwt.isEmpty) return;

      String? token = await _firebaseMessaging.getToken();

      if (token != null && token.isNotEmpty) {
        await sendTokenToBackend(jwt, token);
        await storeFCMToken(token);
        await subscribeToTopics();
      }
    } catch (e) {
    }
  }

  static Future<void> getAndRefreshFCMToken() async {
    try {
      String? jwt = await _storage.read(key: 'backendJwt');
      if (jwt == null || jwt.isEmpty) return;

      String? storedToken = await getFCMToken();

      String? currentToken = await _firebaseMessaging.getToken();

      if (currentToken != null && currentToken.isNotEmpty && currentToken != storedToken) {
        await sendTokenToBackend(jwt, currentToken);
        await storeFCMToken(currentToken);
      }

      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        await sendTokenToBackend(jwt, newToken);
        await storeFCMToken(newToken);
      });
    } catch (e) {
    }
  }

  static Future<void> storeFCMToken(String token) async {
    await _storage.write(key: 'fcmToken', value: token);
  }

  static Future<String?> getFCMToken() async {
    return await _storage.read(key: 'fcmToken');
  }

  static Future<void> sendTokenToBackend(String jwt, String token) async {
    try {
      // final appCheckToken = await FirebaseAppCheck.instance.getToken();

      await http.post(
        Uri.parse('${dotenv.env['BACKEND']!}/users/store_fcm_token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
          // 'X-Firebase-AppCheck': appCheckToken ?? '',
        },
        body: jsonEncode({
          'user': {
            'fcm_token': token,
          }
        }),
      );

    } catch (e) {
    }
  }

  static Future<void> subscribeToTopics() async {
    try {
      await _firebaseMessaging.subscribeToTopic('priceUpdates');
      await _firebaseMessaging.subscribeToTopic('campaigns');
    } catch (e) {
      print('Error subscribing to topics: $e');
    }
  }

  static Future<void> listenForForegroundPushNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      try {
        if (message.notification != null) {
          // Create local notification details
          const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
            'push_channel', // Channel ID
            'Push Notifications', // Channel name
            channelDescription: 'This channel is used for push notifications.',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: 'ic_notification',
          );

          const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

          const NotificationDetails platformChannelSpecifics = NotificationDetails(
            android: androidNotificationDetails,
            iOS: iosNotificationDetails,
          );

          await flutterLocalNotificationsPlugin.show(
            0, // Notification ID
            message.notification!.title, // Notification title
            message.notification!.body, // Notification body
            platformChannelSpecifics,
          );
        }
      } catch (e) {
      }
    });
  }
}
