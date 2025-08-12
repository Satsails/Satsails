import 'package:Satsails/models/datetime_range_model.dart';
import 'package:Satsails/models/eulen_transfer_model.dart';
import 'package:Satsails/models/nox_transfer_model.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:Satsails/models/sideshift_model.dart';
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart' as breez;
import 'package:lwk/lwk.dart' as lwk;

abstract class BaseTransaction {
  final String id;
  final DateTime timestamp;
  final bool isConfirmed;

  BaseTransaction({
    required this.id,
    required this.timestamp,
    required this.isConfirmed,
  });
}

class BitcoinTransaction extends BaseTransaction {
  final bdk.TransactionDetails btcDetails;

  BitcoinTransaction({
    required super.id,
    required super.timestamp,
    required super.isConfirmed,
    required this.btcDetails,
  });
}

class LiquidTransaction extends BaseTransaction {
  final lwk.Tx lwkDetails;

  LiquidTransaction({
    required super.id,
    required super.timestamp,
    required this.lwkDetails,
    required super.isConfirmed,
  });
}

class LightningConversionTransaction extends BaseTransaction {
  final breez.Payment details;

  LightningConversionTransaction({
    required super.id,
    required super.timestamp,
    required this.details,
    required super.isConfirmed,
  });
}

class EulenTransaction extends BaseTransaction {
  final EulenTransfer details;

  EulenTransaction({
    required super.id,
    required super.timestamp,
    required this.details,
    required super.isConfirmed,
  });
}

class NoxTransaction extends BaseTransaction {
  final NoxTransfer details;

  NoxTransaction({
    required super.id,
    required super.timestamp,
    required this.details,
    required super.isConfirmed,
  });
}

class SideswapPegTransaction extends BaseTransaction {
  final SideswapPegStatus sideswapPegDetails;

  SideswapPegTransaction({
    required super.id,
    required super.timestamp,
    required this.sideswapPegDetails,
    required super.isConfirmed,
  });
}

class SideswapInstantSwapTransaction extends BaseTransaction {
  final SideswapCompletedSwap sideswapInstantSwapDetails;

  SideswapInstantSwapTransaction({
    required super.id,
    required super.timestamp,
    required this.sideswapInstantSwapDetails,
    required super.isConfirmed,
  });
}

class SideShiftTransaction extends BaseTransaction {
  final SideShift details;

  SideShiftTransaction({
    required super.id,
    required super.timestamp,
    required this.details,
    required super.isConfirmed,
  });
}

class Transaction {
  final List<BitcoinTransaction> bitcoinTransactions;
  final List<LiquidTransaction> liquidTransactions;
  final List<SideswapPegTransaction> sideswapPegTransactions;
  final List<SideswapInstantSwapTransaction> sideswapInstantSwapTransactions;
  final List<EulenTransaction> eulenTransactions;
  final List<NoxTransaction> noxTransactions;
  final List<LightningConversionTransaction> lightningConversionTransactions;
  final List<SideShiftTransaction> sideShiftTransactions;

  Transaction({
    required this.bitcoinTransactions,
    required this.liquidTransactions,
    required this.sideswapPegTransactions,
    required this.sideswapInstantSwapTransactions,
    required this.eulenTransactions,
    required this.noxTransactions,
    required this.lightningConversionTransactions,
    required this.sideShiftTransactions,
  });

  Transaction copyWith({
    List<BitcoinTransaction>? bitcoinTransactions,
    List<LiquidTransaction>? liquidTransactions,
    List<SideswapPegTransaction>? sideswapPegTransactions,
    List<SideswapInstantSwapTransaction>? sideswap,
    List<EulenTransaction>? eulenTransactions,
    List<NoxTransaction>? noxTransactions,
    List<LightningConversionTransaction>? lightningConversionTransactions,
    List<SideShiftTransaction>? sideShiftTransactions,
  }) {
    return Transaction(
      bitcoinTransactions: bitcoinTransactions ?? this.bitcoinTransactions,
      liquidTransactions: liquidTransactions ?? this.liquidTransactions,
      sideswapPegTransactions: sideswapPegTransactions ?? this.sideswapPegTransactions,
      sideswapInstantSwapTransactions: sideswap ?? this.sideswapInstantSwapTransactions,
      eulenTransactions: eulenTransactions ?? this.eulenTransactions,
      noxTransactions: noxTransactions ?? this.noxTransactions,
      lightningConversionTransactions: lightningConversionTransactions ?? this.lightningConversionTransactions,
      sideShiftTransactions: sideShiftTransactions ?? this.sideShiftTransactions,
    );
  }

