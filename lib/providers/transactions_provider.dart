import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:lwk_dart/lwk_dart.dart' as lwk;

import 'liquid_provider.dart';

final initializeTransactionsProvider = FutureProvider.autoDispose<Transaction>((ref) async {
  final bitcoinTransactions = await ref.watch(getBitcoinTransactionsProvider.future);
  final liquidTransactions = await ref.watch(liquidTransactionsProvider.future);

  return Transaction(
    bitcoinTransactions: bitcoinTransactions,
    liquidTransactions: liquidTransactions,
  );
});

final transactionNotifierProvider = StateNotifierProvider.autoDispose<TransactionModel, Transaction>((ref) {
  final initialTransactions = ref.watch(initializeTransactionsProvider);

  return TransactionModel(initialTransactions.when(
    data: (transactions) => transactions,
    loading: () => Transaction(
      bitcoinTransactions: [const bdk.TransactionDetails(
        transaction: null,
        txid: '',
        received: 0,
        sent: 0,
        fee: null,
        confirmationTime: null,
      )],
      liquidTransactions: [const lwk.Tx(
        txid: '',
        balances: [],
        kind: '',
        fee: 0,
        height: 0,
        inputs: [],
        outputs: [],
        timestamp: 0,
        unblindedUrl: '',
        vsize: 0,
      )],
    ),
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});


final bitcoinTransactionsByDate = StateProvider.autoDispose<List<dynamic>>((ref) {
  final dateTimeRange = ref.watch(dateTimeSelectProvider);
  return ref.watch(transactionNotifierProvider).filterBitcoinTransactions(dateTimeRange);
});

final liquidTransactionsByDate = StateProvider.autoDispose<List<dynamic>>((ref) {
  final dateTimeRange = ref.watch(dateTimeSelectProvider);
  return ref.watch(transactionNotifierProvider).filterLiquidTransactions(dateTimeRange);
});


