import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lwk/lwk.dart';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/models/bitcoin_model.dart' as bitcoinModel;
import 'package:Satsails/models/liquid_model.dart' as liquidModel;
import 'package:Satsails/models/send_tx_model.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart' as bitcoinProvider;
import 'package:Satsails/providers/liquid_provider.dart' as liquidProvider;
import 'package:Satsails/providers/settings_provider.dart';

final sendTxProvider = StateNotifierProvider<SendTxModel, SendTx>((ref) {
  return SendTxModel(SendTx(address: '', amount: 0, type: PaymentType.Unknown, assetId: AssetMapper.reverseMapTicker(AssetId.LBTC), drain: false));
});

final sendBlocksProvider = StateProvider.autoDispose<double>((ref) {
  return 1;
});

final currencyParamsProvider = StateProvider.autoDispose<CurrencyParams>((ref) {
  final currency = ref.watch(settingsProvider).currency;
  final sendAmount = ref.watch(sendTxProvider).amount;
  return CurrencyParams(currency, sendAmount.toInt());
});

final feeParamsProvider = StateProvider.autoDispose<FeeCalculationParams>((ref) {
  final sendAmount = ref.watch(sendTxProvider).amount;
  final sendBlocks = ref.watch(sendBlocksProvider);
  return FeeCalculationParams(sendAmount, sendBlocks.toInt());
});

final feeCurrencyParamsProvider = FutureProvider.autoDispose<CurrencyParams>((ref) async {
  final currency = ref.watch(settingsProvider).currency;
  final fee = await ref.watch(feeProvider.future).then((value) => value);
  return CurrencyParams(currency, fee);
});

final liquidFeeCurrencyParamsProvider = FutureProvider.autoDispose<CurrencyParams>((ref) async {
  final currency = ref.watch(settingsProvider).currency;
  final fee = await ref.watch(liquidFeeProvider.future).then((value) => value);
  return CurrencyParams(currency, fee);
});

final liquidFeeValueInCurrencyProvider = FutureProvider.autoDispose<double>((ref) async {
  final currencyParams = await ref.watch(liquidFeeCurrencyParamsProvider.future).then((value) => value);
  return ref.read(currentBitcoinPriceInCurrencyProvider(currencyParams));
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
  return (transaction.$1.feeAmount() ?? BigInt.zero).toInt();
});

final bitcoinTransactionBuilderProvider =  FutureProvider.autoDispose.family<bitcoinModel.TransactionBuilder, int>((ref, amount) async {
  final double fee = await ref.read(bitcoinProvider.getCustomFeeRateProvider.future).then((value) => value);
  final address = ref.watch(sendTxProvider).address;
  return bitcoinModel.TransactionBuilder(amount, address, fee);
});

final liquidFeeProvider = FutureProvider.autoDispose<int>((ref) async {
  final asset = ref.watch(sendTxProvider).assetId;
  final drain = ref.watch(sendTxProvider).drain;
  final FeeCalculationParams params = ref.watch(feeParamsProvider);
  final transactionBuilder = await ref.read(liquidTransactionBuilderProvider(params.amount).future).then((value) => value);
  if (asset == AssetMapper.reverseMapTicker(AssetId.LBTC)) {
    if (drain) {
      final transaction = await ref.read(liquidProvider.buildDrainLiquidTransactionProvider(transactionBuilder).future).then((value) => value);
      final decodedPset = await ref.read(liquidProvider.decodeLiquidPsetProvider(transaction).future).then((value) => value);
      return decodedPset.absoluteFees.toInt();
    }
    final transaction = await ref.read(liquidProvider.buildLiquidTransactionProvider(transactionBuilder).future).then((value) => value);
    final decodedPset = await ref.read(liquidProvider.decodeLiquidPsetProvider(transaction).future).then((value) => value);
    return decodedPset.absoluteFees.toInt();
  } else {
    if (!ref.watch(isPayjoin)) {
      final transaction = await ref.read(liquidProvider.buildLiquidAssetTransactionProvider(transactionBuilder).future).then((value) => value);
      final decodedPset = await ref.read(liquidProvider.decodeLiquidPsetProvider(transaction).future).then((value) => value);
      return decodedPset.absoluteFees.toInt();
    } else{
      final transaction = await ref.read(liquidProvider.buildLiquidPayjoinTransactionProvider(transactionBuilder).future).then((value) => value);
      return transaction.networkFee.toInt();
    }
  }
});

