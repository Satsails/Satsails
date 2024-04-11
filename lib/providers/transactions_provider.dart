import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:satsails/models/transactions_model.dart';

final initializeTransactionsProvider = FutureProvider<Transaction>((ref) async {
  final bitcoinBox = await Hive.openBox('bitcoin');
  final liquidBox = await Hive.openBox('liquid');
  final bitcoinTransactions = bitcoinBox.get('bitcoinTransactions', defaultValue: []);
  final liquidTransactions = liquidBox.get('liquidTransactions', defaultValue: []);

  return Transaction(
    bitcoinTransactions: bitcoinTransactions,
    liquidTransactions: liquidTransactions,
  );
});

final transactionNotifierProvider = StateNotifierProvider<TransactionModel, Transaction>((ref) {
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