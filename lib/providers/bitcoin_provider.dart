import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/bitcoin_model.dart';
import 'bitcoin_config_provider.dart';

final bitcoinProvider = FutureProvider<Bitcoin>((ref) async {
  Wallet wallet = await ref.watch(restoreWalletProvider.future);
  try {
    Blockchain blockchain = await ref.watch(initializeBlockchainProvider.future);
    return Bitcoin(wallet, blockchain);
  } catch (e) {
    return Bitcoin(wallet, null);
  }
});

final syncBitcoinProvider = FutureProvider.autoDispose<void>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.sync();
  });
});

final bitcoinAddressProvider = FutureProvider.autoDispose<AddressInfo>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.getAddress();
  });
});
// maybe implement into static addresses service.
final bitcoinAddressWithAmountProvider = FutureProvider.autoDispose.family<String, int>((ref, amount) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.getAddressWithAmount(amount);
  });
});

final getBitcoinTransactionsProvider = FutureProvider<List<TransactionDetails>>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.getTransactions();
  });
});

final getBitcoinBalanceProvider = FutureProvider<Balance>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.getBalance();
  });
});

final unspentUtxosProvider = FutureProvider<List<LocalUtxo>>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    return bitcoin.wallet.listUnspent();
  });
});

final getPsbtInputProvider = FutureProvider<Input>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) async {
    final unspentUtxos = await ref.watch(unspentUtxosProvider.future);
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.getPsbtInput(unspentUtxos.first, true);
  });
});

final getFastFeeRateProvider = FutureProvider.autoDispose<FeeRate>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.estimateFeeRate(1);
  });
});

final getMediumFeeRateProvider = FutureProvider.autoDispose<FeeRate>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.estimateFeeRate(3);
  });
});

final getSlowFeeRateProvider = FutureProvider.autoDispose<FeeRate>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.estimateFeeRate(6);
  });
});

final getCustomFeeRateProvider = FutureProvider.family.autoDispose<FeeRate, int>((ref, blocks) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.estimateFeeRate(blocks);
  });
});

final sendBitcoinProvider = FutureProvider.family.autoDispose<void, SendParams>((ref, params) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) async {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    FeeRate feeRate = await ref.watch(getCustomFeeRateProvider(params.blocks).future);
    return bitcoinModel.sendBitcoin(params.address, feeRate);
  });
});