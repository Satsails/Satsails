// registration_manager.dart
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

  Future<String> setupWebhook(String pubKey) async {
    final webhookUrl = await webhookService.generateWebhookUrl();
    // In a real app, you might unregister an old webhook here
    await webhookService.register(webhookUrl);
    await breezPreferences.setWebhookUrl(webhookUrl);
    return webhookUrl;
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
        if (username == null) throw Exception("Username could not be resolved.");
        return _registerWithRetries(
          pubKey: pubKey,
          webhookUrl: webhookUrl,
          username: username,
          offer: offer,
        );
    }
  }

  Future<Lnurl> _handleRecovery({required String pubKey, required String webhookUrl, String? offer}) async {
    try {
      final request = await requestBuilder.buildUnregisterRecoverRequest(webhookUrl: webhookUrl);
      final response = await lnAddressService.recover(pubKey: pubKey, request: request);

      // If recovery is successful, transfer ownership
      final recoveredUsername = response.lightningAddress?.split('@').first;
      if (recoveredUsername != null) {
        return _attemptRegistration(
          pubKey: pubKey,
          webhookUrl: webhookUrl,
          username: recoveredUsername,
          offer: offer,
        );
      }
      throw Exception("Recovery failed to return a lightning address.");
    } on WebhookNotFoundException {
      // If not found, treat as a new registration
      final username = await usernameResolver.resolveUsername();
      if (username == null) throw Exception("Username could not be resolved for new registration.");
      return _registerWithRetries(pubKey: pubKey, webhookUrl: webhookUrl, username: username, offer: offer);
    }
  }

  Future<Lnurl> _registerWithRetries({
    required String pubKey,
    required String webhookUrl,
    required String username,
    String? offer,
  }) async {
    String currentUsername = username;
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await _attemptRegistration(
          pubKey: pubKey,
          webhookUrl: webhookUrl,
          username: currentUsername,
          offer: offer,
        );
      } on UsernameConflictException {
        if (i == maxRetries - 1) throw MaxRetriesExceededException();
        currentUsername = UsernameGenerator.generateUsername(username, i + 1);
        await Future.delayed(_retryBackoff * (1 << i));
      }
    }
    throw MaxRetriesExceededException();
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
