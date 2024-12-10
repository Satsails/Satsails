import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/purchase_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final initializeTransactionsProvider =
FutureProvider.autoDispose<Transaction>((ref) async {
  final bitcoinTxs = await ref.watch(getBitcoinTransactionsProvider.future);
  final bitcoinTransactions = bitcoinTxs.map((btcTx) {
    return BitcoinTransaction(
      id: btcTx.txid,
      timestamp: btcTx.confirmationTime != null &&btcTx.confirmationTime!.timestamp != 0 ? DateTime.fromMillisecondsSinceEpoch(btcTx.confirmationTime!.timestamp * 1000) : DateTime.now(),
      btcDetails: btcTx,
      isConfirmed: btcTx.confirmationTime != null && btcTx.confirmationTime!.timestamp != 0,
    );
  }).toList();
  final liquidTxs = await ref.watch(liquidTransactionsProvider.future);
  final liquidTransactions = liquidTxs.map((lwkTx) {
    return LiquidTransaction(
      id: lwkTx.txid,
      timestamp: DateTime.fromMillisecondsSinceEpoch(lwkTx.timestamp! * 1000),
      lwkDetails: lwkTx,
      isConfirmed: lwkTx.timestamp != null && lwkTx.timestamp != 0,
    );
  }).toList();

  // Fetch Coinos Transactions
  final coinosTxs = ref.watch(coinosLnProvider).transactions;
  final coinosTransactions = coinosTxs.map((coinosTx) {
    return CoinosTransaction(
      id: coinosTx.id ?? '',
      timestamp: coinosTx.created!,
      coinosDetails: coinosTx,
      isConfirmed: coinosTx.confirmed ?? false,
    );
  }).toList();

  final sideswapPegTxs = await ref.watch(sideswapAllPegsProvider.future);
  final sideswapPegTransactions = sideswapPegTxs.map((pegTx) {
    return SideswapPegTransaction(
      id: pegTx.orderId!,
      timestamp: DateTime.fromMillisecondsSinceEpoch(pegTx.createdAt!),
      sideswapPegDetails: pegTx,
      isConfirmed: pegTx.list!.map((e) => e.status).contains('completed'),
    );
  }).toList();

  final sideswapInstantSwapTxs =
  await ref.watch(sideswapGetSwapsProvider.future);
  final sideswapInstantSwapTransactions =
  sideswapInstantSwapTxs.map((instantSwapTx) {
    return SideswapInstantSwapTransaction(
      id: instantSwapTx.orderId,
      timestamp: DateTime.fromMillisecondsSinceEpoch(instantSwapTx.timestamp!),
      sideswapInstantSwapDetails: instantSwapTx,
      isConfirmed: instantSwapTx.txid != null && instantSwapTx.txid!.isNotEmpty,
    );
  }).toList();

  final purchases = ref.watch(purchaseProvider) ;
  final pixPurchases = purchases.map((pixTx) {
    return PixPurchaseTransaction(
      id: pixTx.id.toString(),
      timestamp: pixTx.createdAt,
      pixDetails: pixTx,
      isConfirmed: pixTx.completedTransfer,
    );
  }).toList();

  return Transaction(
    bitcoinTransactions: bitcoinTransactions,
    liquidTransactions: liquidTransactions,
    coinosTransactions: coinosTransactions,
    sideswapPegTransactions: sideswapPegTransactions,
    sideswapInstantSwapTransactions: sideswapInstantSwapTransactions,
    pixPurchaseTransactions: pixPurchases,
  );
});

final transactionNotifierProvider = StateNotifierProvider.autoDispose<TransactionModel, Transaction>((ref) {
  final initialTransactionsAsync = ref.watch(initializeTransactionsProvider);

  return initialTransactionsAsync.when(
    data: (transactions) => TransactionModel(transactions),
    loading: () => TransactionModel(
      Transaction(
        bitcoinTransactions: [],
        liquidTransactions: [],
        coinosTransactions: [],
        sideswapPegTransactions: [],
        sideswapInstantSwapTransactions: [],
        pixPurchaseTransactions: [],
      ),
    ),
    error: (error, stackTrace) {
      return TransactionModel(
        Transaction(
          bitcoinTransactions: [],
          liquidTransactions: [],
          coinosTransactions: [],
          sideswapPegTransactions: [],
          sideswapInstantSwapTransactions: [],
          pixPurchaseTransactions: [],
        ),
      );
    },
  );
});

final bitcoinTransactionsByDate = StateProvider.autoDispose<List<BitcoinTransaction>>((ref) {
  final dateTimeRange = ref.watch(dateTimeSelectProvider);
  final transactionState = ref.watch(transactionNotifierProvider);

  return transactionState.filterBitcoinTransactions(dateTimeRange);
});

final liquidTransactionsByDate = StateProvider.autoDispose<List<LiquidTransaction>>((ref) {
  final dateTimeRange = ref.watch(dateTimeSelectProvider);
  final transactionState = ref.watch(transactionNotifierProvider);

  return transactionState.filterLiquidTransactions(dateTimeRange);
});

final dateTimeSelectProvider = Provider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: now.subtract(Duration(days: 30)),
    end: now,
  );
});
