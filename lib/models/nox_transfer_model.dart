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

  Future<void> _loadPurchases() async {
    final box = await Hive.openBox<NoxTransfer>('noxTransfersBox');
    box.watch().listen((event) => _updateTransfers());
    _updateTransfers();
  }

  void _updateTransfers() {
    final box = Hive.box<NoxTransfer>('noxTransfersBox');
    final purchases = box.values.toList();
    purchases.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = purchases;
  }

  Future<void> mergeTransfer(NoxTransfer serverData) async {
    final box = Hive.box<NoxTransfer>('noxTransfersBox');
    final existingPurchase = box.get(serverData.id);

    if (existingPurchase == null) {
      await box.put(serverData.id, serverData);
      _updateTransfers();
      return;
    }

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
      cashback: serverData.cashback,
      cashbackPayed: serverData.cashbackPayed,
    );

    if (existingPurchase == updatedPurchase) {
      return;
    }

    await box.put(serverData.id, updatedPurchase);
    _updateTransfers();
  }

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
        cashback: serverData.cashback,
        cashbackPayed: serverData.cashbackPayed,
      ) ?? serverData;

      if (existingPurchase == null || existingPurchase != updatedPurchase) {
        await box.put(serverData.id, updatedPurchase);
      }
    }

    _updateTransfers();
  }
}

@HiveType(typeId: 29)
class NoxTransfer extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String transactionId;

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
  final String? transactionType;

  @HiveField(15)
  final String? provider;

  @HiveField(16)
  final double? price;

  @HiveField(17)
  final double? cashback;

  @HiveField(18)
  final bool? cashbackPayed;

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
    this.cashback = 0.0, // Default to 0.0
    this.cashbackPayed = false, // Default to false
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
      cashback: double.tryParse(data['cashback_to_pay_user_in_bitcoin']?.toString() ?? '') ?? 0.0, // Default to 0.0
      cashbackPayed: data['cashback_payed'] ?? false, // Default to false
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
    double? cashback,
    bool? cashbackPayed,
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
      cashback: cashback ?? this.cashback,
      cashbackPayed: cashbackPayed ?? this.cashbackPayed,
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
    cashback: 0.0, // Default to 0.0
    cashbackPayed: false, // Default to false
  );
}

class NoxService {
  static Future<Result<String>> createTransaction(String auth, String address, int amountToReceive, {String transactionType = 'BUY', String fromCurrency = 'BRL', String toCurrency = 'BTC'}) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND']!}/nox_transfers'),
        body: jsonEncode({
          'transfer': {
            'address': address,
            'type': transactionType,
            'value_set_to_receive': amountToReceive,
            'from_currency': fromCurrency,
            'to_currency': toCurrency,
          }
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
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

  static Future<Result<List<NoxTransfer>>> getTransfers(String auth) async {
    try {
      final uri = Uri.parse('${dotenv.env['BACKEND']!}/nox_transfers');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
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
  }}