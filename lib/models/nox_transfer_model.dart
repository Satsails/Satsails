import 'dart:convert';

import 'package:Satsails/handlers/response_handlers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

part 'nox_transfer_model.g.dart';

class NoxTransferNotifier extends StateNotifier<List<NoxTransfer>> {
  NoxTransferNotifier() : super([]) {
    _loadPurchases();
  }

  NoxTransfer getPurchaseById(int id) {
    return state.firstWhere((purchase) => purchase.id == id, orElse: () => NoxTransfer.empty());
  }

  /// **Loads purchases from Hive & sets up a listener**
  Future<void> _loadPurchases() async {
    final box = await Hive.openBox<NoxTransfer>('noxTransfersBox');

    // **Listen for real-time updates in Hive**
    box.watch().listen((event) => _updateTransfers());

    // **Initial state update**
    _updateTransfers();
  }

  /// **Updates the provider's state with the latest purchases**
  void _updateTransfers() {
    final box = Hive.box<NoxTransfer>('noxTransfersBox');
    final purchases = box.values.toList();

    // **Sort purchases by `createdAt` (newest first)**
    purchases.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    state = purchases;
  }

  /// **Merge a single purchase into Hive and update state**
  Future<void> mergeTransfer(NoxTransfer serverData) async {
    final box = Hive.box<NoxTransfer>('noxTransfersBox');

    // Get the existing purchase if it exists
    final existingPurchase = box.get(serverData.id);

    // If no existing purchase, add the new one directly
    if (existingPurchase == null) {
      await box.put(serverData.id, serverData);
      _updateTransfers();
      return;
    }

    // **Merge updated fields** (ensure no data is lost)
    final updatedPurchase = existingPurchase.copyWith(
      transactionId: serverData.transactionId,
      originalAmount: serverData.originalAmount,
      completed: serverData.completed,
      failed: serverData.failed,
      userId: serverData.userId ?? existingPurchase.userId,
      createdAt: existingPurchase.createdAt ?? serverData.createdAt,
      updatedAt: serverData.updatedAt,
      receivedAmount: serverData.receivedAmount,
      status: serverData.status ?? existingPurchase.status,
      paymentMethod: serverData.paymentMethod ?? existingPurchase.paymentMethod,
      to_currency: serverData.to_currency ?? existingPurchase.to_currency,
      from_currency: serverData.from_currency ?? existingPurchase.from_currency,
      transactionType: serverData.transactionType,
      price: serverData.price,
    );

    // If the purchase has **no changes**, skip saving
    if (existingPurchase == updatedPurchase) {
      return;
    }

    // Save the updated purchase
    await box.put(serverData.id, updatedPurchase);

    // Update state
    _updateTransfers();
  }

  /// **Merge a list of purchases, ensuring updates only when necessary**
  Future<void> mergePurchases(List<NoxTransfer> serverDatas) async {
    final box = Hive.box<NoxTransfer>('noxTransfersBox');

    for (final serverData in serverDatas) {
      final existingPurchase = box.get(serverData.id);

      final updatedPurchase = existingPurchase?.copyWith(
        transactionId: serverData.transactionId,
        originalAmount: serverData.originalAmount,
        completed: serverData.completed,
        failed: serverData.failed,
        userId: serverData.userId ?? existingPurchase.userId,
        createdAt: existingPurchase.createdAt ?? serverData.createdAt,
        updatedAt: serverData.updatedAt,
        receivedAmount: serverData.receivedAmount,
        status: serverData.status ?? existingPurchase.status,
        paymentMethod: serverData.paymentMethod ?? existingPurchase.paymentMethod,
        to_currency: serverData.to_currency ?? existingPurchase.to_currency,
        from_currency: serverData.from_currency ?? existingPurchase.from_currency,
        transactionType: serverData.transactionType,
        price: serverData.price,
      ) ?? serverData;

      // Save only if changes exist
      if (existingPurchase == null || existingPurchase != updatedPurchase) {
        await box.put(serverData.id, updatedPurchase);
      }
    }

    _updateTransfers();
  }
}

@HiveType(typeId: 28)
class NoxTransfer extends HiveObject {
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
  @HiveField(10)
  final String? status;
  @HiveField(11)
  final String? paymentMethod;
  @HiveField(12)
  final String? to_currency;
  @HiveField(13)
  final String? from_currency;
  @HiveField(14)
  final String transactionType; // e.g., "BUY" or "SELL"
  @HiveField(15)
  final String provider; // e.g. "Nox"
  @HiveField(16)
  final double price; // e.g. "Nox"

  NoxTransfer({
    required this.id,
    required this.transactionId,
    required this.originalAmount,
    required this.completed,
    required this.failed,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.receivedAmount,
    this.status = 'unknown',
    this.paymentMethod = 'unknown',
    this.to_currency = 'unknown',
    this.from_currency = 'unknown',
    this.transactionType = 'BUY',
    this.provider = 'Nox',
    this.price = 0.0,
  });

