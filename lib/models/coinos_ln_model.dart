import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

class CoinosLn {
  final String token;
  final bool registered;

  CoinosLn({required this.token, this.registered = false});

  CoinosLn copyWith({String? token, bool? registered}) {
    return CoinosLn(
      token: token ?? this.token,
      registered: registered ?? this.registered,
    );
  }
}


class CoinosLnModel extends StateNotifier<CoinosLn?> {
  CoinosLnModel() : super(null);

  Future<void> login(String username, String password) async {
    final result = await CoinosLnService.login(username, password);
    if (result != null) {
      final expiryTime = DateTime.now().add(Duration(hours: 1));
      await _storage.write(key: 'authToken', value: result);
      await _storage.write(key: 'tokenExpiry', value: expiryTime.toIso8601String());
      state = CoinosLn(token: result);
    }
  }

  Future<bool> isTokenExpired() async {
    final expiry = await _storage.read(key: 'tokenExpiry');
    if (expiry == null) return true;
    return DateTime.now().isAfter(DateTime.parse(expiry));
  }

  Future<void> register(String username, String password) async {
    await CoinosLnService.register(username, password);
  }

  Future<void> createInvoice(int amount, String memo) async {
    final token = await _storage.read(key: 'authToken');
    if (token != null) {
      await CoinosLnService.createInvoice(token, amount, memo);
    }
  }

  Future<List<dynamic>?> getInvoices() async {
    final token = await _storage.read(key: 'authToken');
    if (token != null) {
      return await CoinosLnService.getInvoices(token);
    }
    return null;
  }

  Future<void> sendPayment(String address, int amount) async {
    final token = await _storage.read(key: 'authToken');
    if (token != null) {
      await CoinosLnService.sendPayment(token, address, amount);
    }
  }

  Future<List<dynamic>?> getTransactions() async {
    final token = await _storage.read(key: 'authToken');
    if (token != null) {
      return await CoinosLnService.getTransactions(token);
    }
    return null;
  }
}

class CoinosLnService {
  static final String baseUrl = dotenv.env['COINOS_API_URL']!;

  static Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['token'];
      }
    } catch (e) {
      print('Error logging in: $e');
    }
    return null;
  }

  static Future<void> register(String username, String password) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
    } catch (e) {
      print('Error registering: $e');
    }
  }

  static Future<void> createInvoice(String token, int amount, String memo) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/invoices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'amount': amount, 'memo': memo}),
      );
    } catch (e) {
      print('Error creating invoice: $e');
    }
  }

  static Future<List<dynamic>?> getInvoices(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/invoices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error getting invoices: $e');
    }
    return null;
  }

  static Future<void> sendPayment(String token, String address, int amount) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'address': address, 'amount': amount}),
      );
    } catch (e) {
      print('Error sending payment: $e');
    }
  }

  static Future<List<dynamic>?> getTransactions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error getting transactions: $e');
    }
    return null;
  }
}
