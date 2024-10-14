import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionSearchModel {
  bool? isLiquid;
  String? txid;
  int? amount;
  String? assetId;
  String? amountBlinder;
  String? assetBlinder;

  TransactionSearchModel({
    this.isLiquid,
    this.txid,
    this.amount,
    this.assetId,
    this.amountBlinder,
    this.assetBlinder,
  });

  TransactionSearchModel copyWith({
    bool? isLiquid,
    String? txid,
    int? amount,
    String? assetId,
    String? amountBlinder,
    String? assetBlinder,
  }) {
    return TransactionSearchModel(
      isLiquid: isLiquid ?? this.isLiquid,
      txid: txid ?? this.txid,
      amount: amount ?? this.amount,
      assetId: assetId ?? this.assetId,
      amountBlinder: amountBlinder ?? this.amountBlinder,
      assetBlinder: assetBlinder ?? this.assetBlinder,
    );
  }

  // Method to clear all fields
  TransactionSearchModel clear() {
    return TransactionSearchModel();
  }
}


final transactionSearchProvider = StateProvider<TransactionSearchModel>((ref) {
  return TransactionSearchModel();
});

// Function to clear the provider state
void clearTransactionSearch(WidgetRef ref) {
  ref.read(transactionSearchProvider.notifier).update((state) => state.clear());
}
