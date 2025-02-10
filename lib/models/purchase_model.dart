import 'dart:convert';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:Satsails/handlers/response_handlers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'purchase_model.g.dart';

/// **Notifier for managing Purchase transactions**
class PurchaseNotifier extends StateNotifier<List<Purchase>> {
  PurchaseNotifier() : super([]) {
    _loadPurchases();
  }

  Purchase getPurchaseById(int id) {
    return state.firstWhere((purchase) => purchase.id == id, orElse: () => Purchase.empty());
  }

  /// **Loads purchases from Hive & sets up a listener**
  Future<void> _loadPurchases() async {
    final box = await Hive.openBox<Purchase>('purchasesBox');

    // **Listen for real-time updates in Hive**
    box.watch().listen((event) => _updatePurchases());

    // **Initial state update**
    _updatePurchases();
  }

  /// **Updates the provider's state with the latest purchases**
  void _updatePurchases() {
    final box = Hive.box<Purchase>('purchasesBox');
    final purchases = box.values.toList();

    // **Sort purchases by `createdAt` (newest first)**
    purchases.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    state = purchases;
  }

  /// **Merge a single purchase into Hive and update state**
  Future<void> mergePurchase(Purchase serverPurchase) async {
    final box = Hive.box<Purchase>('purchasesBox');

    // Get the existing purchase if it exists
    final existingPurchase = box.get(serverPurchase.id);

    // If no existing purchase, add the new one directly
    if (existingPurchase == null) {
      await box.put(serverPurchase.id, serverPurchase);
      _updatePurchases();
      return;
    }

    // **Merge updated fields** (ensure no data is lost)
    final updatedPurchase = existingPurchase.copyWith(
      transferId: serverPurchase.transferId,
      originalAmount: serverPurchase.originalAmount,
      completedTransfer: serverPurchase.completedTransfer,
      failed: serverPurchase.failed,
      userId: serverPurchase.userId ?? existingPurchase.userId,
      createdAt: existingPurchase.createdAt, // Keep original creation date
      updatedAt: serverPurchase.updatedAt, // Use new updated timestamp
      receivedAmount: serverPurchase.receivedAmount,
      pixKey: serverPurchase.pixKey,
      paymentGateway: serverPurchase.paymentGateway ?? existingPurchase.paymentGateway,
      status: serverPurchase.status ?? existingPurchase.status,
      paymentMethod: serverPurchase.paymentMethod ?? existingPurchase.paymentMethod,
      asset: serverPurchase.asset ?? existingPurchase.asset,
      currency: serverPurchase.currency ?? existingPurchase.currency,
      type: serverPurchase.type ?? existingPurchase.type,
    );

    // If the purchase has **no changes**, skip saving
    if (existingPurchase == updatedPurchase) {
      return;
    }

    // Save the updated purchase
    await box.put(serverPurchase.id, updatedPurchase);

    // Update state
    _updatePurchases();
  }

  /// **Merge a list of purchases, ensuring updates only when necessary**
  Future<void> mergePurchases(List<Purchase> serverPurchases) async {
    final box = Hive.box<Purchase>('purchasesBox');

    for (final serverPurchase in serverPurchases) {
      final existingPurchase = box.get(serverPurchase.id);

      final updatedPurchase = existingPurchase?.copyWith(
        transferId: serverPurchase.transferId,
        originalAmount: serverPurchase.originalAmount,
        completedTransfer: serverPurchase.completedTransfer,
        failed: serverPurchase.failed,
        userId: serverPurchase.userId ?? existingPurchase?.userId,
        createdAt: existingPurchase?.createdAt ?? serverPurchase.createdAt,
        updatedAt: serverPurchase.updatedAt,
        receivedAmount: serverPurchase.receivedAmount,
        pixKey: serverPurchase.pixKey,
        paymentGateway: serverPurchase.paymentGateway ?? existingPurchase?.paymentGateway,
        status: serverPurchase.status ?? existingPurchase?.status,
        paymentMethod: serverPurchase.paymentMethod ?? existingPurchase?.paymentMethod,
        asset: serverPurchase.asset ?? existingPurchase?.asset,
        currency: serverPurchase.currency ?? existingPurchase?.currency,
        type: serverPurchase.type ?? existingPurchase?.type,
      ) ?? serverPurchase;

      // Save only if changes exist
      if (existingPurchase == null || existingPurchase != updatedPurchase) {
        await box.put(serverPurchase.id, updatedPurchase);
      }
    }

    _updatePurchases();
  }
}

