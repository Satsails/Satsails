import 'dart:convert';

import 'package:Satsails/models/breez/lnurl_model.dart';
import 'package:Satsails/notifications/firebase.dart';
import 'package:Satsails/providers/breez_config_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

abstract class MessageSigner {
  Future<String> signMessage(String message);
}

class BreezMessageSigner implements MessageSigner {
  final Ref _ref;

  BreezMessageSigner(this._ref);

  @override
  Future<String> signMessage(String message) async {
    final sdk = await _ref.watch(breezSDKProvider.future);
    if (sdk.instance == null) throw Exception("Breez SDK not initialized");
    final req = SignMessageRequest(message: message);
    final res = sdk.instance!.signMessage(req: req);
    return res.signature;
  }
}

class WebhookRequestBuilder {
  final MessageSigner messageSigner;

  WebhookRequestBuilder(this.messageSigner);

  Future<RegisterLnurlPayRequest> buildRegisterRequest({
    required String webhookUrl,
    String? username,
    String? offer,
  }) async {
    final additionalData = '${_formatOptionalComponent(username)}${_formatOptionalComponent(offer)}';
    final requestData = await _buildSignedRequestData(
      webhookUrl: webhookUrl,
      additionalData: additionalData,
    );
    return RegisterLnurlPayRequest(
      time: requestData.timestamp,
      webhookUrl: webhookUrl,
      signature: requestData.signature,
      username: username,
      offer: offer,
    );
  }

  Future<UnregisterRecoverLnurlPayRequest> buildUnregisterRecoverRequest({
    required String webhookUrl,
  }) async {
    final requestData = await _buildSignedRequestData(webhookUrl: webhookUrl);
    return UnregisterRecoverLnurlPayRequest(
      time: requestData.timestamp,
      webhookUrl: webhookUrl,
      signature: requestData.signature,
    );
  }

  String _formatOptionalComponent(String? component) {
    return (component == null || component.isEmpty) ? '' : '-$component';
  }

  Future<SignedRequestData> _buildSignedRequestData({
    required String webhookUrl,
    String additionalData = '',
  }) async {
    // Create a single, authoritative timestamp.
    final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final message = '$timestamp-$webhookUrl$additionalData';
    final signature = await messageSigner.signMessage(message);
    // Return the timestamp so it can be used in the request body.
    return SignedRequestData(timestamp: timestamp, signature: signature);
  }
}


class WebhookService {
  final Ref _ref;
  String? _cachedToken;
  DateTime? _tokenCacheTime;
  static const Duration _tokenCacheDuration = Duration(hours: 1);

  WebhookService(this._ref);

  Future<String> generateWebhookUrl({bool forceRefresh = false}) async {
    final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
    final token = await _getToken(forceRefresh: forceRefresh);
    final baseUrl = dotenv.env['LNURL_SERVICE_URL'];
    if (baseUrl == null) throw GenerateWebhookUrlException('LNURL_SERVICE_URL not configured.');
    return '$baseUrl/notify-lnurl/api/v1/notify?platform=$platform&token=$token';
  }

  Future<void> register(String webhookUrl) async {
    final sdk = await _ref.watch(breezSDKProvider.future);
    if (sdk.instance == null) throw RegisterWebhookException('Breez SDK not initialized.');
    await sdk.instance!.registerWebhook(webhookUrl: webhookUrl);
  }

  Future<String> _getToken({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedToken != null && _tokenCacheTime != null) {
      if (DateTime.now().difference(_tokenCacheTime!) < _tokenCacheDuration) {
        return _cachedToken!;
      }
    }
    final token = await FirebaseService.getToken();
    await FirebaseService.requestNotificationPermissions();
    if (token == null) throw GenerateWebhookUrlException('Failed to get notification token.');
    _cachedToken = token;
    _tokenCacheTime = DateTime.now();
    return token;
  }
}class LnUrlPayService {
  final String? _baseUrl = dotenv.env['LNURL_SERVICE_URL'];
  String getDomain() => _baseUrl!.replaceFirst('https://', '');

  Future<Lnurl> register({required String pubKey, required RegisterLnurlPayRequest request}) async {
    return _handleRequest(
          () => http.post(
        Uri.parse('$_baseUrl/lnurlpay/$pubKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ),
    );
  }

  Future<Lnurl> recover({required String pubKey, required UnregisterRecoverLnurlPayRequest request}) async {
    return _handleRequest(
          () => http.post(
        Uri.parse('$_baseUrl/lnurlpay/$pubKey/recover'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      ),
    );
  }

  Future<void> unregister({required String pubKey, required UnregisterRecoverLnurlPayRequest request}) async {
    if (_baseUrl == null) throw Exception('Backend URL not configured.');

    final response = await http.delete(
      Uri.parse('$_baseUrl/lnurlpay/$pubKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else {
      throw Exception('Failed to unregister with status ${response.statusCode}: ${response.body}');
    }
  }

  Future<Lnurl> _handleRequest(Future<http.Response> Function() request) async {
    if (_baseUrl == null) throw Exception('Backend URL not configured.');
    final response = await request();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Lnurl.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw WebhookNotFoundException(response.body);
    } else if (response.statusCode == 409) {
      throw UsernameConflictException(response.body);
    } else {
      throw Exception('Failed with status ${response.statusCode}: ${response.body}');
    }
  }
}

