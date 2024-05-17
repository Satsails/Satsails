import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionSearchModel {
  bool? isLiquid;
  String? txid;
  int? amount;
  String? assetId;
  String? amountBlinder;
  String? assetBlinder;


  TransactionSearchModel({this.isLiquid, this.txid, this.amount, this.assetId, this.amountBlinder, this.assetBlinder});
}

final transactionSearchProvider = StateProvider<TransactionSearchModel>((ref) {
  return TransactionSearchModel();
});
