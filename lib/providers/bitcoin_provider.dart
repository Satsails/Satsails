import 'package:Satsails/providers/address_provider.dart';
import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/bitcoin_model.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'bitcoin_config_provider.dart';

final bitcoinProvider = FutureProvider<Bitcoin>((ref) async {
  Wallet wallet = await ref.watch(restoreWalletProvider.future);
  final config = await ref.read(bitcoinConfigProvider.future);
  try {
    Blockchain blockchain = await ref.watch(initializeBlockchainProvider.future);
    return Bitcoin(wallet, blockchain, config.network);
  } catch (e) {
    return Bitcoin(wallet, null, config.network);
  }
});

final syncBitcoinProvider = FutureProvider.autoDispose<void>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.sync();
  });
});

final lastUsedAddressProvider = FutureProvider.autoDispose<int>((ref) async {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.getAddress();
  });
});

final bitcoinAddressProvider = FutureProvider.autoDispose<String>((ref) async {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    final addressIndex = ref.watch(addressProvider).bitcoinAddressIndex;
    return bitcoinModel.getCurrentAddress(addressIndex);
  });
});

final bitcoinAddressInfoProvider = FutureProvider.autoDispose<AddressInfo>((ref) async {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    final addressIndex = ref.watch(addressProvider).bitcoinAddressIndex;
    return bitcoinModel.getAddressInfo(addressIndex);
  });
});

final getBitcoinTransactionsProvider = FutureProvider.autoDispose<List<TransactionDetails>>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.getTransactions();
  });
});

final getBitcoinBalanceProvider = FutureProvider.autoDispose<Balance>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.getBalance();
  });
});

final unspentUtxosProvider = FutureProvider.autoDispose<List<LocalUtxo>>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    return bitcoin.wallet.listUnspent();
  });
});

final getPsbtInputProvider = FutureProvider.autoDispose<Input>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) async {
    final unspentUtxos = await ref.watch(unspentUtxosProvider.future);
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.getPsbtInput(unspentUtxos.first, true);
  });
});

final bitcoinFeeRatePerBlockProvider = FutureProvider<BitcoinFeeModel>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.estimateFeeRate();
  });
});

final getCustomFeeRateProvider = FutureProvider.autoDispose<double>((ref) {
  final blocks = ref.watch(sendBlocksProvider).toInt();
  final feeRate = ref.watch(bitcoinFeeRatePerBlockProvider.future);
  return feeRate.then((value) {
    switch (blocks) {
      case 1:
        return value.fastestFee;
      case 2:
        return value.halfHourFee;
      case 3:
        return value.hourFee;
      case 4:
        return value.economyFee;
      case 5:
        return value.minimumFee;
      default:
        return value.fastestFee;
    }
  });
});

final buildBitcoinTransactionProvider = FutureProvider.autoDispose.family<(PartiallySignedTransaction, TransactionDetails), TransactionBuilder>((ref, transaction) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    return BitcoinModel(bitcoin).buildBitcoinTransaction(transaction);
  });
});

final buildDrainWalletBitcoinTransactionProvider = FutureProvider.autoDispose.family<(PartiallySignedTransaction, TransactionDetails), TransactionBuilder>((ref, transaction) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    return BitcoinModel(bitcoin).drainWalletBitcoinTransaction(transaction);
  });
});

final signBitcoinPsbtProvider = FutureProvider.family.autoDispose<(PartiallySignedTransaction, TransactionDetails), (PartiallySignedTransaction, TransactionDetails)>((ref, psbt) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  final BitcoinModel bitcoinModel = BitcoinModel(bitcoin);

  await bitcoinModel.signBitcoinTransaction(psbt);

  return psbt;
});

final broadcastBitcoinTransactionProvider = FutureProvider.autoDispose.family<String, (PartiallySignedTransaction, TransactionDetails)>((ref, signedPsbt) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.broadcastBitcoinTransaction(signedPsbt);
  });
});

final sendBitcoinTransactionProvider = FutureProvider.autoDispose<String>((ref) async {
  final feeRate = await ref.watch(getCustomFeeRateProvider.future);
  final sendTx = ref.read(sendTxProvider);
  final transactionBuilder = TransactionBuilder(sendTx.amount, sendTx.address, feeRate);

  final psbt = sendTx.drain
      ? await ref.watch(buildDrainWalletBitcoinTransactionProvider(transactionBuilder).future)
      : await ref.watch(buildBitcoinTransactionProvider(transactionBuilder).future);

  final signedPsbt = await ref.watch(signBitcoinPsbtProvider(psbt).future);

  return await ref.watch(broadcastBitcoinTransactionProvider(signedPsbt).future);
});