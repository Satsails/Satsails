import 'package:Satsails/models/transfer_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserArguments {
  final String paymentId;
  final String liquidAddress;

  UserArguments({required this.paymentId, required this.liquidAddress});
}

class UserService {
  Future<String> createUserRequest(String paymentId, String liquidAddress) async {
    final response = await http.post(
      Uri.parse('https://4f7b-177-143-252-140.ngrok-free.app/users'),
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

  Future<List<Transfer>> getUserTransactions(String pixPaymentCode) async {
    final uri = Uri.parse('https://4f7b-177-143-252-140.ngrok-free.app/user_transfers')
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
      List<dynamic> jsonResponse = jsonDecode(response.body);
      List<Transfer> transfers = jsonResponse.map((item) => Transfer.fromJson(item as Map<String, dynamic>)).toList();
      return transfers;
    } else {
      throw Exception('Failed to get user transactions: ${response.body}');
    }
  }

  Future<String> getAmountTransferred(String pixPaymentCode) async {
    final uri = Uri.parse('https://4f7b-177-143-252-140.ngrok-free.app/amount_transfered_by_day')
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
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get amount transferred');
    }
  }
}