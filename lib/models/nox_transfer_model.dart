import 'dart:convert';

import 'package:Satsails/handlers/response_handlers.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

part 'nox_transfer_model.g.dart';


class MinimumDeposit {
  final String brl;
  final String btc;

  MinimumDeposit({required this.brl, required this.btc});

  factory MinimumDeposit.fromJson(Map<String, dynamic> json) {
    return MinimumDeposit(
      brl: json['brl']?.toString() ?? '20.00',
      btc: json['btc']?.toString() ?? '0.00005',
    );
  }
}

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
      subStatus: serverData.subStatus ?? existingPurchase.subStatus,
      depositAddress: serverData.depositAddress ?? existingPurchase.depositAddress,
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
        subStatus: serverData.subStatus ?? existingPurchase.subStatus,
        depositAddress: serverData.depositAddress ?? existingPurchase.depositAddress,
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

  @HiveField(19)
  final String? subStatus;

  @HiveField(20)
  final String? depositAddress;

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
    this.cashback = 0.0,
    this.cashbackPayed = false,
    this.subStatus,
    this.depositAddress,
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
      subStatus: data['sub_status']?.toString(),
      depositAddress: data['deposit_address']?.toString(),
      paymentMethod: data['payment_method']?.toString() ?? 'unknown',
      to_currency: data['to_currency']?.toString() ?? 'unknown',
      from_currency: data['from_currency']?.toString() ?? 'unknown',
      transactionType: data['type']?.toString() ?? 'BUY',
      provider: 'Nox',
      price: double.tryParse(data['price']?.toString() ?? '') ?? 0.0,
      cashback: double.tryParse(data['cashback_to_pay_user']?.toString() ?? '') ?? 0.0,
      cashbackPayed: data['cashback_payed'] ?? false,
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
    String? subStatus,
    String? depositAddress,
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
      subStatus: subStatus ?? this.subStatus,
      depositAddress: depositAddress ?? this.depositAddress,
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
    subStatus: null,
    depositAddress: null,
    paymentMethod: 'unknown',
    to_currency: 'unknown',
    from_currency: 'unknown',
    transactionType: 'BUY',
    provider: 'Nox',
    price: 0.0,
    cashback: 0.0,
    cashbackPayed: false,
  );

  String get statusText {
    switch (status) {
      case "pix_deposit":
        return "Pix Deposit".i18n;
      case "pix_withdrawal":
        return "Pix Withdrawal".i18n;
      case "kyc_validation":
        return "KYC Validation".i18n;
      case "quoting":
        return "Quoting".i18n;
      case "crypto_deposit":
        return "Crypto Deposit".i18n;
      case "crypto_withdrawal":
        return "Crypto Withdrawal".i18n;
      case "swap_fiat_for_crypto":
        return "Fiat to Crypto Swap".i18n;
      case "swap_crypto_for_fiat":
        return "Crypto to Fiat Swap".i18n;
      case "client_side_success":
        return "Completed".i18n;
      default:
        return status?.replaceAll('_', ' ').i18n.capitalize() ?? "Unknown".i18n;
    }
  }

  bool get shouldShowInMainTransaction {
    const userInteractionStartedStatuses = [
      'kyc_validation',
      'pix_deposit',
      'pix_withdrawal',
      'crypto_deposit',
      'crypto_withdrawal',
      'swap_fiat_for_crypto',
      'swap_crypto_for_fiat',
      'client_side_success',
    ];

    if (status != null && userInteractionStartedStatuses.contains(status)) {
      return true;
    }
    return false;
  }

  String get subStatusText {
    switch (status) {
      case "quoting":
        switch (subStatus) {
          case "INITIAL": return "Initiated, not opened by client".i18n;
          case "QUOTE": return "Quote shown to client, pending acceptance".i18n;
          case "ERROR": return "Error on quote".i18n;
          case "EXPIRED": return "Quote expired".i18n;
          case "DONE": return "Quote accepted by client".i18n;
        }
        break;
      case "kyc_validation":
        switch (subStatus) {
          case "INITIAL": return "Initiated, not opened by client".i18n;
          case "INFO": return "KYC shown to client, pending filling".i18n;
          case "INVALID": return "Invalid KYC data".i18n;
          case "TIER_LIMIT": return "Transaction exceeds client's transactional limit".i18n;
          case "DONE": return "KYC filled and accepted".i18n;
        }
        break;
      case "pix_deposit":
        switch (subStatus) {
          case "INITIAL": return "Initiated, not opened by client".i18n;
          case "QRCODE": return "QR Code shown, pending payment".i18n;
          case "ERROR": return "Error processing payment".i18n;
          case "DONE": return "Payment received successfully".i18n;
        }
        break;
      case "pix_withdrawal":
        switch (subStatus) {
          case "INITIAL": return "Processing initiated".i18n;
          case "WAITING": return "Waiting for payment confirmation".i18n;
          case "DIVERGENT": return "Payment failed due to data divergence".i18n;
          case "ERROR": return "Error processing payment".i18n;
          case "DONE": return "Client received payment".i18n;
        }
        break;
      case "crypto_deposit":
        switch (subStatus) {
          case "INITIAL": return "Processing initiated".i18n;
          case "WAITING_DEPOSIT": return "Waiting for crypto deposit".i18n;
          case "EXPIRED": return "Quote expired before deposit".i18n;
          case "ERROR": return "Error processing payment".i18n;
          case "DONE": return "Crypto deposit received".i18n;
        }
        break;
      case "crypto_withdrawal":
        switch (subStatus) {
          case "INITIAL": return "Processing initiated".i18n;
          case "WAITING_TRANSFER": return "Processing withdrawal".i18n;
          case "ERROR": return "Error processing withdrawal".i18n;
          case "DONE": return "Crypto withdrawal processed".i18n;
        }
        break;
      case "swap_fiat_for_crypto":
      case "swap_crypto_for_fiat":
        switch (subStatus) {
          case "INITIAL": return "Processing initiated".i18n;
          case "ERROR": return "Error processing swap and transfer".i18n;
          case "DONE": return "Swap and transfer processed".i18n;
        }
        break;
      case "client_side_success":
        if (subStatus == "INITIAL") return "Successfully processed".i18n;
        break;
    }
    return subStatus?.replaceAll('_', ' ').i18n.capitalize() ?? '';
  }

}