  factory NoxTransfer.fromJson(Map<String, dynamic> json) {
    final data = json['transfer'] ?? json;
    return NoxTransfer(
      id: data['id'] ?? 0,
      transactionId: data['transfer_id'] ?? '',
      originalAmount: double.tryParse(data['original_amount']?.toString() ?? '') ?? 0.0,
      completed: data['completed_transfer'] ?? false,
      failed: data['failed'] ?? false,
      userId: data['user_id'],
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updated_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      receivedAmount: double.tryParse(data['amount_received_by_user']?.toString() ?? '') ?? 0.0,
      status: data['status']?.toString() ?? 'unknown',
      paymentMethod: data['payment_method']?.toString() ?? 'unknown',
      to_currency: data['to_currency']?.toString() ?? 'unknown',
      from_currency: data['from_currency']?.toString() ?? 'unknown',
      transactionType: data['type']?.toString() ?? 'BUY',
      provider: 'Nox',
      price: double.tryParse(data['price']?.toString() ?? '') ?? 0.0,
    );
  }

  NoxTransfer copyWith({
    String? transactionId,
    double? originalAmount,
    bool? completed,
    bool? failed,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? receivedAmount,
    String? status,
    String? paymentMethod,
    String? to_currency,
    String? from_currency,
    String? transactionType,
    String? provider,
    double? price,
  }) {
    return NoxTransfer(
      id: id,
      transactionId: transactionId ?? this.transactionId,
      originalAmount: originalAmount ?? this.originalAmount,
      completed: completed ?? this.completed,
      failed: failed ?? this.failed,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      to_currency: to_currency ?? this.to_currency,
      from_currency: from_currency ?? this.from_currency,
      transactionType: transactionType ?? this.transactionType,
      provider: provider ?? this.provider,
      price: price ?? this.price,
    );
  }

  static NoxTransfer empty() => NoxTransfer(
    id: 0,
    transactionId: '',
    originalAmount: 0.0,
    completed: false,
    failed: false,
    userId: null,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    receivedAmount: 0.0,
    status: 'unknown',
    paymentMethod: 'unknown',
    to_currency: 'unknown',
    from_currency: 'unknown',
    transactionType: 'BUY',
    provider: 'Nox',
    price: 0.0,
  );
}

class NoxService {
  /// Creates a new Nox transaction (purchase or sale).
  static Future<Result<String>> createTransaction(String auth, String quoteId, String address, {String transactionType = 'BUY'}) async {
    try {
      // final appCheckToken = await FirebaseAppCheck.instance.getToken();
      final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND']!}/nox_transfers'),
        body: jsonEncode({
          'transfer': {
            'quote_id': quoteId,
            'address': address,
            'type': transactionType,
          }
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
          // 'X-Firebase-AppCheck': appCheckToken ?? '',
        },
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return Result(data: jsonResponse['transfer']);
      } else {
        return Result(error: response.body);
      }
    } catch (e) {
      return Result(error: 'An error has occurred. Please try again later');
    }
  }

  /// Retrieves a list of Nox transactions.
  static Future<Result<List<NoxTransfer>>> getTransfers(String auth) async {
    try {
      // final appCheckToken = await FirebaseAppCheck.instance.getToken();
      final uri = Uri.parse('${dotenv.env['BACKEND']!}/nox_transfers');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
          // 'X-Firebase-AppCheck': appCheckToken ?? '',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<NoxTransfer> transactions = (jsonResponse['transfer'] as List)
            .map((item) => NoxTransfer.fromJson(item as Map<String, dynamic>))
            .toList();
        return Result(data: transactions);
      } else {
        return Result(error: 'An error has occurred. Please try again later');
      }
    } catch (e) {
      return Result(error: 'An error has occurred. Please try again later');
    }
  }

  static Future<Result<NoxTransfer>> getQuote(
      String auth, String fromCurrency, String toCurrency, String amount) async {
    try {
      // final appCheckToken = await FirebaseAppCheck.instance.getToken();
      // Build the URI with query parameters for from_currency, to_currency, and value_set_to_receive.
      final uri = Uri.parse('${dotenv.env['BACKEND']!}/nox_transfers/quote')
          .replace(queryParameters: {
        'from_currency': fromCurrency,
        'to_currency': toCurrency,
        'value_set_to_receive': amount,
      });

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
          // 'X-Firebase-AppCheck': appCheckToken ?? '',
        },
      );

      if (response.statusCode == 200) {
        return Result(data: NoxTransfer.fromJson(jsonDecode(response.body)));
      } else {
        return Result(error: 'An error has occurred. Please try again later');
      }
    } catch (e) {
      return Result(error: 'An error has occurred. Please try again later');
    }
  }

}
