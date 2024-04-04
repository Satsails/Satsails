import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/bitcoin_model.dart';
import 'package:satsails/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bitcoin_config_provider.dart';

final bitcoinProvider = FutureProvider<Bitcoin>((ref) async {
  final wallet = await ref.watch(restoreWalletProvider.future);
  final settings = ref.read(onlineProvider.notifier);
  try {
    final blockchain = await ref.watch(initializeBlockchainProvider.future);
    settings.state = true;
    return Bitcoin(wallet, blockchain);
  } catch (e) {
    settings.state = false;
    return Bitcoin(wallet, null);
  }
});

final syncBitcoinProvider = FutureProvider.autoDispose<void>((ref) async {
  final settings = ref.read(onlineProvider.notifier);
  final bitcoin = await ref.watch(bitcoinProvider.future);
  if (settings.state) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    await bitcoinModel.sync();
  } else {
    throw Exception('No internet connection');
  }
});

final asyncSyncBitcoinProvider = FutureProvider.autoDispose<void>((ref) async {
  final settings = ref.watch(onlineProvider);
  final bitcoin = await ref.watch(bitcoinProvider.future);
  if (settings) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    await bitcoinModel.asyncSync();
  } else {
    throw Exception('No internet connection');
  }
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

final updateTransactionsProvider = FutureProvider.autoDispose<void>((ref) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  await ref.watch(syncBitcoinProvider.future);
  BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
  await bitcoinModel.getConfirmedTransactions();
  await bitcoinModel.getUnConfirmedTransactions();
});

final getBalanceProvider = FutureProvider<Balance>((ref) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
  return await bitcoinModel.getBalance();
});

final updateBitcoinBalanceProvider = FutureProvider.autoDispose<int>((ref) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  await ref.watch(syncBitcoinProvider.future);
  BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
  final balance = await bitcoinModel.getBalance();
  final prefs = await SharedPreferences.getInstance();
  if (balance.total == 0 || !ref.watch(onlineProvider)) {
    return prefs.getInt('latestBitcoinBalance') ?? 0;
  } else {
    return balance.total;
  }
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

final getFastFeeRateProvider = FutureProvider.autoDispose<FeeRate>((ref) async {
  final settings = ref.watch(onlineProvider);
  final bitcoin = await ref.watch(bitcoinProvider.future);
  if (settings) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return await bitcoinModel.estimateFeeRate(1);
  } else {
    throw Exception('No internet connection');
  }
});

final getMediumFeeRateProvider = FutureProvider.autoDispose<FeeRate>((ref) async {
  final settings = ref.watch(onlineProvider);
  final bitcoin = await ref.watch(bitcoinProvider.future);
  if (settings) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return await bitcoinModel.estimateFeeRate(3);
  } else {
    throw Exception('No internet connection');
  }
});

final getSlowFeeRateProvider = FutureProvider.autoDispose<FeeRate>((ref) async {
  final settings = ref.watch(onlineProvider);
  final bitcoin = await ref.watch(bitcoinProvider.future);
  if (settings) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return await bitcoinModel.estimateFeeRate(6);
  } else {
    throw Exception('No internet connection');
  }
});

final getCustomFeeRateProvider = FutureProvider.family.autoDispose<FeeRate, int>((ref, blocks) async {
  final settings = ref.watch(onlineProvider);
  final bitcoin = await ref.watch(bitcoinProvider.future);
  if (settings) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return await bitcoinModel.estimateFeeRate(blocks);
  } else {
    throw Exception('No internet connection');
  }
});

final sendProvider = FutureProvider.family.autoDispose<void, SendParams>((ref, params) async {
  final settings = ref.watch(onlineProvider);
  final bitcoin = await ref.watch(bitcoinProvider.future);
  if (settings) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    FeeRate feeRate = await ref.watch(getCustomFeeRateProvider(params.blocks).future);
    await bitcoinModel.sendBitcoin(params.address, feeRate);
  } else {
    throw Exception('No internet connection');
  }
});