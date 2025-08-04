import 'dart:convert';
import 'dart:math';

import 'package:Satsails/handlers/response_handlers.dart';
import 'package:Satsails/models/breez/lnurl_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// A service to interact with the LNURL-pay backend for registration, recovery,
/// and unregistration of Lightning Addresses.
class LnurlService {
  final String? _baseUrl = dotenv.env['LNURL_SERVICE_URL'];
  static const int _maxRetries = 3;
  static const Duration _retryBackoff = Duration(milliseconds: 500);

  /// Determines the type of registration based on whether recovery is requested or if a username is provided.
  RegistrationType determineRegistrationType({
    required bool isRecover,
    String? username,
  }) {
    if (isRecover) {
      return RegistrationType.recovery;
    }
    return username != null && username.isNotEmpty
        ? RegistrationType.update
        : RegistrationType.newRegistration;
  }

  /// The main entry point to perform a registration or recovery flow.
  /// This method orchestrates the correct API call based on the provided registrationType.
  Future<Result<Lnurl>> performRegistration({
    required String pubkey,
    required String signature,
    required String webhookUrl,
    required RegistrationType registrationType,
    String? username,
    String? offer,
  }) async {
    try {
      // Recovery is now a single step handled by the provider.
      // This method now only handles registration, updates, and ownership transfers.
      if (username == null || username.isEmpty) {
        return Result(error: 'Username is required for new registration and updates.');
      }
      return await _registerWithRetries(
          pubkey: pubkey,
          signature: signature,
          webhookUrl: webhookUrl,
          username: username,
          offer: offer);
    } catch (e) {
      return Result(error: e.toString());
    }
  }

  /// Attempts to register a webhook with retries for transient errors.
  /// Note: The handling of UsernameConflictException is now done at a higher level
  /// in the provider, where it can generate a new username and retry.
  Future<Result<Lnurl>> _registerWithRetries(
      {required String pubkey,
        required String signature,
        required String webhookUrl,
        required String username,
        String? offer}) async {
    Exception? lastException;
    for (int i = 0; i < _maxRetries; i++) {
      try {
        return await _registerLnurlWebhook(
            pubkey: pubkey,
            signature: signature,
            webhookUrl: webhookUrl,
            username: username,
            offer: offer);
      } on UsernameConflictException catch (e) {
        // We re-throw a UsernameConflictException immediately because it's a specific
        // error that the caller needs to handle by changing the username.
        throw e;
      } catch (e) {
        // For other exceptions, we retry with exponential backoff.
        lastException = e is Exception ? e : Exception(e.toString());
        await Future.delayed(_retryBackoff * (1 << i));
      }
    }
    throw lastException ?? Exception("Registration failed after $_maxRetries retries.");
  }

  /// Handles the HTTP request and response for backend calls.
  Future<Result<Lnurl>> _handleRequest(Future<http.Response> Function() request) async {
    if (_baseUrl == null) return Result(error: 'Backend URL not configured.');
    try {
      final response = await request();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Result(data: Lnurl.fromJson(jsonDecode(response.body)));
      } else if (response.statusCode == 409) {
        throw UsernameConflictException(response.body);
      } else {
        return Result(error: 'Failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      if (e is UsernameConflictException) rethrow;
      return Result(error: 'An error has occurred: ${e.toString()}');
    }
  }

  /// Generates a random username suffix.
  String generateRandomUsername({String base = ''}) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final randomSuffix = String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
    return base.isEmpty ? "user$randomSuffix" : "$base$randomSuffix";
  }

  /// Constructs the message to be signed. The message structure changes based on
  /// whether a username and offer are included.
  String constructSignedMessage({
    required int time,
    required String webhookUrl,
    String? username,
    String? offer,
  }) {
    final parts = <String>[
      time.toString(),
      webhookUrl,
    ];

    if (username != null && username.isNotEmpty) {
      parts.add(username);
      if (offer != null && offer.isNotEmpty) {
        parts.add(offer);
      }
    }

    return parts.join('-');
  }

  /// Makes the API call to register a new LNURL webhook.
  Future<Result<Lnurl>> _registerLnurlWebhook(
      {required String pubkey,
        required String webhookUrl,
        required String signature,
        String? username,
        String? offer}) {
    return _handleRequest(() => http.post(
      Uri.parse('$_baseUrl/lnurlpay/$pubkey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'webhook_url': webhookUrl,
        'username': username,
        'offer': offer,
        'signature': signature,
      }),
    ));
  }

  /// Makes the API call to recover an existing LNURL.
  Future<Result<Lnurl>> recoverLnurl({required String pubkey, required String webhookUrl, required String signature}) {
    return _handleRequest(() => http.post(
      Uri.parse('$_baseUrl/lnurlpay/$pubkey/recover'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'webhook_url': webhookUrl,
        'signature': signature,
      }),
    ));
  }
}

class SignatureParams {
  const SignatureParams({
    required this.time,
    required this.webhookUrl,
    this.username,
    this.offer,
  });

  final int time;
  final String webhookUrl;
  final String? username;
  final String? offer;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SignatureParams &&
        other.time == time &&
        other.webhookUrl == webhookUrl &&
        other.username == username &&
        other.offer == offer;
  }

  @override
  int get hashCode => Object.hash(time, webhookUrl, username, offer);
}
