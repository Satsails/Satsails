import 'dart:convert';

import 'package:Satsails/handlers/response_handlers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

part 'lnurl_model.g.dart';

class LnurlNotifier extends StateNotifier<List<Lnurl>> {
  LnurlNotifier() : super([]) {
    _loadLnurls();
  }

  Future<void> _loadLnurls() async {
    // Renamed Hive box
    final box = await Hive.openBox<Lnurl>('lnurlsBox');
    box.watch().listen((event) => _updateState());
    _updateState();
  }

  void _updateState() {
    final box = Hive.box<Lnurl>('lnurlsBox');
    final lnurls = box.values.toList();
    // Sort by most recent
    lnurls.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
    state = lnurls;
  }

  Future<void> addOrUpdateLnurl(Lnurl lnurl) async {
    final box = Hive.box<Lnurl>('lnurlsBox');
    // Use pubkey as the unique key
    await box.put(lnurl.pubkey, lnurl);
    _updateState();
  }
}

@HiveType(typeId: 31)
class Lnurl extends HiveObject {
  @HiveField(0)
  final String pubkey;

  @HiveField(1)
  final String? username;

  @HiveField(2)
  final String? webhookUrl;

  @HiveField(3)
  final String? offer;

  @HiveField(4)
  final DateTime registeredAt;

  Lnurl({
    required this.pubkey,
    this.username,
    this.webhookUrl,
    this.offer,
    required this.registeredAt,
  });

  factory Lnurl.fromJson(Map<String, dynamic> json) {
    final data = json['registration'] ?? json;
    return Lnurl(
      pubkey: data['pubkey'] ?? '',
      username: data['username'],
      webhookUrl: data['webhook_url'],
      offer: data['offer'],
      registeredAt: DateTime.tryParse(data['registered_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
    );
  }

  Lnurl copyWith({
    String? pubkey,
    String? username,
    String? webhookUrl,
    String? offer,
    DateTime? registeredAt,
  }) {
    return Lnurl(
      pubkey: pubkey ?? this.pubkey,
      username: username ?? this.username,
      webhookUrl: webhookUrl ?? this.webhookUrl,
      offer: offer ?? this.offer,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }
}

class LnurlService {
  final String? _baseUrl = dotenv.env['BACKEND'];

  Future<Result<Lnurl>> _handleRequest(
      Future<http.Response> Function() request,
      ) async {
    if (_baseUrl == null) {
      return Result(error: 'Backend URL not configured.');
    }
    try {
      final response = await request();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final lnurl = Lnurl.fromJson(jsonDecode(response.body));
        return Result(data: lnurl);
      } else {
        return Result(error: 'Failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      return Result(error: 'An error has occurred. Please try again later.');
    }
  }

  Future<Result<Lnurl>> registerLnurlWebhook({
    required String pubkey,
    required String webhookUrl,
    required String signature,
    String? username,
    String? offer,
  }) async {
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

  Future<Result<Lnurl>> unregisterLnurlWebhook({
    required String pubkey,
    required String webhookUrl,
    required String signature,
  }) async {
    return _handleRequest(() => http.delete(
      Uri.parse('$_baseUrl/lnurlpay/$pubkey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'webhook_url': webhookUrl,
        'signature': signature,
      }),
    ));
  }

  Future<Result<Lnurl>> recoverLnurl({
    required String pubkey,
    required String webhookUrl,
    required String signature,
  }) async {
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

  Future<Result<Lnurl>> registerBolt12Offer({
    required String pubkey,
    required String username,
    required String offer,
    required String signature,
  }) async {
    return _handleRequest(() => http.post(
      Uri.parse('$_baseUrl/bolt12offer/$pubkey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'username': username,
        'offer': offer,
        'signature': signature,
      }),
    ));
  }

  Future<Result<Lnurl>> unregisterBolt12Offer({
    required String pubkey,
    required String offer,
    required String signature,
  }) async {
    return _handleRequest(() => http.delete(
      Uri.parse('$_baseUrl/bolt12offer/$pubkey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'offer': offer,
        'signature': signature,
      }),
    ));
  }

  Future<Result<Lnurl>> recoverBolt12Offer({
    required String pubkey,
    required String offer,
    required String signature,
  }) async {
    return _handleRequest(() => http.post(
      Uri.parse('$_baseUrl/bolt12offer/$pubkey/recover'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'time': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'offer': offer,
        'signature': signature,
      }),
    ));
  }
}

// Renamed Riverpod Providers
final lnurlNotifierProvider = StateNotifierProvider<LnurlNotifier, List<Lnurl>>(
      (ref) => LnurlNotifier(),
);

final lnurlServiceProvider = Provider<LnurlService>((ref) {
  return LnurlService();
});