class NoxService {
  static Future<Result<String>> createTransaction(String auth, String address, String? amountCrypto, String? amountFiat, String transactionType) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['BACKEND']!}/nox_transfers'),
        body: jsonEncode({
          'transfer': {
            'address': address,
            'type': transactionType,
            'amount_crypto': amountCrypto,
            'type': transactionType,
            'amount_fiat': amountFiat,
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
  }

  static Future<Result<NoxTransfer>> getTransfer(String auth, String transferId) async {
    try {
      final uri = Uri.parse('${dotenv.env['BACKEND']!}/nox_transfers/$transferId');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final transaction = NoxTransfer.fromJson(jsonResponse['transfer']);
        return Result(data: transaction);
      } else {
        return Result(error: 'Failed to get transaction details');
      }
    } catch (e) {
      return Result(error: 'An error has occurred. Please try again later');
    }
  }


  static Future<Result<MinimumDeposit>> getMinimumDeposit(String auth) async {
    try {
      final uri = Uri.parse('${dotenv.env['BACKEND']!}/nox_transfers/minimum_deposits');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': auth,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final minimumDeposits = MinimumDeposit.fromJson(jsonResponse);
        return Result(data: minimumDeposits);
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Failed to get minimum deposit';
        return Result(error: error);
      }
    } catch (e) {
      return Result(error: 'An error has occurred. Please try again later');
    }
  }
}