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
  @HiveField(3)
  final double originalAmount;
  @HiveField(6)
  final bool completedTransfer;
  @HiveField(8)
  final bool failed;
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
  @HiveField(17)
  final String? paymentGateway;
  @HiveField(18)
  final String? status; // Made nullable
  @HiveField(19)
  final String? paymentMethod; // Made nullable
  @HiveField(20)
  final String? assetPurchased; // Made nullable
  @HiveField(21)
  final String? currencyOfPayment; // Made nullable

  Purchase({
    required this.id,
    required this.transferId,
    required this.originalAmount,
    required this.failed,
    required this.completedTransfer,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.receivedAmount,
    this.pixKey = '',
    this.paymentGateway,
    this.status = 'unknown', // Optional with default
    this.paymentMethod = 'unknown', // Optional with default
    this.assetPurchased = 'unknown', // Optional with default
    this.currencyOfPayment = 'unknown', // Optional with default
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    final transfer = json['transfer'] ?? json;

    return Purchase(
      id: transfer['id'] ?? 0,
      transferId: transfer['transfer_id'] ?? '',
      originalAmount: (transfer['original_amount'] != null)
          ? double.tryParse(transfer['original_amount'].toString()) ?? 0.0
          : 0.0,
      completedTransfer: transfer['completed_transfer'] ?? false,
      userId: transfer['user_id'],
      receivedAmount: (transfer['amount_received_by_user'] != null)
          ? double.tryParse(transfer['amount_received_by_user'].toString()) ?? 0.0
          : 0.0,
      createdAt: DateTime.tryParse(transfer['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      updatedAt: DateTime.tryParse(transfer['updated_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      failed: transfer['failed'] ?? false,
      pixKey: json['pix']?.toString() ?? '',
      paymentGateway: transfer['payment_gateway']?.toString(),
      status: transfer['status']?.toString() ?? 'unknown', // Ensure default
      paymentMethod: transfer['payment_method']?.toString() ?? 'unknown', // Ensure default
      assetPurchased: transfer['asset_purchased']?.toString() ?? 'unknown', // Ensure default
      currencyOfPayment: transfer['currency_of_payment']?.toString() ?? 'unknown', // Ensure default
    );
  }

  Purchase.empty()
      : this(
    id: 0,
    transferId: '',
    originalAmount: 0.0,
    completedTransfer: false,
    userId: null,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    receivedAmount: 0.0,
    failed: false,
    pixKey: '',
    status: 'unknown',
    paymentMethod: 'unknown',
    assetPurchased: 'unknown',
    currencyOfPayment: 'unknown',
  );
}

class PurchaseService {
  static Future<Result<Purchase>> createPurchaseRequest(String auth, int amount, String liquidAddress) async {
    try {
      final response = await http.post(
        Uri.parse(dotenv.env['BACKEND']! + '/transfers'),
        body: jsonEncode({
          'transfer': {
            'value_set_to_receive': amount,
            'liquid_address': liquidAddress,
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
      return Result(error: 'An error has occurred. Please try again later');
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
        return Result(error: 'An error has occurred. Please try again later');
      }
    } catch (e) {
      return Result(
          error: 'An error has occurred. Please try again later');
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
        return Result(error: 'An error has occurred. Please try again later');
      }
    } catch (e) {
      return Result(
          error: 'An error has occurred. Please try again later');
    }
  }

  static Future<Result<bool>> getPurchasePixPaymentState(String transactionId, String auth) async {
    try {
      final uri = Uri.parse(
          dotenv.env['BACKEND']! + '/transfers/check_purchase_state'
      ).replace(queryParameters: {
        'transfer[txid]': transactionId,
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
        return Result(error: 'An error has occurred. Please try again later');
      }
    } catch (e) {
      return Result(
          error: 'An error has occurred. Please try again later');
    }
  }
}

