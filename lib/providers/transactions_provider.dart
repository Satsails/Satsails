import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:Satsails/models/adapters/transaction_adapters.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';

final initializeTransactionsProvider = FutureProvider.autoDispose<Transaction>((ref) async {
  final bitcoinBox = await Hive.openBox('bitcoin');
  final liquidBox = await Hive.openBox('liquid');
  final bitcoinTransactions = bitcoinBox.get('bitcoinTransactions', defaultValue: []);
  final liquidTransactions = liquidBox.get('liquidTransactions', defaultValue: []);

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
      bitcoinTransactions: [],
      liquidTransactions: [],
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

final updateTransactionsProvider = FutureProvider.autoDispose<void>((ref) async {
  final bitcoinBox = await Hive.openBox('bitcoin');
  final transactionProvider = ref.read(transactionNotifierProvider.notifier);
  final bitcoinTransactions = await ref.refresh(getBitcoinTransactionsProvider.future);
  List<TransactionDetails> bitcoinTransactionsHive = bitcoinTransactions.map((transaction) => TransactionDetails.fromBdk(transaction)).toList();
  if (bitcoinTransactions.isNotEmpty) {
    bitcoinTransactionsHive.sort((a, b) {
      if (a.confirmationTime == null && b.confirmationTime != null) {
        return 1;
      } else if (a.confirmationTime != null && b.confirmationTime == null) {
        return -1;
      } else if (a.confirmationTime != null && b.confirmationTime != null) {
        // If both transactions are confirmed, sort by timestamp.
        // The most recent transaction (with the larger timestamp) should come first.
        return b.confirmationTime!.timestamp.compareTo(a.confirmationTime!.timestamp);
      } else {
        // If both transactions are unconfirmed, they are considered equal for sorting purposes.
        return 0;
      }
    });

    bitcoinBox.put('bitcoinTransactions', bitcoinTransactionsHive);
    transactionProvider.updateBitcoinTransactions(bitcoinTransactionsHive);
  }
  final liquidTransactions = await ref.refresh(liquidTransactionsProvider.future);
  final liquidBox = await Hive.openBox('liquid');
  List<Tx> liquidTransactionsHive = liquidTransactions.map((transaction) => Tx.fromLwk(transaction)).toList();
  if (liquidTransactions.isNotEmpty) {
    liquidBox.put('liquidTransactions', liquidTransactionsHive);
    transactionProvider.updateLiquidTransactions(liquidTransactionsHive);
  }
});
