import 'package:Satsails/models/transfer_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionDetailsNotifier extends StateNotifier<Transfer> {
  TransactionDetailsNotifier() : super(Transfer.empty());

  void setTransaction(Transfer transaction) {
    state = transaction;
  }

  void clearTransaction() {
    state = Transfer.empty();
  }
}

final singleTransactionDetailsProvider = StateNotifierProvider<TransactionDetailsNotifier, Transfer>((ref) {
  return TransactionDetailsNotifier();
});

