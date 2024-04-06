import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/bitcoin_model.dart';
import 'package:satsails/providers/settings_provider.dart';
import 'bitcoin_config_provider.dart';

final bitcoinProvider = FutureProvider<Bitcoin>((ref) {
  return ref.watch(restoreWalletProvider.future).then((wallet) {
    final settings = ref.read(onlineProvider.notifier);
    return ref.watch(initializeBlockchainProvider.future).then((blockchain) {
      settings.state = true;
      return Bitcoin(wallet, blockchain);
    }).catchError((e) {
      settings.state = false;
      return Bitcoin(wallet, null);
    });
  });
});

final syncBitcoinProvider = FutureProvider.autoDispose<void>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    final settings = ref.read(onlineProvider.notifier);
    if (settings.state) {
      BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
      return bitcoinModel.sync();
    }
  });
});

final addressProvider = FutureProvider.autoDispose<AddressInfo>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.getAddress();
  });
});

final getUnConfirmedTransactionsProvider = FutureProvider<List<TransactionDetails>>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.getUnConfirmedTransactions();
  });
});

final getConfirmedTransactionsProvider = FutureProvider<List<TransactionDetails>>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.getConfirmedTransactions();
  });
});

final updateTransactionsProvider = FutureProvider.autoDispose<void>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) async {
    await ref.watch(syncBitcoinProvider.future);
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    await bitcoinModel.getConfirmedTransactions();
    await bitcoinModel.getUnConfirmedTransactions();
  });
});

final getBalanceProvider = FutureProvider<Balance>((ref) {
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
    final settings = ref.watch(onlineProvider);
    if (settings) {
      BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
      return bitcoinModel.estimateFeeRate(1);
    } else {
      throw Exception('Offline');
    }
  });
});

final getMediumFeeRateProvider = FutureProvider.autoDispose<FeeRate>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    final settings = ref.watch(onlineProvider);
    if (settings) {
      BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
      return bitcoinModel.estimateFeeRate(3);
    } else {
      throw Exception('Offline');
    }
  });
});

final getSlowFeeRateProvider = FutureProvider.autoDispose<FeeRate>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    final settings = ref.watch(onlineProvider);
    if (settings) {
      BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
      return bitcoinModel.estimateFeeRate(6);
    } else {
      throw Exception('No internet connection');
    }
  });
});

final getCustomFeeRateProvider = FutureProvider.family.autoDispose<FeeRate, int>((ref, blocks) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    final settings = ref.watch(onlineProvider);
    if (settings) {
      BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
      return bitcoinModel.estimateFeeRate(blocks);
    } else {
      throw Exception('No internet connection');
    }
  });
});

final sendProvider = FutureProvider.family.autoDispose<void, SendParams>((ref, params) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) async {
    final settings = ref.watch(onlineProvider);
    if (settings) {
      BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
      FeeRate feeRate = await ref.watch(getCustomFeeRateProvider(params.blocks).future);
      return bitcoinModel.sendBitcoin(params.address, feeRate);
    }
  });
});