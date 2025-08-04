
import 'package:Satsails/models/firebase_model.dart';
import 'package:Satsails/services/breez/sdk_instance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LnurlWebhookManager {
  final BreezSDKLiquid _breezSdkLiquid;

  String? _cachedToken;
  DateTime? _tokenCacheTime;
  static const Duration _tokenCacheDuration = Duration(hours: 1);

  LnurlWebhookManager(this._breezSdkLiquid);

  /// Generates a webhook URL by fetching the platform and a fresh notification token.
  Future<String> generateAndCacheWebhookUrl() async {
    final platform = await getPlatform();
    final token = await _getToken();
    final baseUrl = dotenv.env['LNURL_SERVICE_URL'];

    if (baseUrl == null) {
      throw Exception('LNURL_SERVICE_URL not configured.');
    }

    return '$baseUrl/notify-lnurl/api/v1/notify?platform=$platform&token=$token';
  }

  /// Registers the given webhook URL with the Breez SDK.
  Future<void> registerWebhook(String webhookUrl) async {
    final sdk = _breezSdkLiquid.instance;
    if (sdk == null) {
      throw Exception('Breez SDK not initialized.');
    }
    await sdk.registerWebhook(webhookUrl: webhookUrl);
  }

  Future<String> _getToken() async {
    if (_cachedToken != null && _tokenCacheTime != null) {
      final now = DateTime.now();
      if (now.difference(_tokenCacheTime!) < _tokenCacheDuration) {
        return _cachedToken!;
      }
    }

    // Fetch a new token and update permissions
    final token = await FirebaseService.getToken();
    await FirebaseService.requestNotificationPermissions();

    if (token != null) {
      _cachedToken = token;
      _tokenCacheTime = DateTime.now();
      return token;
    }

    throw Exception('Failed to get notification token.');
  }

  /// The main method to handle the full webhook lifecycle:
  /// 1. Get a fresh or cached token to build the URL.
  /// 2. Generate the full webhook URL.
  /// 3. Register the URL with the Breez SDK.
  Future<void> setupAndRegisterWebhook() async {
    final webhookUrl = await generateAndCacheWebhookUrl();
    await registerWebhook(webhookUrl);
  }
}

Future<String> getPlatform() async {
  if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
  if (defaultTargetPlatform == TargetPlatform.android) return 'android';
  throw Exception('Platform not supported');
}