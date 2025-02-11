import 'dart:convert';

import 'package:Satsails/handlers/response_handlers.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

part 'eulen_transfer_model.g.dart';

class EulenTransferNotifier extends StateNotifier<List<EulenTransfer>> {
  EulenTransferNotifier() : super([]) {
    _loadPurchases();
  }

  EulenTransfer getPurchaseById(int id) {
    return state.firstWhere((purchase) => purchase.id == id, orElse: () => EulenTransfer.empty());
  }

  /// **Loads purchases from Hive & sets up a listener**
  Future<void> _loadPurchases() async {
    final box = await Hive.openBox<EulenTransfer>('eulenTransfersBox');

    // **Listen for real-time updates in Hive**
    box.watch().listen((event) => _updateTransfers());

    // **Initial state update**
    _updateTransfers();
  }

  /// **Updates the provider's state with the latest purchases**
  void _updateTransfers() {
    final box = Hive.box<EulenTransfer>('eulenTransfersBox');
    final purchases = box.values.toList();

    // **Sort purchases by `createdAt` (newest first)**
    purchases.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    state = purchases;
  }

  /// **Merge a single purchase into Hive and update state**
  Future<void> mergeTransfer(EulenTransfer serverPurchase) async {
    final box = Hive.box<EulenTransfer>('eulenTransfersBox');

    // Get the existing purchase if it exists
    final existingPurchase = box.get(serverPurchase.id);

    // If no existing purchase, add the new one directly
    if (existingPurchase == null) {
      await box.put(serverPurchase.id, serverPurchase);
      _updateTransfers();
      return;
    }

    // **Merge updated fields** (ensure no data is lost)
    final updatedPurchase = existingPurchase.copyWith(
      transactionId: serverPurchase.transactionId,
      originalAmount: serverPurchase.originalAmount,
      completed: serverPurchase.completed,
      failed: serverPurchase.failed,
      userId: serverPurchase.userId ?? existingPurchase?.userId,
      createdAt: existingPurchase?.createdAt ?? serverPurchase.createdAt,
      updatedAt: serverPurchase.updatedAt,
      receivedAmount: serverPurchase.receivedAmount,
      pixKey: serverPurchase.pixKey,
      status: serverPurchase.status ?? existingPurchase?.status,
      paymentMethod: serverPurchase.paymentMethod ?? existingPurchase?.paymentMethod,
      asset: serverPurchase.asset ?? existingPurchase?.asset,
      currency: serverPurchase.currency ?? existingPurchase?.currency,
      transactionType: serverPurchase.transactionType,
    );

    // If the purchase has **no changes**, skip saving
    if (existingPurchase == updatedPurchase) {
      return;
    }

    // Save the updated purchase
    await box.put(serverPurchase.id, updatedPurchase);

    // Update state
    _updateTransfers();
  }

  /// **Merge a list of purchases, ensuring updates only when necessary**
  Future<void> mergePurchases(List<EulenTransfer> serverPurchases) async {
    final box = Hive.box<EulenTransfer>('eulenTransfersBox');

    for (final serverPurchase in serverPurchases) {
      final existingPurchase = box.get(serverPurchase.id);

      final updatedPurchase = existingPurchase?.copyWith(
        transactionId: serverPurchase.transactionId,
        originalAmount: serverPurchase.originalAmount,
        completed: serverPurchase.completed,
        failed: serverPurchase.failed,
        userId: serverPurchase.userId ?? existingPurchase?.userId,
        createdAt: existingPurchase?.createdAt ?? serverPurchase.createdAt,
        updatedAt: serverPurchase.updatedAt,
        receivedAmount: serverPurchase.receivedAmount,
        pixKey: serverPurchase.pixKey,
        status: serverPurchase.status ?? existingPurchase?.status,
        paymentMethod: serverPurchase.paymentMethod ?? existingPurchase?.paymentMethod,
        asset: serverPurchase.asset ?? existingPurchase?.asset,
        currency: serverPurchase.currency ?? existingPurchase?.currency,
        transactionType: serverPurchase.transactionType,
      ) ?? serverPurchase;

      // Save only if changes exist
      if (existingPurchase == null || existingPurchase != updatedPurchase) {
        await box.put(serverPurchase.id, updatedPurchase);
      }
    }

    _updateTransfers();
  }
}

