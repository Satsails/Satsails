import 'dart:convert';
import 'package:Satsails/handlers/response_handlers.dart';
import 'package:Satsails/models/auth_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'coinos_ln_model.g.dart';

@HiveType(typeId: 27)
class CoinosPayment {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String? hash;

  @HiveField(2)
  final int? amount;

  @HiveField(3)
  final String? uid;

  @HiveField(4)
  final double? rate;

  @HiveField(5)
  final String? currency;

  @HiveField(6)
  final String? memo;

  @HiveField(7)
  final String? ref;

  @HiveField(8)
  final int? tip;

  @HiveField(9)
  final String? type;

  @HiveField(10)
  final bool? confirmed;

  @HiveField(11)
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
      created: json['created'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created'])
          : null,
    );
  }
}

const FlutterSecureStorage _storage = FlutterSecureStorage();

@HiveType(typeId: 28)
class CoinosLn {
  @HiveField(0)
  final String token;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final List<CoinosPayment> transactions;

  @HiveField(4)
  final bool isMigrated;

  CoinosLn({
    required this.token,
    required this.username,
    this.password = '',
    required this.transactions,
    this.isMigrated = false,
  });

  CoinosLn copyWith({
    String? token,
    String? username,
    String? password,
    List<CoinosPayment>? transactions,
    bool? isMigrated,
  }) {
    return CoinosLn(
      token: token ?? this.token,
      username: username ?? this.username,
      password: password ?? this.password,
      transactions: transactions ?? this.transactions,
      isMigrated: isMigrated ?? this.isMigrated,
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

  Future<void> updateTransactions(List<CoinosPayment> transactions) async {
    final box = await Hive.openBox<List<CoinosPayment>>('coinosPayments');
    await box.put('transactions', transactions);
    state = state.copyWith(transactions: transactions);
  }

  Future<void> setMigrated(bool migrated) async {
    final box = await Hive.openBox('coinosLn');
    await box.put('isMigrated', migrated);
    state = state.copyWith(isMigrated: migrated);
  }

  Future<void> register() async {
    final password = await AuthModel().getCoinosPassword();
    final username = await AuthModel().getUsername();
    await CoinosLnService.register(username!, password!);
    login();
  }

  Future<int> getBalance() async {
    final token = state.token;
    if (token.isEmpty) {
      return 0;
    }

    final result = await CoinosLnService.getBalance(token);
    if (result.isSuccess) {
      return result.data!;
    } else {
      throw Exception(result.error ?? 'Failed to fetch balance');
    }
  }

  Future<String> createInvoice(int amount, {String type = 'lightning'}) async {
    final token = state.token;
    if (token.isEmpty) {
      throw 'Token is missing or invalid';
    }

    final result = await CoinosLnService.createInvoice(token, amount, type: type);
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
    if (token.isEmpty) {
      throw 'Token is missing or invalid';
    }

    final result = await CoinosLnService.sendPayment(token, address, amount);
    if (!result.isSuccess) {
      throw result.error ?? 'Failed to send payment';
    }
  }

  Future<void> sendBitcoinPayment(String address, int amount, double fee) async {
    final token = state.token;
    if (token.isEmpty) {
      throw 'Token is missing or invalid';
    }

    final result = await CoinosLnService.sendBitcoinPayment(token, address, amount, fee);
    if (!result.isSuccess) {
      throw result.error ?? 'Failed to send payment';
    }
  }

  Future<void> sendLiquidPayment(String address, int amount, double fee) async {
    final token = state.token;
    if (token.isEmpty) {
      throw 'Token is missing or invalid';
    }

    final result = await CoinosLnService.sendLiquidPayment(token, address, amount, fee);
    if (!result.isSuccess) {
      throw result.error ?? 'Failed to send payment';
    }
  }

  Future<List<CoinosPayment>> getTransactions() async {
    final token = state.token;
    if (token.isEmpty) {
      return [];
    }

    final result = await CoinosLnService.getTransactions(token);
    if (result.isSuccess) {
      return result.data!;
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

  static Future<Result<String>> register(String username,String password) async {
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

  static Future<Result<String>> createInvoice(String token, int amount, {String type = 'lightning'}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/invoice'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'invoice': {'amount': amount, 'type': type}}),
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
        return Result(data: username);
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
        body: jsonEncode({'payreq': address, 'amount': amount}),
      );

      if (response.statusCode == 200) {
        return Result(data: null);
      } else {
        if (response.body.contains('Insufficient funds')) {
          return Result(error: 'Insufficient funds to pay for fees');
        } else {
          return Result(error: response.body);
        }
      }
    } catch (e) {
      return Result(error: 'Error sending payment: $e');
    }
  }

  static Future<Result<void>> sendBitcoinPayment(String token, String address, int amount, double fee) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bitcoin/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'address': address, 'amount': amount, 'subtract': true, 'feeRate': fee}),
      );

      if (response.statusCode == 200) {
        return Result(data: null);
      } else {
        if (response.body.contains('Insufficient funds')) {
          return Result(error: 'Insufficient funds to pay for fees');
        } else {
          return Result(error: response.body);
        }
      }
    } catch (e) {
      return Result(error: 'Error sending payment: $e');
    }
  }

  static Future<Result<void>> sendLiquidPayment(String token, String address, int amount, double fee) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bitcoin/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'address': address, 'amount': amount, 'subtract': true, 'feeRate': fee}),
      );

      if (response.statusCode == 200) {
        return Result(data: null);
      } else {
        if (response.body.contains('Insufficient funds')) {
          return Result(error: 'Insufficient funds to pay for fees');
        } else {
          return Result(error: response.body);
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

  static Future<Result<List<CoinosPayment>>> getTransactions(String token) async {
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
        final List<CoinosPayment> payments = data['payments'].map<CoinosPayment>((json) => CoinosPayment.fromJson(json)).toList();
        return Result(data: payments);
      } else {
        return Result(error: 'Failed to fetch balance and transactions: ${response.body}');
      }
    } catch (e) {
      return Result(error: 'Error fetching balance and transactions: $e');
    }
  }

  static Future<Result<int>> getBalance(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Result(data: data['balance']);
      } else {
        return Result(error: 'Failed to fetch balance: ${response.body}');
      }
    } catch (e) {
      return Result(error: 'Error fetching balance: $e');
    }
  }
}
