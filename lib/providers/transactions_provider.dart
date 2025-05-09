import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/eulen_transfer_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:Satsails/providers/sideshift_provider.dart'; // Assuming this exists for SideShift

final transactionNotifierProvider = StateNotifierProvider<TransactionModel, Transaction>((ref) {
  return TransactionModel();
});

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

final getFiatPurchasesProvider = FutureProvider<void>((ref) async {
  await Future.wait([
    ref.read(getNoxUserPurchasesProvider.future).catchError((e) {
      return null; // Continue despite the error
    }),
    ref.read(getEulenUserPurchasesProvider.future).catchError((e) {
      return null; // Continue despite the error
    }),
  ]);
});