import 'package:Satsails/models/coinos_ln_model.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lwk_dart/lwk_dart.dart' as lwk;

/// StateNotifier for managing the Transaction state.
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

/// Represents a Liquid transaction.
class LiquidTransaction extends BaseTransaction {
  final lwk.Tx lwkDetails;

  LiquidTransaction({
    required String id,
    required DateTime timestamp,
    required this.lwkDetails,
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

  Transaction({
    required this.bitcoinTransactions,
    required this.liquidTransactions,
    required this.coinosTransactions,
    required this.sideswapPegTransactions,
    required this.sideswapInstantSwapTransactions,
  });

  Transaction copyWith({
    List<BitcoinTransaction>? bitcoinTransactions,
    List<LiquidTransaction>? liquidTransactions,
    List<CoinosTransaction>? coinosTransactions,
    List<SideswapPegTransaction>? sideswapPegTransactions,
    List<SideswapInstantSwapTransaction>? sideswapInstantSwapTransactions,
  }) {
    return Transaction(
      bitcoinTransactions: bitcoinTransactions ?? this.bitcoinTransactions,
      liquidTransactions: liquidTransactions ?? this.liquidTransactions,
      coinosTransactions: coinosTransactions ?? this.coinosTransactions,
      sideswapPegTransactions: sideswapPegTransactions ?? this.sideswapPegTransactions,
      sideswapInstantSwapTransactions: sideswapInstantSwapTransactions ?? this.sideswapInstantSwapTransactions,
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

  /// Filters Liquid transactions within a specific date range.
  List<LiquidTransaction> filterLiquidTransactions(DateTimeRange range) {
    return liquidTransactions.where((tx) {
      return tx.timestamp.isAfter(range.start) &&
          tx.timestamp.isBefore(range.end);
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
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
