import 'dart:convert';
import 'package:Satsails/models/auth_model.dart';
import 'package:Satsails/models/breez/init.dart';
import 'package:Satsails/models/breez/sdk_instance.dart';
import 'package:Satsails/notifications/breez/job.dart';
import 'package:Satsails/notifications/breez/notification.dart';
import 'package:Satsails/providers/breez_config_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart' as liquid_sdk;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");

  final job = getJobFromMessage(message);
  if (job == null) {
    debugPrint("No job found for the received message.");
    return;
  }

  bool didConnectInHandler = false;

  try {
    debugPrint("Starting background job: ${job.runtimeType}");
    await dotenv.load(fileName: ".env");

    // First, attempt to initialize the native Rust bridge.
    try {
      await FlutterBreezLiquid.init();
      debugPrint("Bridge initialized successfully.");
    } catch (e) {
      // If we get this specific error, it means the main app's isolate
      // already initialized the bridge. We can safely ignore it.
      if (e.toString().contains("Should not initialize flutter_rust_bridge twice")) {
        debugPrint("Bridge already initialized, continuing.");
      } else {
        // If it's any other error, it's a real problem.
        rethrow;
      }
    }

    // Now, we can safely check for the Dart-side SDK instance.
    liquid_sdk.BreezSdkLiquid? sdk = breezSDKLiquid.instance;

    // If the instance is null, we need to connect.
    if (sdk == null) {
      debugPrint("SDK not connected. Connecting...");
      final connectRequest = await getConnectRequestFromStorage();
      await breezSDKLiquid.connect(req: connectRequest);
      sdk = breezSDKLiquid.instance;
      didConnectInHandler = true; // Mark that we started the connection
    } else {
      debugPrint("SDK already connected. Using existing instance.");
    }

    if (sdk != null) {
      await job.start(sdk);
      debugPrint("Background job finished successfully.");
    } else {
      throw Exception("SDK instance was null after attempting to connect.");
    }

  } catch (e) {
    debugPrint("Background job failed: $e");
  } finally {
    if (didConnectInHandler) {
      debugPrint("Disconnecting SDK connection started by handler.");
      breezSDKLiquid.disconnect();
    }
  }
}

Future<ConnectRequest> getConnectRequestFromStorage() async {
  final mnemonic = await AuthModel().getMnemonic();

  if (mnemonic == null) {
    throw Exception("Mnemonic not found for background processing.");
  }

  return await createConnectRequest(mnemonic);
}

class FirebaseService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> initialize() async {
    await NotificationHelper.initialize();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await getAndRefreshFCMToken();
  }

  static Future<void> requestNotificationPermissions() async {
    await FirebaseMessaging.instance.requestPermission();
  }

  static Future<bool> checkNotificationPermissionStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  static Future<String> getToken() async {
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
      }
    } catch (e) {
      debugPrint("Error storing token on backend: $e");
    }
  }

  static Future<void> getAndRefreshFCMToken() async {
    try {
      String? jwt = await _storage.read(key: 'backendJwt');
      if (jwt == null || jwt.isEmpty) return;

      String? storedToken = await _storage.read(key: 'fcmToken');
      String? currentToken = await getToken();

      if (currentToken != null && currentToken.isNotEmpty && currentToken != storedToken) {
        await sendTokenToBackend(jwt, currentToken);
        await storeFCMToken(currentToken);
      }

      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        if (jwt.isNotEmpty) {
          await sendTokenToBackend(jwt, newToken);
          await storeFCMToken(newToken);
        }
      });
    } catch (e) {
      debugPrint("Error refreshing FCM token: $e");
    }
  }

  static Future<void> storeFCMToken(String token) async {
    await _storage.write(key: 'fcmToken', value: token);
  }

  static Future<void> sendTokenToBackend(String jwt, String token) async {
    try {
      await http.post(
        Uri.parse('${dotenv.env['BACKEND']!}/users/store_fcm_token'),
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
    } catch (e) {
      debugPrint("Error sending token to backend: $e");
    }
  }

  static Future<void> subscribeToTopics() async {
    try {
      await _firebaseMessaging.subscribeToTopic('prices');
      await _firebaseMessaging.subscribeToTopic('errors');
    } catch (e) {
      debugPrint('Error subscribing to topics: $e');
    }
  }

  static Future<void> handleForegroundMessage(WidgetRef ref, RemoteMessage message) async {
    try {
      debugPrint('Got a message whilst in the foreground!');

      final job = getJobFromMessage(message);
      if (job != null) {
        debugPrint("Handling job in foreground: ${job.runtimeType}");

        final breezSDK = await ref.read(breezSDKProvider.future);
        final sdkInstance = breezSDK.instance;

        if (sdkInstance != null) {
          await job.start(sdkInstance);
          debugPrint("Foreground job finished successfully.");
        } else {
          debugPrint("Foreground job failed: SDK instance was null.");
        }
      }

      if (message.notification != null) {
        await NotificationHelper.showNotification(
          title: message.notification!.title ?? 'New Message',
          body: message.notification!.body,
        );
      }
    } catch (e) {
      debugPrint("Error handling foreground message: $e");
    }
  }
}