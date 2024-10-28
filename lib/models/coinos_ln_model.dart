import 'dart:convert';
import 'dart:math';
import 'package:Satsails/handlers/response_handlers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

class CoinosLn {
  final String token;
  final String username;
  final String password;

  CoinosLn({required this.token, required this.username, this.password = ''});

  CoinosLn copyWith({String? token, String? username, String? password}) {
    return CoinosLn(
      token: token ?? this.token,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}

class CoinosLnModel extends StateNotifier<CoinosLn> {
  CoinosLnModel(super.state);

  Future<void> login(String username, String password) async {
    final result = await CoinosLnService.login(username, password);
    if (result.isSuccess) {
      await _storage.write(key: 'coinosToken', value: result.data);
      await _storage.write(key: 'coinosUsername', value: username);
      await _storage.write(key: 'coinosPassword', value: password);
      state = state.copyWith(token: result.data, username: username, password: password);
    } else {
      throw Exception(result.error ?? 'Login failed');
    }
  }

  String generateSecurePassword(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+[]{}|;:,.<>?';
    final rand = Random.secure();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> register(String username) async {
    final password = generateSecurePassword(16);
    final result = await CoinosLnService.register(username, password);
    if (result.isSuccess) {
      state = state.copyWith(username: username, password: password);
    } else {
      throw Exception('Registration failed');
    }
  }

  Future<String> createInvoice(int amount) async {
    final token = state.token;
    if (token == null || token.isEmpty) {
      throw Exception('Token is missing or invalid');
    }

    final result = await CoinosLnService.createInvoice(token, amount);
    if (result.isSuccess) {
      return result.data!;
    } else {
      throw Exception('Failed to create invoice');
    }
  }

  Future<List<dynamic>?> getInvoices() async {
    final token = state.token;
    if (token == null || token.isEmpty) {
      throw Exception('Token is missing or invalid');
    }

    final result = await CoinosLnService.getInvoices(token);
    if (result.isSuccess) {
      return result.data;
    } else {
      throw Exception('Failed to get invoices');
    }
  }

  Future<void> sendPayment(String address, int amount) async {
    final token = state.token;
    if (token == null || token.isEmpty) {
      throw Exception('Token is missing or invalid');
    }

    final result = await CoinosLnService.sendPayment(token, address, amount);
    if (!result.isSuccess) {
      throw Exception('Failed to send payment');
    }
  }

  Future<List<dynamic>?> getTransactions() async {
    final token = state.token;
    if (token == null || token.isEmpty) {
      throw Exception('Token is missing or invalid');
    }

    final result = await CoinosLnService.getTransactions(token);
    if (result.isSuccess) {
      return result.data;
    } else {
      throw Exception('Failed to get transactions');
    }
  }
}

class CoinosLnService {
  static final String baseUrl = dotenv.env['COINOS_API_URL']!;

  static Future<Result<String>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token'];
        return Result(data: token);
      } else {
        return Result(error: 'Login failed: ${response.body}');
      }
    } catch (e) {
      return Result(error: 'Error logging in: $e');
    }
  }

  static Future<Result<String>> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user': {'username': username, 'password': password}}),
      );
      if (response.statusCode == 200) {
        return Result(data: 'Registration successful');
      } else {
        return Result(error: 'Registration failed: ${response.body}');
      }
    } catch (e) {
      return Result(error: 'Error registering: $e');
    }
  }

  static Future<Result<String>> createInvoice(String token, int amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/invoice'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'invoice': {'amount': amount, 'type': 'lightning'}}),
      );
      if (response.statusCode == 200) {
        return Result(data: jsonDecode(response.body)['hash']);
      } else {
        return Result(error: 'Failed to create invoice: ${response.body}');
      }
    } catch (e) {
      return Result(error: 'Error creating invoice: $e');
    }
  }

  static Future<Result<List<dynamic>>> getInvoices(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/invoices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return Result(data: jsonDecode(response.body));
      } else {
        return Result(error: 'Failed to get invoices: ${response.body}');
      }
    } catch (e) {
      return Result(error: 'Error getting invoices: $e');
    }
  }

  static Future<Result<void>> sendPayment(String token, String address, int amount) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'address': address, 'amount': amount}),
      );
      if (response.statusCode == 200) {
        return Result(data: null);
      } else {
        return Result(error: 'Failed to send payment: ${response.body}');
      }
    } catch (e) {
      return Result(error: 'Error sending payment: $e');
    }
  }

  static Future<Result<List<dynamic>>> getTransactions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return Result(data: jsonDecode(response.body));
      } else {
        return Result(error: 'Failed to get transactions: ${response.body}');
      }
    } catch (e) {
      return Result(error: 'Error getting transactions: $e');
    }
  }
}
