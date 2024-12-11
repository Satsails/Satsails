import 'dart:convert';

import 'package:Satsails/models/auth_model.dart';
import 'package:Satsails/models/coinos_ln_model.dart';
import 'package:Satsails/models/purchase_model.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lwk_dart/lwk_dart.dart' as lwk;

class TransactionModel extends StateNotifier<Transaction> {
  TransactionModel(Transaction state) : super(state);
}

abstract class BaseTransaction {
  final String id;
  final DateTime timestamp;

  BaseTransaction({
    required this.id,
    required this.timestamp,
  });
}

class BitcoinTransaction extends BaseTransaction {
  final bdk.TransactionDetails btcDetails;

  BitcoinTransaction({
    required String id,
    required DateTime timestamp,
    required bool isConfirmed,
    required this.btcDetails,
  }) : super(id: id, timestamp: timestamp);
}

class LiquidTransaction extends BaseTransaction {
  final lwk.Tx lwkDetails;

  LiquidTransaction({
    required String id,
    required DateTime timestamp,
    required this.lwkDetails,
    required bool isConfirmed,
  }) : super(id: id, timestamp: timestamp);
}

class PixPurchaseTransaction extends BaseTransaction {
  final Purchase pixDetails;

  PixPurchaseTransaction({
    required String id,
    required DateTime timestamp,
    required this.pixDetails,
    required bool isConfirmed,
  }) : super(id: id, timestamp: timestamp);
}

class CoinosTransaction extends BaseTransaction {
  final CoinosPayment coinosDetails;

  CoinosTransaction({
    required String id,
    required DateTime timestamp,
    required this.coinosDetails,
    required bool isConfirmed,
  }) : super(id: id, timestamp: timestamp);
}

class SideswapPegTransaction extends BaseTransaction {
  final SideswapPegStatus sideswapPegDetails;

  SideswapPegTransaction({
    required String id,
    required DateTime timestamp,
    required this.sideswapPegDetails,
    required bool isConfirmed,
  }) : super(id: id, timestamp: timestamp);
}

class SideswapInstantSwapTransaction extends BaseTransaction {
  final SideswapCompletedSwap sideswapInstantSwapDetails;

  SideswapInstantSwapTransaction({
    required String id,
    required DateTime timestamp,
    required this.sideswapInstantSwapDetails,
    required bool isConfirmed,
  }) : super(id: id, timestamp: timestamp);
}

class Transaction {
  final List<BitcoinTransaction> bitcoinTransactions;
  final List<LiquidTransaction> liquidTransactions;
  final List<CoinosTransaction> coinosTransactions;
  final List<SideswapPegTransaction> sideswapPegTransactions;
  final List<SideswapInstantSwapTransaction> sideswapInstantSwapTransactions;
  final List<PixPurchaseTransaction> pixPurchaseTransactions;

  Transaction({
    required this.bitcoinTransactions,
    required this.liquidTransactions,
    required this.coinosTransactions,
    required this.sideswapPegTransactions,
    required this.sideswapInstantSwapTransactions,
    required this.pixPurchaseTransactions,
  });

  Transaction copyWith({
    List<BitcoinTransaction>? bitcoinTransactions,
    List<LiquidTransaction>? liquidTransactions,
    List<CoinosTransaction>? coinosTransactions,
    List<SideswapPegTransaction>? sideswapPegTransactions,
    List<SideswapInstantSwapTransaction>? sideswapInstantSwapTransactions,
    List<PixPurchaseTransaction>? pixPurchaseTransactions,
  }) {
    return Transaction(
      bitcoinTransactions: bitcoinTransactions ?? this.bitcoinTransactions,
      liquidTransactions: liquidTransactions ?? this.liquidTransactions,
      coinosTransactions: coinosTransactions ?? this.coinosTransactions,
      sideswapPegTransactions: sideswapPegTransactions ?? this.sideswapPegTransactions,
      sideswapInstantSwapTransactions: sideswapInstantSwapTransactions ?? this.sideswapInstantSwapTransactions,
      pixPurchaseTransactions: pixPurchaseTransactions ?? this.pixPurchaseTransactions,
    );
  }

