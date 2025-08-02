import 'dart:convert';
import 'dart:math';

import 'package:Satsails/handlers/response_handlers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class Lnurl {
  final String pubkey;
  final String? username;
  final String? webhookUrl;
  final String? offer;
  final DateTime registeredAt;
  final String? lightningAddress;

  Lnurl({
    required this.pubkey,
    this.username,
    this.webhookUrl,
    this.offer,
    required this.registeredAt,
    this.lightningAddress,
  });

  factory Lnurl.fromJson(Map<String, dynamic> json) {
    final data = json['registration'] ?? json;
    return Lnurl(
      pubkey: data['pubkey'] ?? '',
      username: data['username'],
      webhookUrl: data['webhook_url'],
      offer: data['offer'],
      registeredAt:
      DateTime.tryParse(data['registered_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      lightningAddress: data['lightning_address'],
    );
  }
}


class UsernameConflictException implements Exception {
  final String message;
  UsernameConflictException(this.message);

  @override
  String toString() => 'UsernameConflictException: $message';
}

const _lnAddressStorageKey = 'lnurl';
const _storageBoxName = 'lightningBox';

class LnAddressNotifier extends AsyncNotifier<String?> {
  Box get _storageBox => Hive.box(_storageBoxName);

  @override
  Future<String?> build() async {
    return _storageBox.get(_lnAddressStorageKey);
  }

  Future<void> updateLnAddress(String? address) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (address == null || address.isEmpty) {
        await _storageBox.delete(_lnAddressStorageKey);
        return null;
      } else {
        await _storageBox.put(_lnAddressStorageKey, address);
        return address;
      }
    });
  }
}

class RegistrationType {
  static const String newRegistration = 'new';
  static const String update = 'update';
  static const String recovery = 'recovery';
}

class LnurlService {
  final String? _baseUrl = dotenv.env['LNURL_SERVICE_URL'];
  static const int _maxRetries = 3;
  static const Duration _retryBackoff = Duration(milliseconds: 500);

  Future<Result<Lnurl>> performRegistration({
    required String pubkey,
    required String signature,
    required String webhookUrl,
    required String registrationType,
    String? baseUsername,
    String? offer,
  }) async {
    try {
      if (registrationType == RegistrationType.recovery) {
        return await _handleRecovery(
            pubkey: pubkey, signature: signature, webhookUrl: webhookUrl, offer: offer);
      } else {
        return await _registerWithRetries(
            pubkey: pubkey,
            signature: signature,
            webhookUrl: webhookUrl,
            username: baseUsername ?? '',
            offer: offer);
      }
    } catch (e) {
      return Result(error: e.toString());
    }
  }

  Future<Result<Lnurl>> _handleRecovery(
      {required String pubkey,
        required String signature,
        required String webhookUrl,
        String? offer}) async {
    final result =
    await recoverLnurl(pubkey: pubkey, webhookUrl: webhookUrl, signature: signature);

    if (result.isSuccess && result.data?.lightningAddress != null) {
      final recoveredUsername = result.data!.lightningAddress!.split('@').first;
      return _registerWithRetries(
          pubkey: pubkey,
          signature: signature,
          webhookUrl: webhookUrl,
          username: recoveredUsername,
          offer: offer);
    }
    return _registerWithRetries(
        pubkey: pubkey,
        signature: signature,
        webhookUrl: webhookUrl,
        username: '',
        offer: offer);
  }

  Future<Result<Lnurl>> _registerWithRetries(
      {required String pubkey,
        required String signature,
        required String webhookUrl,
        required String username,
        String? offer}) async {
    String currentUsername = username.isEmpty ? _generateRandomUsername() : username;
    Exception? lastException;

    for (int i = 0; i < _maxRetries; i++) {
      try {
        return await _registerLnurlWebhook(
            pubkey: pubkey,
            webhookUrl: webhookUrl,
            signature: signature,
            username: currentUsername,
            offer: offer);
      } on UsernameConflictException catch (e) {
        lastException = e;
        currentUsername = _generateRandomUsername(base: username);
        await Future.delayed(_retryBackoff * (1 << i));
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        await Future.delayed(_retryBackoff * (1 << i));
      }
    }
    throw lastException ?? Exception("Registration failed after $_maxRetries retries.");
  }

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

  String _generateRandomUsername({String base = ''}) {
    final randomPart = (100 + Random().nextInt(900)).toString();
    return base.isEmpty ? "user$randomPart" : "$base$randomPart";
  }

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

  Future<Result<Lnurl>> recoverLnurl(
      {required String pubkey, required String webhookUrl, required String signature}) {
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


Future<String> getPlatform() async {
  if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
  if (defaultTargetPlatform == TargetPlatform.android) return 'android';
  throw Exception('Platform not supported');
}

