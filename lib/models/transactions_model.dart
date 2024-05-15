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
    var filteredTransactions = bitcoinTransactions.where((transaction) {
      final confirmationTime = transaction.confirmationTime;
      if (confirmationTime == null || confirmationTime.timestamp == 0) {
        return true;
      }
      return confirmationTime.timestamp > range.start && confirmationTime.timestamp < range.end;
    }).toList();

    filteredTransactions.sort((a, b) {
      if (a.confirmationTime == null || a.confirmationTime.timestamp == 0) {
        return -1;
      } else if (b.confirmationTime == null || b.confirmationTime.timestamp == 0) {
        return 1;
      } else {
        return b.confirmationTime.timestamp.compareTo(a.confirmationTime.timestamp);
      }
    });

    return filteredTransactions;
  }

  List<dynamic> filterLiquidTransactions(DateTimeSelect range) {
    var filteredTransactions = liquidTransactions.where((transaction) {
      final confirmationTime = transaction.timestamp;
      if (confirmationTime == null) {
        return true;
      }
      return confirmationTime > range.start && confirmationTime < range.end;
    }).toList();

    filteredTransactions.sort((a, b) {
      if (a.timestamp == null) {
        return -1;
      } else if (b.timestamp == null) {
        return 1;
      } else {
        return b.timestamp.compareTo(a.timestamp);
      }
    });

    return filteredTransactions;
  }
}