import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationType {
  // Keys for data within the push notification payload
  static const String type = 'notification_type';
  static const String payload = 'notification_payload';

  // Specific notification types from the Breez service
  static const String invoiceRequest = 'invoice_request';
  static const String lnurlPayInfo = 'lnurlpay_info';
  static const String lnurlPayInvoice = 'lnurlpay_invoice';
  static const String lnurlPayVerify = 'lnurlpay_verify';
  static const String swapUpdated = 'swap_updated';
}

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String replaceableChannelId = 'replaceable_channel';
  static const String replaceableChannelName = 'Payment Status';
  static const String replaceableChannelDescription = 'Notifications for in-progress payment events.';

  static const String dismissibleChannelId = 'dismissible_channel';
  static const String dismissibleChannelName = 'Completed Payments';
  static const String dismissibleChannelDescription = 'Notifications for completed or failed payments.';

  static const int _replaceableNotificationId = 1001;

  /// Initializes the notification plugin and creates the necessary Android channels.
  /// Call this once at app startup.
  static Future<void> initialize() async {
    // Ensure you have 'ic_notification.png' in android/app/src/main/res/drawable
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_notification');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await _createNotificationChannels();
  }

  static Future<void> _createNotificationChannels() async {
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    final replaceableChannel = const AndroidNotificationChannel(
      replaceableChannelId,
      replaceableChannelName,
      description: replaceableChannelDescription,
      importance: Importance.defaultImportance, // Less intrusive for status updates
    );

    final dismissibleChannel = const AndroidNotificationChannel(
      dismissibleChannelId,
      dismissibleChannelName,
      description: dismissibleChannelDescription,
      importance: Importance.high, // More intrusive for important results
    );

    await androidImplementation?.createNotificationChannel(replaceableChannel);
    await androidImplementation?.createNotificationChannel(dismissibleChannel);
  }

  /// Displays a notification using a specific channel.
  static Future<void> showNotification({
    required String title,
    String? body,
    String channelId = dismissibleChannelId,
  }) async {
    final notificationId = channelId == replaceableChannelId
        ? _replaceableNotificationId
        : DateTime.now().millisecondsSinceEpoch.remainder(100000);

    final platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelId == replaceableChannelId ? replaceableChannelName : dismissibleChannelName,
        channelDescription: channelId == replaceableChannelId ? replaceableChannelDescription : dismissibleChannelDescription,
        importance: channelId == dismissibleChannelId ? Importance.high : Importance.defaultImportance,
        priority: channelId == dismissibleChannelId ? Priority.high : Priority.defaultPriority,
        color: Colors.orange,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // A short delay helps ensure the notification persists after a background task completes.
    await Future.delayed(const Duration(milliseconds: 200));
    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}