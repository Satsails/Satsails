import 'dart:async';

import 'package:Satsails/models/datetime_range_model.dart';
import 'package:Satsails/models/eulen_transfer_model.dart';
import 'package:Satsails/models/nox_transfer_model.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/breez_provider.dart';
import 'package:Satsails/providers/eulen_transfer_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:Satsails/providers/sideshift_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart' as breez;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lwk/lwk.dart' as lwk;

class TransactionNotifier extends AsyncNotifier<Transaction> {
  @override
  Future<Transaction> build() async {
    return _fetchAllTransactions();
  }

  Future<void> refreshAndMergeTransactions({List<bdk.TransactionDetails>? btcTxs}) async {
    final previousState = state.value ?? Transaction.empty();
    final newState = await _fetchAllTransactions(bitcoinTxs: btcTxs);

    final merged = Transaction(
      bitcoinTransactions: _merge(previousState.bitcoinTransactions, newState.bitcoinTransactions),
      liquidTransactions: _merge(previousState.liquidTransactions, newState.liquidTransactions),
      sideswapPegTransactions: _merge(previousState.sideswapPegTransactions, newState.sideswapPegTransactions),
      sideswapInstantSwapTransactions: _merge(previousState.sideswapInstantSwapTransactions, newState.sideswapInstantSwapTransactions),
      eulenTransactions: _merge(previousState.eulenTransactions, newState.eulenTransactions),
      noxTransactions: _merge(previousState.noxTransactions, newState.noxTransactions),
      lightningConversionTransactions: _merge(previousState.lightningConversionTransactions, newState.lightningConversionTransactions),
      sideShiftTransactions: _merge(previousState.sideShiftTransactions, newState.sideShiftTransactions),
    );
    state = AsyncData(merged);
  }

  List<T> _merge<T extends BaseTransaction>(List<T> oldList, List<T> newList) {
    final map = <String, T>{};
    for (final tx in oldList) {
      map[tx.id] = tx;
    }
    for (final tx in newList) {
      map[tx.id] = tx;
    }
    return map.values.toList();
  }

  Future<Transaction> _fetchAllTransactions({List<bdk.TransactionDetails>? bitcoinTxs}) async {
    final bitcoinModel = await ref.read(bitcoinModelProvider.future);
    final liquidModel = await ref.read(liquidModelProvider.future);

    final btcTxsList = bitcoinTxs ?? await bitcoinModel.getTransactions();
    final liquidTxs = await liquidModel.txs();

    final bitcoinTransactions = btcTxsList.map((btcTx) {
      return BitcoinTransaction(
        id: btcTx.txid,
        timestamp: btcTx.confirmationTime != null && btcTx.confirmationTime!.timestamp != 0
            ? DateTime.fromMillisecondsSinceEpoch(btcTx.confirmationTime!.timestamp.toInt() * 1000)
            : DateTime.now(),
        btcDetails: btcTx,
        isConfirmed: btcTx.confirmationTime != null && btcTx.confirmationTime!.timestamp != 0,
      );
    }).toList();

    final liquidTransactions = liquidTxs.map((lwkTx) {
      return LiquidTransaction(
        id: lwkTx.txid,
        timestamp: lwkTx.timestamp != null && lwkTx.timestamp != 0
            ? DateTime.fromMillisecondsSinceEpoch(lwkTx.timestamp! * 1000)
            : DateTime.now(),
        lwkDetails: lwkTx,
        isConfirmed: lwkTx.timestamp != null && lwkTx.timestamp != 0,
      );
    }).toList();

    final sideswapPegTxs = ref.read(sideswapAllPegsProvider);
    final sideswapPegTransactions = sideswapPegTxs.map((pegTx) {
      return SideswapPegTransaction(
        id: pegTx.orderId!,
        timestamp: DateTime.fromMillisecondsSinceEpoch(pegTx.createdAt!),
        sideswapPegDetails: pegTx,
        isConfirmed: pegTx.list!.map((e) => e.status).contains('Done'),
      );
    }).toList();

    final eulenPurchases = ref.read(eulenTransferProvider);
    final eulenTransactions = eulenPurchases.map((pixTx) {
      return EulenTransaction(
        id: pixTx.id.toString(),
        timestamp: pixTx.createdAt,
        details: pixTx,
        isConfirmed: pixTx.completed,
      );
    }).toList();

    final noxPurchases = ref.read(noxTransferProvider);
    final noxTransactions = noxPurchases.map((pixTx) {
      return NoxTransaction(
        id: pixTx.id.toString(),
        timestamp: pixTx.createdAt,
        details: pixTx,
        isConfirmed: pixTx.completed,
      );
    }).toList();

    final lightningPayments = await ref.read(listLightningPaymentsProvider(const breez.ListPaymentsRequest()).future);
    final lightningConversionTransactions = lightningPayments.map((payment) {
      final lightningDetails = payment.details as breez.PaymentDetails_Lightning;
      final String paymentId = lightningDetails.paymentHash ?? lightningDetails.swapId;

      return LightningConversionTransaction(
        id: paymentId,
        timestamp: DateTime.fromMillisecondsSinceEpoch(payment.timestamp * 1000),
        details: payment,
        isConfirmed: payment.status == breez.PaymentState.complete,
      );
    }).toList();

    final sideShiftShifts = ref.read(sideShiftShiftsProvider);
    final sideShiftTransactions = sideShiftShifts.map((shift) {
      return SideShiftTransaction(
        id: shift.id,
        timestamp: DateTime.fromMillisecondsSinceEpoch(shift.timestamp * 1000),
        details: shift,
        isConfirmed: shift.status == 'settled',
      );
    }).toList();

    return Transaction(
      bitcoinTransactions: bitcoinTransactions,
      liquidTransactions: liquidTransactions,
      sideswapPegTransactions: sideswapPegTransactions,
      sideswapInstantSwapTransactions: [],
      eulenTransactions: eulenTransactions,
      noxTransactions: noxTransactions,
      lightningConversionTransactions: lightningConversionTransactions,
      sideShiftTransactions: sideShiftTransactions,
    );
  }
}

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
    swaps.addAll(lightningConversionTransactions); // Add lightning swaps/payments
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

  double get totalCashback {
    final eulenSum = eulenTransactions.fold<double>(
      0.0,
          (sum, tx) => sum + (tx.details.cashback ?? 0.0),
    );
    final noxSum = noxTransactions.fold<double>(
      0.0,
          (sum, tx) => sum + (tx.details.cashback ?? 0.0),
    );
    return eulenSum + noxSum;
  }

  double get unpaidCashback {
    final eulenUnpaidSum = eulenTransactions
        .where((tx) => (tx.details.cashbackPayed ?? false) == false && tx.details.completed)
        .fold<double>(
      0.0,
          (sum, tx) => sum + (tx.details.cashback ?? 0.0),
    );
    final noxUnpaidSum = noxTransactions
        .where((tx) => (tx.details.cashbackPayed ?? false) == false && tx.details.completed)
        .fold<double>(
      0.0,
          (sum, tx) => sum + (tx.details.cashback ?? 0.0),
    );
    return eulenUnpaidSum + noxUnpaidSum;
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