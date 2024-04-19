import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/address_model.dart';
import 'package:satsails/models/balance_model.dart';
import 'package:satsails/models/bitcoin_model.dart';
import 'package:satsails/models/send_tx_model.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/bitcoin_provider.dart';
import 'package:satsails/providers/settings_provider.dart';

final sendTxProvider = StateNotifierProvider<SendTxModel, SendTx>((ref) {
  return SendTxModel(SendTx(address: '', amount: 0, type: PaymentType.Unknown, assetId: ''));
});

final sendBlocksProvider = StateProvider<double>((ref) {
  return 1;
});

final sendAmountProvider = StateProvider<int>((ref) {
  return 0;
});

final currencyParamsProvider = StateProvider.autoDispose<CurrencyParams>((ref) {
  final currency = ref.watch(settingsProvider).currency;
  final sendAmount = ref.watch(sendAmountProvider);
  return CurrencyParams(currency, sendAmount.toInt());
});

final feeParamsProvider = StateProvider.autoDispose<FeeCalculationParams>((ref) {
  final sendAmount = ref.watch(sendAmountProvider);
  final sendBlocks = ref.watch(sendBlocksProvider);
  return FeeCalculationParams(sendAmount, sendBlocks.toInt());
});

final feeCurrencyParamsProvider = FutureProvider.autoDispose<CurrencyParams>((ref) async {
  final currency = ref.watch(settingsProvider).currency;
  final fee = await ref.watch(feeProvider.future).then((value) => value);
  return CurrencyParams(currency, fee);
});

final feeValueInCurrencyProvider = FutureProvider.autoDispose<double>((ref) async {
  final currencyParams = await ref.watch(feeCurrencyParamsProvider.future).then((value) => value);
  return ref.read(currentBitcoinPriceInCurrencyProvider(currencyParams));
});

final bitcoinValueInCurrencyProvider = StateProvider.autoDispose<double>((ref) {
  final currencyParams = ref.watch(currencyParamsProvider);
  return ref.read(currentBitcoinPriceInCurrencyProvider(currencyParams));
});

final feeProvider = FutureProvider.autoDispose<int>((ref) async {
  final FeeCalculationParams params = ref.watch(feeParamsProvider);
  final transactionBuilder = await ref.read(bitcoinTransactionBuilderProvider(params.amount).future).then((value) => value);
  final transaction =  await ref.read(buildBitcoinTransactionProvider(transactionBuilder).future).then((value) => value);
  return transaction.txDetails.fee!;
});

final bitcoinTransactionBuilderProvider =  FutureProvider.autoDispose.family<TransactionBuilder, int>((ref, amount) async {
  final FeeRate fee = await ref.read(getCustomFeeRateProvider.future).then((value) => value);
  final address = ref.watch(sendTxProvider.notifier).state.address;
  return TransactionBuilder(amount, address, fee);
});


class FeeCalculationParams {
  final int amount;
  final int blocks;

  FeeCalculationParams(this.amount, this.blocks);
}
