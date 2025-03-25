import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/eulen_transfer_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';

// StateNotifierProvider to hold transaction state
final transactionNotifierProvider = StateNotifierProvider<TransactionModel, Transaction>((ref) {
  return TransactionModel();
});

// Function to fetch transactions and update the provider
Future<void> fetchAndUpdateTransactions(WidgetRef ref) async {
  // if i manage to speed this up problem is fixed
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
      id: instantSwapTx.orderId,
      timestamp: DateTime.fromMillisecondsSinceEpoch(instantSwapTx.timestamp),
      sideswapInstantSwapDetails: instantSwapTx,
      isConfirmed: instantSwapTx.txid.isNotEmpty,
    );
  }).toList();
  //
  final purchases = ref.watch(eulenTransferProvider);
  final pixPurchases = purchases.map((pixTx) {
    return EulenTransaction(
      id: pixTx.id.toString(),
      timestamp: pixTx.createdAt,
      pixDetails: pixTx,
      isConfirmed: pixTx.completed,
    );
  }).toList();

  final transactionNotifier = ref.read(transactionNotifierProvider.notifier);
  transactionNotifier.updateTransactions(
    Transaction(
      bitcoinTransactions: bitcoinTransactions,
      liquidTransactions: liquidTransactions,
      sideswapPegTransactions: sideswapPegTransactions,
      sideswapInstantSwapTransactions: sideswapInstantSwapTransactions,
      pixPurchaseTransactions: pixPurchases,
    ),
  );
}

// StateProviders to filter transactions by date
final bitcoinTransactionsByDate = StateProvider.autoDispose<List<BitcoinTransaction>>((ref) {
  final transactionState = ref.watch(transactionNotifierProvider);
  final dateTimeRange = ref.watch(dateTimeSelectProvider);

  return transactionState.bitcoinTransactions.where((tx) {
    return tx.timestamp.isAfter(DateTime.fromMillisecondsSinceEpoch(dateTimeRange.start * 1000)) &&
        tx.timestamp.isBefore(DateTime.fromMillisecondsSinceEpoch(dateTimeRange.end * 1000));
  }).toList();
});

final liquidTransactionsByDate = StateProvider.autoDispose<List<LiquidTransaction>>((ref) {
  final transactionState = ref.watch(transactionNotifierProvider);
  final dateTimeRange = ref.watch(dateTimeSelectProvider);

  return transactionState.liquidTransactions.where((tx) {
    return tx.timestamp.isAfter(DateTime.fromMillisecondsSinceEpoch(dateTimeRange.start * 1000)) &&
        tx.timestamp.isBefore(DateTime.fromMillisecondsSinceEpoch(dateTimeRange.end * 1000));
  }).toList();
});
