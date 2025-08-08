import 'package:Satsails/models/breez/lnurl_model.dart';
import 'package:Satsails/models/breez/lnurl_service.dart';
import 'package:Satsails/models/breez/username_utilities.dart';
import 'package:hive/hive.dart'; // Mocked/Placeholder

class LnUrlRegistrationManager {
  static const int maxRetries = 3;
  static const Duration _retryBackoff = Duration(milliseconds: 500);

  final LnUrlPayService lnAddressService;
  final BreezPreferences breezPreferences;
  final WebhookRequestBuilder requestBuilder;
  final UsernameResolver usernameResolver;
  final WebhookService webhookService;

  LnUrlRegistrationManager({
    required this.lnAddressService,
    required this.breezPreferences,
    required this.requestBuilder,
    required this.usernameResolver,
    required this.webhookService,
  });

  Future<String> setupWebhook(String pubKey, {bool forceRefresh = false}) async {
    final oldWebhookUrl = await breezPreferences.getWebhookUrl();

    final newWebhookUrl = await webhookService.generateWebhookUrl(forceRefresh: forceRefresh);

    if (oldWebhookUrl != null && oldWebhookUrl != newWebhookUrl) {
      try {
        final unregisterRequest = await requestBuilder.buildUnregisterRecoverRequest(webhookUrl: oldWebhookUrl);
        await lnAddressService.unregister(pubKey: pubKey, request: unregisterRequest);
      } catch (e) {
        print('Failed to unregister old webhook, continuing with new registration. Error: $e');
      }
    }

    await webhookService.register(newWebhookUrl);
    await breezPreferences.setWebhookUrl(newWebhookUrl);

    return newWebhookUrl;
  }

  Future<Lnurl> performRegistration({
    required String pubKey,
    required String webhookUrl,
    required String registrationType,
    String? baseUsername,
    String? offer,
  }) async {
    switch (registrationType) {
      case RegistrationType.recovery:
        return _handleRecovery(pubKey: pubKey, webhookUrl: webhookUrl, offer: offer);
      case RegistrationType.newRegistration:
      case RegistrationType.update:
      default:
        final username = await usernameResolver.resolveUsername(baseUsername: baseUsername);
        return _registerWithRetries(
          pubKey: pubKey,
          webhookUrl: webhookUrl,
          username: username,
          offer: offer,
        );
    }
  }

  Future<Lnurl> _handleRecovery({required String pubKey, required String webhookUrl, String? offer}) async {
    final request = await requestBuilder.buildUnregisterRecoverRequest(webhookUrl: webhookUrl);
    final response = await lnAddressService.recover(pubKey: pubKey, request: request);

    final recoveredUsername = response.lightningAddress?.split('@').first;
    if (recoveredUsername != null) {
      // After successful recovery, we must re-register with the recovered username.
      // This ensures the webhook URL is updated on the backend if it has changed (e.g., new device).
      return _attemptRegistration(
        pubKey: pubKey,
        webhookUrl: webhookUrl,
        username: recoveredUsername,
        offer: offer,
      );
    }
    throw Exception("Recovery failed to return a lightning address.");
  }

  Future<Lnurl> _registerWithRetries({
    required String pubKey,
    required String webhookUrl,
    required String username,
    String? offer,
  }) async {
    try {
      return await _attemptRegistration(
        pubKey: pubKey,
        webhookUrl: webhookUrl,
        username: username,
        offer: offer,
      );
    } on UsernameConflictException {
      rethrow;
    }
  }

  Future<Lnurl> _attemptRegistration({
    required String pubKey,
    required String webhookUrl,
    required String username,
    String? offer,
  }) async {
    final request = await requestBuilder.buildRegisterRequest(
      webhookUrl: webhookUrl,
      username: username,
      offer: offer,
    );
    final response = await lnAddressService.register(pubKey: pubKey, request: request);
    // Persist successful username
    await breezPreferences.setLnAddressUsername(username);
    await breezPreferences.setLnUrlWebhookRegistered();
    return response;
  }
}

class BreezPreferences {
  static const _boxName = 'breez_prefs';
  static const _lnAddressKey = 'ln_address';
  static const _lnUsernameKey = 'ln_username';
  static const _webhookUrlKey = 'webhook_url';
  static const _isRegisteredKey = 'is_webhook_registered';

  Future<Box> get _box async => await Hive.openBox(_boxName);

  Future<String?> getLnAddress() async => (await _box).get(_lnAddressKey);
  Future<void> setLnAddress(String? address) async => (await _box).put(_lnAddressKey, address);

  Future<String?> getLnAddressUsername() async => (await _box).get(_lnUsernameKey);
  Future<void> setLnAddressUsername(String name) async => (await _box).put(_lnUsernameKey, name);

  Future<String?> getWebhookUrl() async => (await _box).get(_webhookUrlKey);
  Future<void> setWebhookUrl(String url) async => (await _box).put(_webhookUrlKey, url);

  Future<bool> isLnUrlWebhookRegistered() async => (await _box).get(_isRegisteredKey) ?? false;
  Future<void> setLnUrlWebhookRegistered() async => (await _box).put(_isRegisteredKey, true);
}

class NotificationPermissionException implements Exception {
  final String message;
  NotificationPermissionException(this.message);

  @override
  String toString() => message;
}
