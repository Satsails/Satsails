import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/address_model.dart';
import 'package:satsails/models/balance_model.dart';
import 'package:satsails/models/bitcoin_model.dart' as bitcoinModel;
import 'package:satsails/models/liquid_model.dart' as liquidModel;
import 'package:satsails/models/send_tx_model.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/bitcoin_provider.dart' as bitcoinProvider;
import 'package:satsails/providers/liquid_provider.dart' as liquidProvider;
import 'package:satsails/providers/settings_provider.dart';

final sendTxProvider = StateNotifierProvider<SendTxModel, SendTx>((ref) {
  return SendTxModel(SendTx(address: '', amount: 0, type: PaymentType.Unknown, assetId: '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d'));
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
  final transaction =  await ref.read(bitcoinProvider.buildBitcoinTransactionProvider(transactionBuilder).future).then((value) => value);
  return transaction.txDetails.fee!;
});

final bitcoinTransactionBuilderProvider =  FutureProvider.autoDispose.family<bitcoinModel.TransactionBuilder, int>((ref, amount) async {
  final FeeRate fee = await ref.read(bitcoinProvider.getCustomFeeRateProvider.future).then((value) => value);
  final address = ref.watch(sendTxProvider.notifier).state.address;
  return bitcoinModel.TransactionBuilder(amount, address, fee);
});

final liquidFeeProvider = FutureProvider.autoDispose<int>((ref) async {
  final FeeCalculationParams params = ref.watch(feeParamsProvider);
  final transactionBuilder = await ref.read(liquidTransactionBuilderProvider(params.amount).future).then((value) => value);
  final transaction = await ref.read(liquidProvider.buildLiquidTransactionProvider(transactionBuilder).future).then((value) => value);
  final decodedPset = await ref.read(liquidProvider.decodeLiquidPsetProvider(transaction).future).then((value) => value);
  return decodedPset.fee;
});

final liquidAssetFeeProvider = FutureProvider.autoDispose<int>((ref) async {
  final FeeCalculationParams params = ref.watch(feeParamsProvider);
  final transactionBuilder = await ref.read(liquidTransactionBuilderProvider(params.amount).future).then((value) => value);
  final transaction = await ref.read(liquidProvider.buildLiquidAssetTransactionProvider(transactionBuilder).future).then((value) => value);
  final decodedPset = await ref.read(liquidProvider.decodeLiquidPsetProvider(transaction).future).then((value) => value);
  return decodedPset.fee;
});

final liquidTransactionBuilderProvider =  FutureProvider.autoDispose.family<liquidModel.TransactionBuilder, int>((ref, amount) async {
  final double fee = await ref.read(liquidProvider.getCustomFeeRateProvider.future).then((value) => value);
  final address = ref.watch(sendTxProvider.notifier).state.address;
  final asset = ref.watch(sendTxProvider).assetId;
  return liquidModel.TransactionBuilder(amount: amount, outAddress: address, fee: fee, assetId: asset!);
});


final inputValueProvider = StateProvider.autoDispose<double>((ref) {
  final sendTxState = ref.watch(sendTxProvider);
  if (sendTxState.amount != 0) {
    ref.read(sendAmountProvider.notifier).state = sendTxState.amount;
    return (sendTxState.amount / 100000000);
  }else {
    return 0;
  }
});

final showBitcoinRelatedWidgetsProvider = StateProvider.autoDispose<bool>((ref) {
  final sendTxState = ref.watch(sendTxProvider);
  switch (sendTxState.assetId) {
    case '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d':
      return true;
    case '02f22f8d9c76ab41661a2729e4752e2c5d1a263012141b86ea98af5472df5189':
      return false;
    case 'ce091c998b83c78bb71a632313ba3760f1763d9cfcffae02258ffa9865a37bd2':
      return false;
    case '18729918ab4bca843656f08d4dd877bed6641fbd596a0a963abbf199cfeb3cec':
      return false;
    default:
      return true;
  }
});

final currentCardIndexProvider = StateProvider.autoDispose<int>((ref) {
  final sendTxState = ref.watch(sendTxProvider);
  switch (sendTxState.assetId) {
    case '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d':
      return 0;
    case '02f22f8d9c76ab41661a2729e4752e2c5d1a263012141b86ea98af5472df5189':
      return 1;
    case 'ce091c998b83c78bb71a632313ba3760f1763d9cfcffae02258ffa9865a37bd2':
      return 2;
    case '18729918ab4bca843656f08d4dd877bed6641fbd596a0a963abbf199cfeb3cec':
      return 3;
    default:
      return 0;
  }
});

final assetBalanceProvider = StateProvider.autoDispose<int>((ref) {
  final currentCardIndex = ref.watch(currentCardIndexProvider.notifier);
  final balance = ref.read(balanceNotifierProvider);
  switch (currentCardIndex.state) {
    case 0:
      return balance.liquidBalance;
    case 1:
      return balance.brlBalance;
    case 2:
      return balance.usdBalance;
    case 3:
      return balance.eurBalance;
    default:
      return balance.liquidBalance;
  }
});


class FeeCalculationParams {
  final int amount;
  final int blocks;

  FeeCalculationParams(this.amount, this.blocks);
}
