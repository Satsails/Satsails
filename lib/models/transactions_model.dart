import 'package:Satsails/models/datetime_range_model.dart';
import 'package:Satsails/models/purchase_model.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lwk/lwk.dart' as lwk;

class TransactionModel extends StateNotifier<Transaction> {
  TransactionModel() : super(Transaction.empty());

  void updateTransactions(Transaction newTransactions) {
    state = newTransactions;
  }
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
  final List<SideswapPegTransaction> sideswapPegTransactions;
  final List<SideswapInstantSwapTransaction> sideswapInstantSwapTransactions;
  final List<PixPurchaseTransaction> pixPurchaseTransactions;

  Transaction({
    required this.bitcoinTransactions,
    required this.liquidTransactions,
    required this.sideswapPegTransactions,
    required this.sideswapInstantSwapTransactions,
    required this.pixPurchaseTransactions,
  });

  Transaction copyWith({
    List<BitcoinTransaction>? bitcoinTransactions,
    List<LiquidTransaction>? liquidTransactions,
    List<SideswapPegTransaction>? sideswapPegTransactions,
    List<SideswapInstantSwapTransaction>? sideswapInstantSwapTransactions,
    List<PixPurchaseTransaction>? pixPurchaseTransactions,
  }) {
    return Transaction(
      bitcoinTransactions: bitcoinTransactions ?? this.bitcoinTransactions,
      liquidTransactions: liquidTransactions ?? this.liquidTransactions,
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

  List<BitcoinTransaction> filterBitcoinTransactions(DateTimeSelect range) {
    return bitcoinTransactions.where((tx) {
      return tx.timestamp.isAfter(DateTime.fromMillisecondsSinceEpoch(range.start * 1000)) &&
          tx.timestamp.isBefore(DateTime.fromMillisecondsSinceEpoch(range.end * 1000));
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<LiquidTransaction> filterLiquidTransactions(DateTimeSelect range) {
    return liquidTransactions.where((tx) {
      return tx.timestamp.isAfter(DateTime.fromMillisecondsSinceEpoch(range.start * 1000)) &&
          tx.timestamp.isBefore(DateTime.fromMillisecondsSinceEpoch(range.end * 1000));
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

  factory Transaction.empty() {
    return Transaction(
      bitcoinTransactions: [],
      liquidTransactions: [],
      sideswapPegTransactions: [],
      sideswapInstantSwapTransactions: [],
      pixPurchaseTransactions: [],
    );
  }
}