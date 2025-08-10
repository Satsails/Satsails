import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/eulen_transfer_provider.dart';
import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:flutter/foundation.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart' as breez;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lwk/lwk.dart' as lwk;

import 'package:Satsails/models/eulen_transfer_model.dart';
import 'package:Satsails/models/nox_transfer_model.dart';
import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';

/// A simple data class to hold all the raw transaction data fetched
/// by the background sync process. This acts as a "staging area".
class RawTransactionData {
  final List<bdk.TransactionDetails> bitcoinTxs;
  final List<lwk.Tx> liquidTxs;
  final List<SideswapPegStatus> sideswapPegTxs;
  final List<EulenTransfer> eulenTxs;
  final List<NoxTransfer> noxTxs;
  final List<breez.Payment> lightningPayments;
  final List<SideShift> sideShiftShifts;

  RawTransactionData({
    required this.bitcoinTxs,
    required this.liquidTxs,
    required this.sideswapPegTxs,
    required this.eulenTxs,
    required this.noxTxs,
    required this.lightningPayments,
    required this.sideShiftShifts,
  });
}

/// This provider is the "staging area". The background sync will write to it.
final rawTransactionDataProvider = StateProvider<RawTransactionData?>((ref) => null);

/// This provider fetches the latest fiat purchase transactions.
/// It's called by the background sync process.
final getFiatPurchasesProvider = FutureProvider.autoDispose<void>((ref) async {
  final userIsNotCreated = ref.watch(userProvider).jwt.isEmpty;
  if (userIsNotCreated) {
    return;
  }

  await Future.wait([
    ref.read(getNoxUserPurchasesProvider.future).catchError((e, s) {
      debugPrint("Failed to get Nox purchases: $e");
      // Return a correctly typed empty list to satisfy the Future's type.
      return <NoxTransfer>[];
    }),
    ref.read(getEulenUserPurchasesProvider.future).catchError((e, s) {
      debugPrint("Failed to get Eulen purchases: $e");
      // Return a correctly typed empty list to satisfy the Future's type.
      return <EulenTransfer>[];
    }),
  ]);
});


/// The main provider for transaction state, now a StateNotifierProvider.
final transactionNotifierProvider =
StateNotifierProvider<TransactionNotifier, Transaction>(
      (ref) => TransactionNotifier(),
);

/// This notifier holds the final, processed list of transactions.
/// It is updated manually by the background sync process.
class TransactionNotifier extends StateNotifier<Transaction> {
  TransactionNotifier() : super(Transaction.empty());

  /// Processes the raw data and updates the state.
  void updateTransactions(RawTransactionData? rawData) {
    if (rawData == null) {
      state = Transaction.empty();
      return;
    }

    final bitcoinTransactions = rawData.bitcoinTxs.map((btcTx) {
      return BitcoinTransaction(
        id: btcTx.txid,
        timestamp: btcTx.confirmationTime != null && btcTx.confirmationTime!.timestamp != 0
            ? DateTime.fromMillisecondsSinceEpoch(btcTx.confirmationTime!.timestamp.toInt() * 1000)
            : DateTime.now(),
        btcDetails: btcTx,
        isConfirmed: btcTx.confirmationTime != null && btcTx.confirmationTime!.timestamp != 0,
      );
    }).toList();

    final liquidTransactions = rawData.liquidTxs.map((lwkTx) {
      return LiquidTransaction(
        id: lwkTx.txid,
        timestamp: lwkTx.timestamp != null && lwkTx.timestamp != 0
            ? DateTime.fromMillisecondsSinceEpoch(lwkTx.timestamp! * 1000)
            : DateTime.now(),
        lwkDetails: lwkTx,
        isConfirmed: lwkTx.timestamp != null && lwkTx.timestamp != 0,
      );
    }).toList();

    final sideswapPegTransactions = rawData.sideswapPegTxs.map((pegTx) {
      return SideswapPegTransaction(
        id: pegTx.orderId!,
        timestamp: DateTime.fromMillisecondsSinceEpoch(pegTx.createdAt!),
        sideswapPegDetails: pegTx,
        isConfirmed: pegTx.list!.map((e) => e.status).contains('Done'),
      );
    }).toList();

    final eulenTransactions = rawData.eulenTxs.map((pixTx) {
      return EulenTransaction(
        id: pixTx.id.toString(),
        timestamp: pixTx.createdAt,
        details: pixTx,
        isConfirmed: pixTx.completed,
      );
    }).toList();

    final noxTransactions = rawData.noxTxs.map((pixTx) {
      return NoxTransaction(
        id: pixTx.id.toString(),
        timestamp: pixTx.createdAt,
        details: pixTx,
        isConfirmed: pixTx.completed,
      );
    }).toList();

    final lightningConversionTransactions = rawData.lightningPayments
        .where((payment) => payment.details is breez.PaymentDetails_Lightning)
        .map((payment) {
      final lightningDetails = payment.details as breez.PaymentDetails_Lightning;
      final String paymentId = lightningDetails.paymentHash ?? lightningDetails.swapId;

      return LightningConversionTransaction(
        id: paymentId,
        timestamp: DateTime.fromMillisecondsSinceEpoch(payment.timestamp * 1000),
        details: payment,
        isConfirmed: payment.status == breez.PaymentState.complete,
      );
    }).toList();

    final sideShiftTransactions = rawData.sideShiftShifts.map((shift) {
      return SideShiftTransaction(
        id: shift.id,
        timestamp: DateTime.fromMillisecondsSinceEpoch(shift.timestamp * 1000),
        details: shift,
        isConfirmed: shift.status == 'settled',
      );
    }).toList();

    state = Transaction(
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