import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirebaseService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> storeTokenOnbackend() async {
    try {
      String? jwt = await _storage.read(key: 'backendJwt');
      if (jwt == null || jwt.isEmpty) return;

      String? token = await _firebaseMessaging.getToken();

      if (token != null && token.isNotEmpty) {
        await sendTokenToBackend(jwt, token);
        await storeFCMToken(token);
      }
    } catch (e) {
      print('Error in FCM token management: $e');
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
      print('Error in FCM token management: $e');
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
      final response = await http.post(
        Uri.parse(dotenv.env['BACKEND']! + '/users/store_fcm_token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({
          'user': {
            'fcm_token': token,
          }
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to send FCM token to backend: ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM token to backend: $e');
    }
  }
}
