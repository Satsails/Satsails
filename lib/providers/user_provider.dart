import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserArguments {
  final String paymentId;
  final String liquidAddress;

  UserArguments({required this.paymentId, required this.liquidAddress});
}

class Transfer {
  final int id;
  final String name;
  final String transferId;
  final String cpf;
  final double sentAmount;
  final double originalAmount;
  final double mintFees;
  final String paymentId;
  final bool completedTransfer;
  final bool processing;
  final String receivedTxid;
  final String? sentTxid;
  final String? receipt;
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transfer({
    required this.id,
    required this.name,
    required this.transferId,
    required this.cpf,
    required this.sentAmount,
    required this.originalAmount,
    required this.mintFees,
    required this.paymentId,
    required this.completedTransfer,
    required this.processing,
    required this.receivedTxid,
    this.sentTxid,
    this.receipt,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['id'],
      name: json['name'],
      transferId: json['transfer_id'],
      cpf: json['cpf'],
      sentAmount: double.parse(json['sent_amount']),
      originalAmount: double.parse(json['original_amount']),
      mintFees: double.parse(json['mint_fees']),
      paymentId: json['payment_id'],
      completedTransfer: json['completed_transfer'].toString().toLowerCase() == 'true',
      processing: json['processing'].toString().toLowerCase() == 'true',
      receivedTxid: json['received_txid'],
      sentTxid: json['sent_txid'],
      receipt: json['receipt'],
      userId: json['user_id'] != null ? json['user_id'] : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

final createUserProvider = FutureProvider.autoDispose.family<String, UserArguments>((ref, userArguments) async {
  return await UserService().createUserRequest(userArguments.paymentId, userArguments.liquidAddress);
});

final getUserTransactionsProvider = FutureProvider.autoDispose<List<Transfer>>((ref) async {
  final paymentId = ref.read(settingsProvider).pixPaymentCode;
  return await UserService().getUserTransactions(paymentId);
});

final getAmountTransferredProvider = FutureProvider.autoDispose<String>((ref) async {
  final paymentId = ref.read(settingsProvider).pixPaymentCode;
  return await UserService().getAmountTransferred(paymentId);
});

class UserService {
  Future<String> createUserRequest(String paymentId, String liquidAddress) async {
    final response = await http.post(
      Uri.parse('https://www.splitter.satsails.com/users'),
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
    final uri = Uri.parse('https://www.splitter.satsails.com/user_transfers')
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
    final uri = Uri.parse('https://www.splitter.satsails.com/amount_transfered_by_day')
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