final payjoinFeeProvider = FutureProvider.autoDispose<String>((ref) async {
    final FeeCalculationParams params = ref.watch(feeParamsProvider);
    final transactionBuilder = await ref.read(liquidTransactionBuilderProvider(params.amount).future);
    final transaction = await ref.read(liquidProvider.buildLiquidPayjoinTransactionProvider(transactionBuilder).future);
    final feeInSatoshis = transaction.assetFee.toInt(); // Ensure integer
    final feeInBtc = feeInSatoshis / 100000000; // Convert satoshis to BTC
    return feeInBtc.toStringAsFixed(2); // Format to 2 decimal places (e.g., "0.01")
});


final liquidDrainWalletProvider = FutureProvider.autoDispose<PsetAmounts>((ref) async {
  final asset = ref.watch(sendTxProvider).assetId;
  if (asset == AssetMapper.reverseMapTicker(AssetId.LBTC)) {
    final transactionBuilder = await ref.read(liquidTransactionBuilderProvider(ref.watch(assetBalanceProvider)).future).then((value) => value);
    final transaction = await ref.read(liquidProvider.buildDrainLiquidTransactionProvider(transactionBuilder).future).then((value) => value);
    return await ref.read(liquidProvider.decodeLiquidPsetProvider(transaction).future).then((value) => value);
  } else {
    final transactionBuilder = await ref.read(liquidTransactionBuilderProvider(ref.watch(assetBalanceProvider)).future).then((value) => value);
    final transaction = await ref.read(liquidProvider.buildLiquidAssetTransactionProvider(transactionBuilder).future).then((value) => value);
    return await ref.read(liquidProvider.decodeLiquidPsetProvider(transaction).future).then((value) => value);
  }
});

final liquidAssetFeeProvider = FutureProvider.autoDispose<int>((ref) async {
  final FeeCalculationParams params = ref.watch(feeParamsProvider);
  final transactionBuilder = await ref.read(liquidTransactionBuilderProvider(params.amount).future).then((value) => value);
  final transaction = await ref.read(liquidProvider.buildLiquidAssetTransactionProvider(transactionBuilder).future).then((value) => value);
  final decodedPset = await ref.read(liquidProvider.decodeLiquidPsetProvider(transaction).future).then((value) => value);
  return decodedPset.absoluteFees.toInt();
});

final liquidTransactionBuilderProvider =  FutureProvider.autoDispose.family<liquidModel.TransactionBuilder, int>((ref, amount) async {
  final double fee = await ref.read(liquidProvider.getCustomFeeRateProvider.future).then((value) => value);
  final address = ref.watch(sendTxProvider).address;
  final asset = ref.watch(sendTxProvider).assetId;
  return liquidModel.TransactionBuilder(amount: amount, outAddress: address, fee: fee, assetId: asset);
});

final assetBalanceProvider = Provider.autoDispose<int>((ref) {
  final assetId = ref.watch(sendTxProvider).assetId; // String hash from sendTxProvider
  final balance = ref.watch(balanceNotifierProvider); // Use watch for reactivity

  // Map the assetId string to an AssetId enum value
  final mappedAsset = AssetMapper.mapAsset(assetId);

  // Return the corresponding balance based on the mapped AssetId
  switch (mappedAsset) {
    case AssetId.LBTC:
      return balance.liquidBalance;
    case AssetId.BRL:
      return balance.brlBalance;
    case AssetId.USD:
      return balance.usdBalance;
    case AssetId.EUR:
      return balance.eurBalance;
    case AssetId.UNKNOWN:
    default:
      return balance.liquidBalance; // Fallback to liquidBalance for unknown assets
  }
});

String getTimeFrame(int blocks, WidgetRef ref) {
  switch (blocks) {
    case 1:
      return '10 minutes'.i18n;
    case 2:
      return '30 minutes'.i18n;
    case 3:
      return '1 hour'.i18n;
    case 4:
      return 'Days'.i18n;
    case 5:
      return 'Weeks'.i18n;
    default:
      return 'Invalid number of blocks.'.i18n;
  }
}


class FeeCalculationParams {
  final int amount;
  final int blocks;

  FeeCalculationParams(this.amount, this.blocks);
}