@HiveType(typeId: 28)
class EulenTransfer extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String transactionId; // formerly transferId
  @HiveField(2)
  final double originalAmount;
  @HiveField(3)
  final bool completed;
  @HiveField(4)
  final bool failed;
  @HiveField(5)
  final int? userId;
  @HiveField(6)
  final DateTime createdAt;
  @HiveField(7)
  final DateTime updatedAt;
  @HiveField(8)
  final double receivedAmount;
  @HiveField(9)
  final String pixKey;
  @HiveField(10)
  final String? status;
  @HiveField(11)
  final String? paymentMethod;
  @HiveField(12)
  final String? asset;
  @HiveField(13)
  final String? currency;
  @HiveField(14)
  final String transactionType; // e.g., "BUY" or "SELL"
  @HiveField(15)
  final String provider; // e.g. "Eulen"

  EulenTransfer({
    required this.id,
    required this.transactionId,
    required this.originalAmount,
    required this.completed,
    required this.failed,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.receivedAmount,
    this.pixKey = '',
    this.status = 'unknown',
    this.paymentMethod = 'unknown',
    this.asset = 'unknown',
    this.currency = 'unknown',
    this.transactionType = 'BUY',
    this.provider = 'Eulen',
  });

  factory EulenTransfer.fromJson(Map<String, dynamic> json) {
    final data = json['transfer'] ?? json;
    return EulenTransfer(
      id: data['id'] ?? 0,
      transactionId: data['transfer_id'] ?? '',
      originalAmount: double.tryParse(data['original_amount']?.toString() ?? '') ?? 0.0,
      completed: data['completed_transfer'] ?? false,
      failed: data['failed'] ?? false,
      userId: data['user_id'],
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updated_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      receivedAmount: double.tryParse(data['amount_received_by_user']?.toString() ?? '') ?? 0.0,
      pixKey: json['pix']?.toString() ?? '',
      status: data['status']?.toString() ?? 'unknown',
      paymentMethod: data['payment_method']?.toString() ?? 'unknown',
      asset: data['asset']?.toString() ?? 'unknown',
      currency: data['currency']?.toString() ?? 'unknown',
      transactionType: data['type']?.toString() ?? 'BUY',
      provider: 'Eulen',
    );
  }

  EulenTransfer copyWith({
    String? transactionId,
    double? originalAmount,
    bool? completed,
    bool? failed,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? receivedAmount,
    String? pixKey,
    String? status,
    String? paymentMethod,
    String? asset,
    String? currency,
    String? transactionType,
    String? provider,
  }) {
    return EulenTransfer(
      id: this.id,
      transactionId: transactionId ?? this.transactionId,
      originalAmount: originalAmount ?? this.originalAmount,
      completed: completed ?? this.completed,
      failed: failed ?? this.failed,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      pixKey: pixKey ?? this.pixKey,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      asset: asset ?? this.asset,
      currency: currency ?? this.currency,
      transactionType: transactionType ?? this.transactionType,
      provider: provider ?? this.provider,
    );
  }

  static EulenTransfer empty() => EulenTransfer(
    id: 0,
    transactionId: '',
    originalAmount: 0.0,
    completed: false,
    failed: false,
    userId: null,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    receivedAmount: 0.0,
    pixKey: '',
    status: 'unknown',
    paymentMethod: 'unknown',
    asset: 'unknown',
    currency: 'unknown',
    transactionType: 'BUY',
    provider: 'Eulen',
  );
}

class EulenService {
  /// Creates a new Eulen transaction (purchase or sale).
  static Future<Result<EulenTransfer>> createTransaction(String auth, int amount, String liquidAddress, {String transactionType = 'BUY'}) async {
    try {
      final appCheckToken = await FirebaseAppCheck.instance.getToken();
      final response = await http.post(
        Uri.parse(dotenv.env['BACKEND']! + '/eulen_transfers'),
        body: jsonEncode({
          'transfer': {
            'value_set_to_receive': amount,
            'liquid_address': liquidAddress,
            // 'type': transactionType,
            // 'asset': transactionType,
            // 'currency': transactionType,
          }
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
          'X-Firebase-AppCheck': appCheckToken ?? '',
        },
      );

      if (response.statusCode == 201) {
        return Result(data: EulenTransfer.fromJson(jsonDecode(response.body)));
      } else {
        return Result(error: response.body);
      }
    } catch (e) {
      return Result(error: 'An error has occurred. Please try again later');
    }
  }

  /// Retrieves a list of Eulen transactions.
  static Future<Result<List<EulenTransfer>>> getTransfers(String auth) async {
    try {
      final appCheckToken = await FirebaseAppCheck.instance.getToken();
      final uri = Uri.parse(dotenv.env['BACKEND']! + '/eulen_transfers');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
          'X-Firebase-AppCheck': appCheckToken ?? '',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<EulenTransfer> transactions = (jsonResponse['transfer'] as List)
            .map((item) => EulenTransfer.fromJson(item as Map<String, dynamic>))
            .toList();
        return Result(data: transactions);
      } else {
        return Result(error: 'An error has occurred. Please try again later');
      }
    } catch (e) {
      return Result(error: 'An error has occurred. Please try again later');
    }
  }

  /// Gets the amount transferred for the day.
  static Future<Result<String>> getAmountTransferred(String auth) async {
    try {
      final appCheckToken = await FirebaseAppCheck.instance.getToken();
      final uri = Uri.parse(dotenv.env['BACKEND']! + '/eulen_transfers/amount_transfered_by_day');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
          'X-Firebase-AppCheck': appCheckToken ?? '',
        },
      );

      if (response.statusCode == 200) {
        return Result(data: jsonDecode(response.body));
      } else {
        return Result(error: 'An error has occurred. Please try again later');
      }
    } catch (e) {
      return Result(error: 'An error has occurred. Please try again later');
    }
  }

  /// Checks the transaction payment state using the transaction ID.
  static Future<Result<bool>> getTransactionPaymentState(String transactionId, String auth) async {
    try {
      final appCheckToken = await FirebaseAppCheck.instance.getToken();
      final uri = Uri.parse(dotenv.env['BACKEND']! + '/eulen_transfers/check_purchase_state')
          .replace(queryParameters: {'transfer[txid]': transactionId,
      });

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
          'X-Firebase-AppCheck': appCheckToken ?? '',
        },
      );

      if (response.statusCode == 200) {
        return Result(data: jsonDecode(response.body));
      } else {
        return Result(error: 'An error has occurred. Please try again later');
      }
    } catch (e) {
      return Result(error: 'An error has occurred. Please try again later');
    }
  }
}
