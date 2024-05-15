import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/datetime_range_model.dart';

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

  List<dynamic> get allTransactionsSorted {
    final allTransactions = this.allTransactions;
    allTransactions.sort((a, b) {
      if (a['confirmationTime'] == null && b['confirmationTime'] != null) {
        return -1;
      } else if (a['confirmationTime'] != null && b['confirmationTime'] == null) {
        return 1;
      } else {
        return 0;
      }
    });
    return allTransactions;
  }

  List<dynamic> filterBitcoinTransactions(DateTimeSelect range) {
    return bitcoinTransactions.where((transaction) {
      final confirmationTime = transaction.confirmationTime;
      if (confirmationTime == null || confirmationTime.timestamp == 0) {
        return true;
      }
      return confirmationTime.timestamp > range.start && confirmationTime.timestamp < range.end;
    }).toList();

  }

  List<dynamic> filterLiquidTransactions(DateTimeSelect range) {
    return liquidTransactions.where((transaction) {
      final confirmationTime =  transaction.timestamp;
      if (confirmationTime == null) {
        return false;
      }
      return confirmationTime > range.start && confirmationTime < range.end;
    }).toList();
  }
}