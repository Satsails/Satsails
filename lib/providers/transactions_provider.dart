import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:satsails/models/adapters/transaction_adapters.dart';
import 'package:satsails/models/transactions_model.dart';
import 'package:satsails/providers/bitcoin_provider.dart';
import 'package:satsails/providers/liquid_provider.dart';

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

final updateTransactionsProvider = FutureProvider.autoDispose<void>((ref) async {
  final bitcoinBox = await Hive.openBox('bitcoin');
  final transactionProvider = ref.read(transactionNotifierProvider.notifier);
  final bitcoinTransactions = await ref.refresh(getBitcoinTransactionsProvider.future);
  List<TransactionDetails> bitcoinTransactionsHive = bitcoinTransactions.map((transaction) => TransactionDetails.fromBdk(transaction)).toList();
  if (bitcoinTransactions.isNotEmpty) {
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