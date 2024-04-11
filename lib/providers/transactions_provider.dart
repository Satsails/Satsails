import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/transactions_model.dart';

final initializeTransactionsProvider = FutureProvider<Transaction>((ref) async {

  return Transaction(
    confirmedBitcoinTransactions: [],
    unConfirmedBitcoinTransactions: [],
    liquidTransactions: [],
  );
});

final transactionNotifierProvider = StateNotifierProvider<TransactionModel, Transaction>((ref) {
  final initialTransactions = ref.watch(initializeTransactionsProvider);

  return TransactionModel(initialTransactions.when(
    data: (transactions) => transactions,
    loading: () => Transaction(
      confirmedBitcoinTransactions: [],
      unConfirmedBitcoinTransactions: [],
      liquidTransactions: [],
    ),
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});