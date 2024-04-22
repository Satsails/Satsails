import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/bitcoin_model.dart';
import 'package:satsails/providers/send_tx_provider.dart';
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

final getCustomFeeRateProvider = FutureProvider.autoDispose<double>((ref) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    final blocks = ref.watch(sendBlocksProvider.notifier).state.toInt();
    return bitcoinModel.estimateFeeRate(blocks);
  });
});

final buildBitcoinTransactionProvider = FutureProvider.autoDispose.family<TxBuilderResult, TransactionBuilder>((ref, transaction) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    return BitcoinModel(bitcoin).buildBitcoinTransaction(transaction);
  });
});

final buildDrainWalletBitcoinTransactionProvider = FutureProvider.autoDispose.family<TxBuilderResult, TransactionBuilder>((ref, transaction) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    return BitcoinModel(bitcoin).drainWalletBitcoinTransaction(transaction);
  });
});

final signBitcoinPsbtProvider = FutureProvider.family.autoDispose<PartiallySignedTransaction, TransactionBuilder>((ref, psbt) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  final BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
  final transaction = await ref.watch(buildBitcoinTransactionProvider(psbt).future);
  return bitcoinModel.signBitcoinTransaction(transaction);
});

final broadcastBitcoinTransactionProvider = FutureProvider.autoDispose.family<void, PartiallySignedTransaction>((ref, signedPsbt) {
  return ref.watch(bitcoinProvider.future).then((bitcoin) {
    BitcoinModel bitcoinModel = BitcoinModel(bitcoin);
    return bitcoinModel.broadcastBitcoinTransaction(signedPsbt);
  });
});

final sendBitcoinTransactionProvider = FutureProvider.autoDispose<void>((ref) async {
  final feeRate = await ref.watch(getCustomFeeRateProvider.future);
  final sendTx = ref.watch(sendTxProvider.notifier);
  final transactionBuilder = TransactionBuilder(sendTx.state.amount, sendTx.state.address, feeRate);
  final signedPsbt = await ref.watch(signBitcoinPsbtProvider(transactionBuilder).future);
  return ref.watch(broadcastBitcoinTransactionProvider(signedPsbt).future);
});

