import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionSearchModel {
  bool? isLiquid;
  String? transactionHash;

  TransactionSearchModel({this.isLiquid, this.transactionHash});
}

final transactionSearchProvider = StateProvider<TransactionSearchModel>((ref) {
  return TransactionSearchModel();
});
