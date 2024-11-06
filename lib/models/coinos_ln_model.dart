import 'dart:convert';
import 'package:Satsails/handlers/response_handlers.dart';
import 'package:Satsails/models/auth_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CoinosPayment {
  final String? id;
  final String? hash;
  final int? amount;
  final String? uid;
  final double? rate;
  final String? currency;
  final String? memo;
  final String? ref;
  final int? tip;
  final String? type;
  final bool? confirmed;
  final DateTime? created;

  CoinosPayment({
    this.id,
    this.hash,
    this.amount,
    this.uid,
    this.rate,
    this.currency,
    this.memo,
    this.ref,
    this.tip,
    this.type,
    this.confirmed,
    this.created,
  });

  factory CoinosPayment.fromJson(Map<String, dynamic> json) {
    return CoinosPayment(
      id: json['id'] as String?,
      hash: json['hash'] as String?,
      amount: json['amount'] as int?,
      uid: json['uid'] as String?,
      rate: (json['rate'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      memo: json['memo'] as String?,
      ref: json['ref'] as String?,
      tip: json['tip'] as int?,
      type: json['type'] as String?,
      confirmed: json['confirmed'] as bool?,
      created: json['created'] != null ? DateTime.fromMillisecondsSinceEpoch(json['created']) : null,
    );
  }
}

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

  Future<void> login() async {
    final password = await AuthModel().getCoinosPassword();
    final username = await AuthModel().getUsername();
    final result = await CoinosLnService.login(username!, password!);
    if (result.isSuccess) {
      await _storage.write(key: 'coinosToken', value: result.data);
      await _storage.write(key: 'coinosUsername', value: username);
      await _storage.write(key: 'coinosPassword', value: password);
      state = state.copyWith(token: result.data, username: username, password: password);
    } else {
      throw Exception(result.error ?? 'Login failed');
    }
  }

  Future<void> register() async {
    final password = await AuthModel().getCoinosPassword();
    final username = await AuthModel().getUsername();
    final result = await CoinosLnService.register(username!, password!);
    if (result.isSuccess) {
      state = state.copyWith(username: username, password: password!);
    } else {
      login();
    }
  }

  Future<String> createInvoice(int amount) async {
    final token = state.token;
    if (token == null || token.isEmpty) {
      throw 'Token is missing or invalid';
    }

    final result = await CoinosLnService.createInvoice(token, amount);
    if (result.isSuccess) {
      return result.data!;
    } else {
      throw 'Failed to create invoice';
    }
  }

  Future<String?> getInvoice(String invoice) async {
    final result = await CoinosLnService.getInvoice(invoice);
    if (result.isSuccess) {
      return result.data;
    } else {
      return null;
    }
  }

  Future<void> sendPayment(String address, int amount) async {
    final token = state.token;
    if (token == null || token.isEmpty) {
      throw 'Token is missing or invalid';
    }

    final result = await CoinosLnService.sendPayment(token, address, amount);
    if (!result.isSuccess) {
      throw result.error ?? 'Failed to send payment';
    }
  }

  Future<Map<String, dynamic>?> getTransactions() async {
    final token = state.token;
    if (token == null || token.isEmpty) {
      return {
        'balance': 0,
        'payments': [],
      };
    }

    final result = await CoinosLnService.getBalanceAndTransactions(token);
    if (result.isSuccess) {
      return result.data;
    } else {
      throw 'Failed to fetch balance and transactions';
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

  static Future<Result<String>> register(String username,
      String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'user': {'username': username, 'password': password}}),
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

  static Future<Result<String>> getInvoice(String hash) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/invoice/$hash'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final username = jsonDecode(response.body)['user']['username'];
        return Result(data: username ?? null);
      } else {
        return Result(error: 'Failed to get invoices: ${response.body}');
      }
    } catch (e) {
      return Result(error: 'Error getting invoices: $e');
    }
  }

  static Future<Result<void>> sendPayment(String token, String address, int amount) async {
    try {
      // final int maxFee = (amount * 0.1).toInt().clamp(1, double.infinity).toInt();

      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'payreq': address, 'amount': amount}),
      );

      if (response.statusCode == 200) {
        return Result(data: null);
      } else {
        if (response.body.contains('Insufficient funds')) {
          return Result(error: 'Insufficient funds to pay for fees');
        } else {
          return Result(error: '${response.body}');
        }
      }
    } catch (e) {
      return Result(error: 'Error sending payment: $e');
    }
  }

  static Future<Result<void>> sendInternalPayment(String token, int amount, String username) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'username': username, 'amount': amount}),
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


  static Future<Result<Map<String, dynamic>>> getBalanceAndTransactions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Convert payments to CoinosPayment instances
        final List<CoinosPayment> payments = data['payments'].map<CoinosPayment>((json) => CoinosPayment.fromJson(json)).toList();

        int balance = 0;
        for (var payment in payments) {
          if (payment.amount != null) {
            balance += payment.amount!;
          }
        }

        return Result(data: {
          'balance': balance,
          'payments': payments,
        });
      } else {
        return Result(error: 'Failed to fetch balance and transactions: ${response.body}');
      }
    } catch (e) {
      return Result(error: 'Error fetching balance and transactions: $e');
    }
  }

}