  /// Combines all transactions into a single list.
  List<BaseTransaction> get allTransactions {
    return [
      ...bitcoinTransactions,
      ...liquidTransactions,
      ...coinosTransactions,
      ...sideswapPegTransactions,
      ...sideswapInstantSwapTransactions,
    ];
  }

  /// Sorts all transactions based on their timestamp.
  List<BaseTransaction> get allTransactionsSorted {
    List<BaseTransaction> sorted = List.from(allTransactions);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  List<BitcoinTransaction> filterBitcoinTransactions(DateTimeRange range) {
    return bitcoinTransactions.where((tx) {
      return tx.timestamp.isAfter(range.start) &&
          tx.timestamp.isBefore(range.end);
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<LiquidTransaction> filterLiquidTransactions(DateTimeRange range) {
    return liquidTransactions.where((tx) {
      return tx.timestamp.isAfter(range.start) &&
          tx.timestamp.isBefore(range.end);
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<LiquidTransaction> filterLiquidTransactionsByAssetId(String assetId) {
    return liquidTransactions.where((tx) {
      return tx.lwkDetails.balances.any((balance) => balance.assetId == assetId);
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<LiquidTransaction> filterLiquidTransactionsByKind(String kind) {
    return liquidTransactions.where((tx) {
      return tx.lwkDetails.kind == kind;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // here for when we implement joltz and we must store transactions for later usage
  Future<String> encryptSideswapTransactions(AuthModel authModel) async {
    final List<Map<String, dynamic>> sideswapPegData = sideswapPegTransactions.map((tx) {
      return {
        'orderId': tx.sideswapPegDetails.orderId,
        'addr': tx.sideswapPegDetails.addr,
        'addrRecv': tx.sideswapPegDetails.addrRecv,
        'createdAt': tx.sideswapPegDetails.createdAt,
        'expiresAt': tx.sideswapPegDetails.expiresAt,
        'pegIn': tx.sideswapPegDetails.pegIn,
        'list': tx.sideswapPegDetails.list?.map((item) {
          return {
            'amount': item.amount,
            'createdAt': item.createdAt,
            'detectedConfs': item.detectedConfs,
            'payout': item.payout,
            'payoutTxid': item.payoutTxid,
            'status': item.status,
            'totalConfs': item.totalConfs,
            'txHash': item.txHash,
            'txState': item.txState,
            'txStateCode': item.txStateCode,
            'vout': item.vout,
          };
        }).toList(),
      };
    }).toList();

    final List<Map<String, dynamic>> sideswapInstantSwapData = sideswapInstantSwapTransactions.map((tx) {
      return {
        'txid': tx.sideswapInstantSwapDetails.txid,
        'sendAsset': tx.sideswapInstantSwapDetails.sendAsset,
        'sendAmount': tx.sideswapInstantSwapDetails.sendAmount,
        'recvAsset': tx.sideswapInstantSwapDetails.recvAsset,
        'recvAmount': tx.sideswapInstantSwapDetails.recvAmount,
        'orderId': tx.sideswapInstantSwapDetails.orderId,
        'timestamp': tx.sideswapInstantSwapDetails.timestamp,
      };
    }).toList();

    final Map<String, dynamic> combinedData = {
      'sideswapPegTransactions': sideswapPegData,
      'sideswapInstantSwapTransactions': sideswapInstantSwapData,
    };

    final jsonString = jsonEncode(combinedData);
    final encrypted = await authModel.encrypt(jsonString);
    return encrypted;
  }

  Future<String> decryptSideswapTransactions(AuthModel authModel, String encrypted) async {
    final decrypted = await authModel.decrypt(encrypted);
    return decrypted;
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  DateTimeRange({
    required this.start,
    required this.end,
  });
}