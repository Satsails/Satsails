import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/bitcoin_model.dart';
import 'bitcoin_config_provider.dart';

final bitcoinProvider = FutureProvider<Bitcoin>((ref) async {
  final blockchain = await ref.watch(initializeBlockchainProvider.future);
  final wallet = await ref.watch(restoreWalletProvider.future);

  return Bitcoin(wallet, blockchain);
});

final syncBitcoinProvider = FutureProvider.autoDispose<void>((ref) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
  await bitcoinModel.sync();
});

final asyncSyncBitcoinProvider = FutureProvider.autoDispose<void>((ref) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
  await bitcoinModel.asyncSync();
});

final addressProvider = FutureProvider<AddressInfo>((ref) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
  return await bitcoinModel.getAddress();
});

final getUnConfirmedTransactionsProvider = FutureProvider<List<TransactionDetails>>((ref) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
  return await bitcoinModel.getUnConfirmedTransactions();
});

final getConfirmedTransactionsProvider = FutureProvider<List<TransactionDetails>>((ref) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
  return await bitcoinModel.getConfirmedTransactions();
});

final getBalanceProvider = FutureProvider<Balance>((ref) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
  return await bitcoinModel.getBalance();
});

final unspentUtxosProvider = FutureProvider<List<LocalUtxo>>((ref) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  return await bitcoin.wallet.listUnspent();
});

final getPsbtInputProvider = FutureProvider<Input>((ref) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  final unspentUtxos = await ref.watch(unspentUtxosProvider.future);
  BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
  return await bitcoinModel.getPsbtInput(unspentUtxos.first, true);
});

final getFastFeeRateProvider = FutureProvider<FeeRate>((ref) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
  return await bitcoinModel.estimateFeeRate(1);
});

final getMediumFeeRateProvider = FutureProvider<FeeRate>((ref) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
  return await bitcoinModel.estimateFeeRate(3);
});

final getSlowFeeRateProvider = FutureProvider<FeeRate>((ref) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
  return await bitcoinModel.estimateFeeRate(6);
});

final getCustomFeeRateProvider = FutureProvider.family.autoDispose<FeeRate, int>((ref, blocks) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
  return await bitcoinModel.estimateFeeRate(blocks);
});

final sendProvider = FutureProvider.family.autoDispose<void, SendParams>((ref, params) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
  FeeRate feeRate = await ref.watch(getCustomFeeRateProvider(params.blocks).future);
  await bitcoinModel.sendBitcoin(params.address, feeRate);
});