  List<BaseTransaction> get allTransactions {
    return [
      ...bitcoinTransactions,
      ...liquidTransactions,
      ...sideswapPegTransactions,
      ...sideswapInstantSwapTransactions,
      ...eulenTransactions,
      ...noxTransactions,
      ...lightningConversionTransactions,
      ...sideShiftTransactions,
    ];
  }

  List<BaseTransaction> get allTransactionsSorted {
    List<BaseTransaction> sorted = List.from(allTransactions);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  Map<String, double> get unpaidCashbackByCurrency {
    final Map<String, double> cashbackMap = {};

    for (final tx in eulenTransactions) {
      if (tx.details.cashback != null && tx.details.cashback! > 0 && !(tx.details.cashbackPayed ?? false)) {
        final currency = tx.details.to_currency?.toUpperCase() ?? 'UNKNOWN';
        cashbackMap.update(currency, (value) => value + tx.details.cashback!, ifAbsent: () => tx.details.cashback!);
      }
    }

    for (final tx in noxTransactions) {
      if (tx.details.cashback != null && tx.details.cashback! > 0 && !(tx.details.cashbackPayed ?? false)) {
        final currency = tx.details.to_currency?.toUpperCase() ?? 'UNKNOWN';
        cashbackMap.update(currency, (value) => value + tx.details.cashback!, ifAbsent: () => tx.details.cashback!);
      }
    }
    return cashbackMap;
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

  List<BaseTransaction> buyAndSell(DateTimeSelect range) {
    List<BaseTransaction> buyAndSellTxs = [
      ...eulenTransactions,
      ...noxTransactions,
    ];

    return buyAndSellTxs.where((tx) {
      return tx.timestamp.isAfter(DateTime.fromMillisecondsSinceEpoch(range.start * 1000)) &&
          tx.timestamp.isBefore(DateTime.fromMillisecondsSinceEpoch(range.end * 1000));
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<BaseTransaction> filterSwapTransactions() {
    List<BaseTransaction> swaps = [];
    swaps.addAll(sideswapPegTransactions);
    swaps.addAll(liquidTransactions.where((tx) => tx.lwkDetails.kind == 'unknown'));
    swaps.addAll(lightningConversionTransactions);
    swaps.addAll(sideShiftTransactions);
    swaps.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return swaps;
  }

  List<BaseTransaction> get unsettledSwapsAndPurchases {
    final List<BaseTransaction> unsettled = [];
    unsettled.addAll(sideShiftTransactions.where((tx) =>
    tx.details.status == 'waiting' || tx.details.status == 'expired'));
    unsettled.addAll(eulenTransactions.where((tx) =>
    tx.details.failed || tx.details.status == 'expired' || tx.details.status == 'pending'));
    unsettled.addAll(noxTransactions.where((tx) =>
    tx.details.status == 'quote' || tx.details.status == 'failed'));
    unsettled.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return unsettled;
  }

  List<BaseTransaction> get settledTransactions {
    final unsettledIds = unsettledSwapsAndPurchases.map((tx) => tx.id).toSet();
    return allTransactionsSorted.where((tx) => !unsettledIds.contains(tx.id)).toList();
  }

  DateTime? get earliestTimestamp {
    if (allTransactions.isEmpty) return null;
    return allTransactions.map((tx) => tx.timestamp).reduce((a, b) => a.isBefore(b) ? a : b);
  }

  factory Transaction.empty() {
    return Transaction(
      bitcoinTransactions: [],
      liquidTransactions: [],
      sideswapPegTransactions: [],
      sideswapInstantSwapTransactions: [],
      eulenTransactions: [],
      noxTransactions: [],
      lightningConversionTransactions: [],
      sideShiftTransactions: [],
    );
  }
}