/// **Purchase Model**
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
  final String? status;
  @HiveField(19)
  final String? paymentMethod;
  @HiveField(20)
  final String? asset;
  @HiveField(21)
  final String? currency;
  @HiveField(22)
  final String? type;

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
    this.status = 'unknown',
    this.paymentMethod = 'unknown',
    this.asset = 'unknown',
    this.currency = 'unknown',
    this.type = 'unknown',
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
      asset: transfer['asset']?.toString() ?? 'unknown', // Ensure default
      currency: transfer['currency']?.toString() ?? 'unknown', // Ensure default
      type: transfer['type']?.toString() ?? 'unknown', // Ensure default
    );
  }

  /// **Create a copy with updated values**
  Purchase copyWith({
    String? transferId,
    double? originalAmount,
    bool? completedTransfer,
    bool? failed,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? receivedAmount,
    String? pixKey,
    String? paymentGateway,
    String? status,
    String? paymentMethod,
    String? asset,
    String? currency,
    String? type,
  }) {
    return Purchase(
      id: id,
      transferId: transferId ?? this.transferId,
      originalAmount: originalAmount ?? this.originalAmount,
      completedTransfer: completedTransfer ?? this.completedTransfer,
      failed: failed ?? this.failed,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      pixKey: pixKey ?? this.pixKey,
      paymentGateway: paymentGateway ?? this.paymentGateway,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      asset: asset ?? this.asset,
      currency: currency ?? this.currency,
      type: currency ?? this.type,
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
    asset: 'unknown',
    currency: 'unknown',
    type: 'unknown',
  );
}


class PurchaseService {
  /// Creates a new purchase request.
  static Future<Result<Purchase>> createPurchaseRequest(String auth, int amount, String liquidAddress) async {
    try {
      // Get the Firebase App Check token.
      final appCheckToken = await FirebaseAppCheck.instance.getToken();

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
          'X-Firebase-AppCheck': appCheckToken ?? '',
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

  /// Retrieves the list of user purchases.
  static Future<Result<List<Purchase>>> getUserPurchases(String auth) async {
    try {
      final appCheckToken = await FirebaseAppCheck.instance.getToken();

      final uri = Uri.parse(dotenv.env['BACKEND']! + '/users/user_transfers');

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
        List<Purchase> transfers = (jsonResponse['transfer'] as List)
            .map((item) => Purchase.fromJson(item as Map<String, dynamic>))
            .toList();
        return Result(data: transfers);
      } else {
        return Result(error: 'An error has occurred. Please try again later');
      }
    } catch (e) {
      return Result(error: 'An error has occurred. Please try again later');
    }
  }

  /// Gets the amount purchased (transferred) by the user for the day.
  static Future<Result<String>> getAmountPurchased(String auth) async {
    try {
      final appCheckToken = await FirebaseAppCheck.instance.getToken();

      final uri = Uri.parse(dotenv.env['BACKEND']! + '/users/amount_transfered_by_day');

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

  /// Checks the purchase Pix payment state using the transaction ID.
  static Future<Result<bool>> getPurchasePixPaymentState(String transactionId, String auth) async {
    try {
      final appCheckToken = await FirebaseAppCheck.instance.getToken();

      final uri = Uri.parse(dotenv.env['BACKEND']! + '/transfers/check_purchase_state')
          .replace(queryParameters: {
        'transfer[txid]': transactionId,
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



