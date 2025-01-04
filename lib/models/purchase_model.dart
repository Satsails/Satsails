import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:Satsails/handlers/response_handlers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'purchase_model.g.dart';

class PurchaseNotifier extends StateNotifier<List<Purchase>> {
  PurchaseNotifier(List<Purchase> initialPurchases) : super(initialPurchases);

  Future<void> addPurchase(Purchase purchase) async {
    state = [...state, purchase];
    await _updateHive();
  }

  Future<void> setPurchases(List<Purchase> purchases) async {
    state = purchases;
    await _updateHive();
  }

  Purchase getPurchaseById(int id) {
    return state.firstWhere((purchase) => purchase.id == id, orElse: () => Purchase.empty());
  }

  Future<void> _updateHive() async {
    final purchaseBox = await Hive.openBox<Purchase>('purchasesBox');
    await purchaseBox.clear();
    await purchaseBox.addAll(state);
  }
}
@HiveType(typeId: 28)
class Purchase extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String transferId;
  @HiveField(2)
  final double sentAmount;
  @HiveField(3)
  final double originalAmount;
  @HiveField(4)
  final double mintFees;
  @HiveField(5)
  final String paymentId;
  @HiveField(6)
  final bool completedTransfer;
  @HiveField(7)
  final bool processingStatus;
  @HiveField(8)
  final bool failed;
  @HiveField(9)
  final bool sentToHotWallet;
  @HiveField(10)
  final String receivedTxid;
  @HiveField(11)
  final String? sentTxid;
  @HiveField(12)
  final int? userId;
  @HiveField(13)
  final DateTime createdAt;
  @HiveField(14)
  final DateTime updatedAt;
  @HiveField(15)
  final double receivedAmount;
  @HiveField(16)
  final String pixKey;

  Purchase({
    required this.id,
    required this.transferId,
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
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.receivedAmount,
    this.pixKey = '',
  });

  factory Purchase.fromMultipleJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['transfer']['id'] ?? 0,
      transferId: json['transfer']['transfer_id'] ?? '',
      sentAmount: (json['transfer']['sent_amount'] != null) ? double.parse(json['transfer']['sent_amount']) : 0.0,
      originalAmount: (json['transfer']['original_amount'] != null) ? double.parse(json['transfer']['original_amount']) : 0.0,
      mintFees: (json['transfer']['mint_fees'] != null) ? double.parse(json['transfer']['mint_fees']) : 0.0,
      paymentId: json['transfer']['payment_id'] ?? '',
      completedTransfer: json['transfer']['completed_transfer'] ?? false,
      receivedTxid: json['transfer']['received_txid'] ?? '',
      sentTxid: json['transfer']['sent_txid'],
      userId: json['transfer']['user_id'],
      receivedAmount: (json['transfer']['amount_received_by_user'] != null) ? double.parse(json['transfer']['amount_received_by_user']) : 0.0,
      createdAt: DateTime.parse(json['transfer']['created_at'] ?? DateTime.now().toIso8601String()).toLocal(),
      updatedAt: DateTime.parse(json['transfer']['updated_at'] ?? DateTime.now().toIso8601String()).toLocal(),
      processingStatus: json['transfer']['processing_status'] ?? false,
      failed: json['transfer']['failed'] ?? false,
      sentToHotWallet: json['transfer']['sent_to_hot_wallet'] ?? false,
      pixKey: json['pix'] ?? '',
    );
  }

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] ?? 0,
      transferId: json['transfer_id'] ?? '',
      sentAmount: (json['sent_amount'] != null) ? double.parse(json['sent_amount']) : 0.0,
      originalAmount: (json['original_amount'] != null) ? double.parse(json['original_amount']) : 0.0,
      mintFees: (json['mint_fees'] != null) ? double.parse(json['mint_fees']) : 0.0,
      paymentId: json['payment_id'] ?? '',
      completedTransfer: json['completed_transfer'] ?? false,
      receivedTxid: json['received_txid'] ?? '',
      sentTxid: json['sent_txid'],
      userId: json['user_id'],
      receivedAmount: (json['amount_received_by_user'] != null) ? double.parse(json['amount_received_by_user']) : 0.0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()).toLocal(),
      processingStatus: json['processing_status'] ?? false,
      failed: json['failed'] ?? false,
      sentToHotWallet: json['sent_to_hot_wallet'] ?? false,
      pixKey: json['pix'] ?? '',
    );
  }

  Purchase.empty() : this(
    id: 0,
    transferId: '',
    sentAmount: 0.0,
    originalAmount: 0.0,
    mintFees: 0.0,
    paymentId: '',
    completedTransfer: false,
    receivedTxid: '',
    sentTxid: null,
    userId: null,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    receivedAmount: 0.0,
    processingStatus: false,
    failed: false,
    sentToHotWallet: false,
    pixKey: '',
  );
}

class PurchaseService {
  static Future<Result<Purchase>> createPurchaseRequest(String auth, int amount) async {
    try {
      final response = await http.post(
        Uri.parse(dotenv.env['BACKEND']! + '/transfers'),
        body: jsonEncode({
          'transfer': {
            'value_set_to_receive': amount,
          }
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
        },
      );

      if (response.statusCode == 201) {
        return Result(data: Purchase.fromJson(jsonDecode(response.body)));
      } else {
        return Result(error: response.body);
      }
    } catch (e) {
      return Result(error: 'An error has occurred. Please check your internet connection or contact support');
    }
  }

  static Future<Result<List<Purchase>>> getUserPurchases(String pixPaymentCode, String auth) async {
    try {
      final uri = Uri.parse(
          dotenv.env['BACKEND']! + '/users/user_transfers').replace(queryParameters: {'payment_id': pixPaymentCode,});

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<Purchase> transfers = jsonResponse['transfer'].map((item) => Purchase.fromJson(item as Map<String, dynamic>)).toList().cast<Purchase>();
        return Result(data: transfers);
      } else {
        return Result(
            error: 'Failed to get user transactions: ${response.body}');
      }
    } catch (e) {
      return Result(
          error: 'An error has occurred. Please check your internet connection or contact support');
    }
  }

  static Future<Result<String>> getAmountPurchased(String pixPaymentCode, String auth) async {
    try {
      final uri = Uri.parse(
          dotenv.env['BACKEND']! + '/users/amount_transfered_by_day')
          .replace(queryParameters: {
        'payment_id': pixPaymentCode,
      });

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
        },
      );

      if (response.statusCode == 200) {
        return Result(data: jsonDecode(response.body));
      } else {
        return Result(error: 'Failed to get amount transferred');
      }
    } catch (e) {
      return Result(
          error: 'An error has occurred. Please check your internet connection or contact support');
    }
  }
}

