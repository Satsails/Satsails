import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Satsails/handlers/response_handlers.dart';

class Transfer {
  final int id;
  final String transferId;
  final String cpf;
  final double sentAmount;
  final double originalAmount;
  final double mintFees;
  final String paymentId;
  final bool completedTransfer;
  final bool processingStatus;
  final bool failed;
  final bool sentToHotWallet;
  final String receivedTxid;
  final String? sentTxid;
  final String? receipt;
  final int? userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double receivedAmount;
  final String pixKey;

  Transfer({
    required this.id,
    required this.transferId,
    required this.cpf,
    required this.sentAmount,
    required this.originalAmount,
    required this.mintFees,
    required this.processingStatus,
    required this.failed,
    required this.paymentId,
    required this.completedTransfer,
    required this.receivedTxid,
    required this.sentToHotWallet,
    this.sentTxid,
    this.receipt,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.receivedAmount,
    this.pixKey = '',
  });

  factory Transfer.fromMultipleJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['transfer']['id'] ?? 0,
      transferId: json['transfer']['transfer_id'] ?? '',
      sentAmount: (json['transfer']['sent_amount'] != null) ? double.parse(json['transfer']['sent_amount']) : 0.0,
      cpf: json['transfer']['cpf'] ?? '',
      originalAmount: (json['transfer']['original_amount'] != null) ? double.parse(json['transfer']['original_amount']) : 0.0,
      mintFees: (json['transfer']['mint_fees'] != null) ? double.parse(json['transfer']['mint_fees']) : 0.0,
      paymentId: json['transfer']['payment_id'] ?? '',
      completedTransfer: json['transfer']['completed_transfer'],
      receivedTxid: json['transfer']['received_txid'] ?? '',
      sentTxid: json['transfer']['sent_txid'],
      receipt: json['transfer']['receipt'],
      userId: json['transfer']['user_id'],
      receivedAmount: (json['transfer']['amount_received_by_user'] != null) ? double.parse(json['transfer']['amount_received_by_user']) : 0.0,
      createdAt: DateTime.parse(json['transfer']['created_at'] ?? DateTime.now().toIso8601String()).toLocal(),
      updatedAt: DateTime.parse(json['transfer']['updated_at'] ?? DateTime.now().toIso8601String()).toLocal(),
      processingStatus: json['transfer']['processing_status'],
      failed: json['transfer']['failed'],
      sentToHotWallet: json['transfer']['sent_to_hot_wallet'],
      pixKey: json['pix'] ?? '',
    );
  }

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['id'] ?? 0,
      transferId: json['transfer_id'] ?? '',
      cpf: json['cpf'] ?? '',
      sentAmount: (json['sent_amount'] != null) ? double.parse(json['sent_amount']) : 0.0,
      originalAmount: (json['original_amount'] != null) ? double.parse(json['original_amount']) : 0.0,
      mintFees: (json['mint_fees'] != null) ? double.parse(json['mint_fees']) : 0.0,
      paymentId: json['payment_id'] ?? '',
      completedTransfer: json['completed_transfer'],
      receivedTxid: json['received_txid'] ?? '',
      sentTxid: json['sent_txid'],
      receipt: json['receipt'],
      userId: json['user_id'],
      receivedAmount: (json['amount_received_by_user'] != null) ? double.parse(json['amount_received_by_user']) : 0.0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()).toLocal(),
      processingStatus: json['processing_status'],
      sentToHotWallet: json['sent_to_hot_wallet'],
      failed: json['failed'],
    );
  }

  Transfer.empty() : this(
    id: 0,
    transferId: '',
    sentAmount: 0.0,
    originalAmount: 0.0,
    cpf: '',
    mintFees: 0.0,
    paymentId: '',
    completedTransfer: false,
    receivedTxid: '',
    sentTxid: '',
    receipt: '',
    userId: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    receivedAmount: 0.0,
    processingStatus: false,
    failed: false,
    sentToHotWallet: false,
    pixKey: '',
  );
}

class ParsedTransfer {
  final String timestamp;
  final String amount_payed_to_affiliate;

  ParsedTransfer({
    required this.timestamp,
    required this.amount_payed_to_affiliate,
  });

  factory ParsedTransfer.fromJson(Map<String, dynamic> json) {
    return ParsedTransfer(
      timestamp: json['timestamp'],
      amount_payed_to_affiliate: json['amount_payed_to_affiliate'] ?? '0',
    );
  }
}

class TransferService {
  static Future<Result<Transfer>> createTransactionRequest(String cpf, String auth, double valueSetToReceive) async {
    try {
      final response = await http.post(
        Uri.parse('https://4c7f-84-90-103-7.ngrok-free.app/transfers'),
        body: jsonEncode({
          'transfer': {
            'cpf': cpf,
            'value_set_to_receive': valueSetToReceive,
          }
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
        },
      );

      if (response.statusCode == 201) {
        return Result(data: Transfer.fromMultipleJson(jsonDecode(response.body)));
      } else {
        return Result(error: 'Please wait a few minutes and try again');
      }
    } catch (e) {
      return Result(error: 'An error has occurred. Please check your internet connection or contact support');
    }
  }
}

