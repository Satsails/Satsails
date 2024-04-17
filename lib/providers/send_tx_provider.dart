import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/address_model.dart';
import 'package:satsails/models/send_tx_model.dart';

final sendTxProvider = StateNotifierProvider<SendTxModel, SendTx>((ref) {
  return SendTxModel(SendTx(address: '', amount: 0, type: PaymentType.Unknown, assetId: ''));
});

final sendCurrencyProvider = StateProvider<String>((ref) {
  return 'btc';
});

final sendBlocksProvider = StateProvider<double>((ref) {
  return 1;
});
