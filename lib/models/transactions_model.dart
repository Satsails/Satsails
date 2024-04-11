import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionModel extends StateNotifier<Transaction>{
  TransactionModel(super.state);

  void updateBitcoinTransactions(List<dynamic> bitcoinTransactions){
    state = state.copyWith(bitcoinTransactions: bitcoinTransactions);
  }

  void updateLiquidTransactions(List<dynamic> liquidTransactions){
    state = state.copyWith(liquidTransactions: liquidTransactions);
  }
}

class Transaction {
  List<dynamic> bitcoinTransactions;
  List<dynamic> liquidTransactions;

  Transaction({
    required this.bitcoinTransactions,
    required this.liquidTransactions,
  });

  Transaction copyWith({
    List<dynamic>? bitcoinTransactions,
    List<dynamic>? liquidTransactions,
  }) {
    return Transaction(
      bitcoinTransactions: bitcoinTransactions ?? this.bitcoinTransactions,
      liquidTransactions: liquidTransactions ?? this.liquidTransactions,
    );
  }

  List<dynamic> get allTransactions {
    return [
      ...bitcoinTransactions,
      ...liquidTransactions,
    ];
  }
}