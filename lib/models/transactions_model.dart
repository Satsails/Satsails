import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionModel extends StateNotifier<Transaction>{
  TransactionModel(super.state);

  void updateConfirmedBitcoinTransactions(List<dynamic> confirmedBitcoinTransactions){
    state = state.copyWith(confirmedBitcoinTransactions: confirmedBitcoinTransactions);
  }

  void updateUnConfirmedBitcoinTransactions(List<dynamic> unConfirmedBitcoinTransactions){
    state = state.copyWith(unConfirmedBitcoinTransactions: unConfirmedBitcoinTransactions);
  }

  void updateLiquidTransactions(List<dynamic> liquidTransactions){
    state = state.copyWith(liquidTransactions: liquidTransactions);
  }
}

class Transaction {
  List<dynamic> confirmedBitcoinTransactions;
  List<dynamic> unConfirmedBitcoinTransactions;
  List<dynamic> liquidTransactions;

  Transaction({
    required this.confirmedBitcoinTransactions,
    required this.unConfirmedBitcoinTransactions,
    required this.liquidTransactions,
  });

  Transaction copyWith({
    List<dynamic>? confirmedBitcoinTransactions,
    List<dynamic>? unConfirmedBitcoinTransactions,
    List<dynamic>? liquidTransactions,
  }) {
    return Transaction(
      confirmedBitcoinTransactions: confirmedBitcoinTransactions ?? this.confirmedBitcoinTransactions,
      unConfirmedBitcoinTransactions: unConfirmedBitcoinTransactions ?? this.unConfirmedBitcoinTransactions,
      liquidTransactions: liquidTransactions ?? this.liquidTransactions,
    );
  }

  List<dynamic> get allTransactions {
    return [
      ...confirmedBitcoinTransactions,
      ...unConfirmedBitcoinTransactions,
      ...liquidTransactions,
    ];
  }

  List<dynamic> get allBitcoinTransactions {
    return [
      ...confirmedBitcoinTransactions,
      ...unConfirmedBitcoinTransactions,
    ];
  }
}