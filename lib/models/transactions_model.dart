import 'package:Satsails/models/boltz_model.dart';
import 'package:Satsails/models/datetime_range_model.dart';
import 'package:Satsails/models/eulen_transfer_model.dart';
import 'package:Satsails/models/nox_transfer_model.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:Satsails/models/sideshift_model.dart'; // Assuming this exists for SideShift
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/providers/eulen_transfer_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:Satsails/providers/sideshift_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lwk/lwk.dart' as lwk;

class TransactionModel extends StateNotifier<Transaction> {
  TransactionModel() : super(Transaction.empty());

  void updateTransactions(Transaction newTransactions) {
    state = newTransactions;
  }
}

Future<void> fetchAndUpdateTransactions(WidgetRef ref) async {
  final bitcoinTxs = await ref.watch(getBitcoinTransactionsProvider.future);
  final bitcoinTransactions = bitcoinTxs.map((btcTx) {
    return BitcoinTransaction(
      id: btcTx.txid,
      timestamp: btcTx.confirmationTime != null && btcTx.confirmationTime!.timestamp != 0
          ? DateTime.fromMillisecondsSinceEpoch(btcTx.confirmationTime!.timestamp.toInt() * 1000)
          : DateTime.now(),
      btcDetails: btcTx,
      isConfirmed: btcTx.confirmationTime != null && btcTx.confirmationTime!.timestamp != 0,
    );
  }).toList();

  final liquidTxs = await ref.watch(liquidTransactionsProvider.future);
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

  final sideswapPegTxs = ref.watch(sideswapAllPegsProvider);
  final sideswapPegTransactions = sideswapPegTxs.map((pegTx) {
    return SideswapPegTransaction(
      id: pegTx.orderId!,
      timestamp: DateTime.fromMillisecondsSinceEpoch(pegTx.createdAt!),
      sideswapPegDetails: pegTx,
      isConfirmed: pegTx.list!.map((e) => e.status).contains('Done'),
    );
  }).toList();

  final sideswapInstantSwapTxs = ref.watch(sideswapGetSwapsProvider);
  final sideswapInstantSwapTransactions = sideswapInstantSwapTxs.map((instantSwapTx) {
    return SideswapInstantSwapTransaction(
      id: instantSwapTx.quoteId.toString(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(instantSwapTx.timestamp),
      sideswapInstantSwapDetails: instantSwapTx,
      isConfirmed: instantSwapTx.txid.isNotEmpty,
    );
  }).toList();

  final eulenPurchases = ref.watch(eulenTransferProvider);
  final eulenTransactions = eulenPurchases.map((pixTx) {
    return EulenTransaction(
      id: pixTx.id.toString(),
      timestamp: pixTx.createdAt,
      details: pixTx,
      isConfirmed: pixTx.completed,
    );
  }).toList();

  final noxPurchases = ref.watch(noxTransferProvider);
  final noxTransactions = noxPurchases.map((pixTx) {
    return NoxTransaction(
      id: pixTx.id.toString(),
      timestamp: pixTx.createdAt,
      details: pixTx,
      isConfirmed: pixTx.completed,
    );
  }).toList();

  final boltzSwaps = ref.watch(boltzSwapProvider);
  final boltzTransactions = boltzSwaps.map((swap) {
    return BoltzTransaction(
      id: swap.swap.id,
      timestamp: DateTime.fromMillisecondsSinceEpoch(swap.timestamp),
      details: swap,
      isConfirmed: swap.completed ?? false,
    );
  }).toList();

  final sideShiftShifts = ref.watch(sideShiftShiftsProvider); // Assuming this provider exists
  final sideShiftTransactions = sideShiftShifts.map((shift) {
    return SideShiftTransaction(
      id: shift.id,
      timestamp: DateTime.fromMillisecondsSinceEpoch(shift.timestamp * 1000),
      details: shift,
      isConfirmed: shift.status == 'settled', // Adjust based on actual status field
    );
  }).toList();

  final transactionNotifier = ref.read(transactionNotifierProvider.notifier);
  transactionNotifier.updateTransactions(
    Transaction(
      bitcoinTransactions: bitcoinTransactions,
      liquidTransactions: liquidTransactions,
      sideswapPegTransactions: sideswapPegTransactions,
      sideswapInstantSwapTransactions: sideswapInstantSwapTransactions,
      eulenTransactions: eulenTransactions,
      noxTransactions: noxTransactions,
      boltzTransactions: boltzTransactions,
      sideShiftTransactions: sideShiftTransactions,
    ),
  );
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

class BoltzTransaction extends BaseTransaction {
  final LbtcBoltz details;

  BoltzTransaction({
    required super.id,
    required super.timestamp,
    required this.details,
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
  final List<BoltzTransaction> boltzTransactions;
  final List<SideShiftTransaction> sideShiftTransactions;

  Transaction({
    required this.bitcoinTransactions,
    required this.liquidTransactions,
    required this.sideswapPegTransactions,
    required this.sideswapInstantSwapTransactions,
    required this.eulenTransactions,
    required this.noxTransactions,
    required this.boltzTransactions,
    required this.sideShiftTransactions,
  });

  Transaction copyWith({
    List<BitcoinTransaction>? bitcoinTransactions,
    List<LiquidTransaction>? liquidTransactions,
    List<SideswapPegTransaction>? sideswapPegTransactions,
    List<SideswapInstantSwapTransaction>? sideswapInstantSwapTransactions,
    List<EulenTransaction>? eulenTransactions,
    List<NoxTransaction>? noxTransactions,
    List<BoltzTransaction>? boltzTransactions,
    List<SideShiftTransaction>? sideShiftTransactions,
  }) {
    return Transaction(
      bitcoinTransactions: bitcoinTransactions ?? this.bitcoinTransactions,
      liquidTransactions: liquidTransactions ?? this.liquidTransactions,
      sideswapPegTransactions: sideswapPegTransactions ?? this.sideswapPegTransactions,
      sideswapInstantSwapTransactions: sideswapInstantSwapTransactions ?? this.sideswapInstantSwapTransactions,
      eulenTransactions: eulenTransactions ?? this.eulenTransactions,
      noxTransactions: noxTransactions ?? this.noxTransactions,
      boltzTransactions: boltzTransactions ?? this.boltzTransactions,
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
      ...boltzTransactions,
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
    swaps.addAll(boltzTransactions);
    swaps.addAll(sideShiftTransactions); // Include SideShift in swaps if applicable
    swaps.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return swaps;
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
      boltzTransactions: [],
      sideShiftTransactions: [],
    );
  }
}