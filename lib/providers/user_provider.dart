import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserArguments {
  final String paymentId;
  final String liquidAddress;

  UserArguments({required this.paymentId, required this.liquidAddress});
}

final createUserProvider = FutureProvider.autoDispose.family<String, UserArguments>((ref, userArguments) async {
  return await CreateUserService().createUserRequest(userArguments.paymentId, userArguments.liquidAddress);
});

final getUserTransactionsProvider = FutureProvider.autoDispose<String>((ref) async {
  final paymentId = ref.read(settingsProvider).pixPaymentCode;
  return await CreateUserService().getUserTransactions(paymentId);
});

class CreateUserService {
  Future<String> createUserRequest(String paymentId, String liquidAddress) async {
    final response = await http.post(
      Uri.parse('https://5aae-109-50-157-141.ngrok-free.app/users'),
      body: jsonEncode({
        'user': {
          'payment_id': paymentId,
          'liquid_address': liquidAddress,
        }
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return 'Wallet unique id created successfully';
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  Future<String> getUserTransactions(String pixPaymentCode) async {
    final uri = Uri.parse('https://5aae-109-50-157-141.ngrok-free.app/user_transfers')
        .replace(queryParameters: {
      'payment_id': pixPaymentCode,
    });
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to get user transactions: ${response.body}');
    }
  }
}
