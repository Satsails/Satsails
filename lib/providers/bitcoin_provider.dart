import 'package:Satsails/models/bitcoin_model.dart';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final bitcoinModelProvider = FutureProvider<BitcoinModel>((ref) async {
  final bitcoin = await ref.watch(bitcoinProvider.future);
  return BitcoinModel(bitcoin);
});

final syncBitcoinProvider = FutureProvider<void>((ref) async {
  final bitcoinModel = await ref.watch(bitcoinModelProvider.future);
  return bitcoinModel.sync();
});

final lastUsedAddressProvider = FutureProvider.autoDispose<int>((ref) async {
  final bitcoinModel = await ref.watch(bitcoinModelProvider.future);
  return await bitcoinModel.getAddress();
});

final lastUsedAddressProviderString = FutureProvider.autoDispose<String>((ref) async {
  final bitcoinModel = await ref.watch(bitcoinModelProvider.future);
  return await bitcoinModel.getAddressString();
});

final bitcoinAddressProvider = FutureProvider.autoDispose<String>((ref) async {
  final bitcoinModel = await ref.watch(bitcoinModelProvider.future);
  final addressIndex = ref.watch(addressProvider).bitcoinAddressIndex;
  return await bitcoinModel.getCurrentAddress(addressIndex);
});

final getBitcoinTransactionsProvider = FutureProvider<List<TransactionDetails>>((ref) async {
  final bitcoinModel = await ref.watch(bitcoinModelProvider.future);
  return await bitcoinModel.getTransactions();
});

final getBitcoinBalanceProvider = FutureProvider.autoDispose<Balance>((ref) async {
  final bitcoinModel = await ref.watch(bitcoinModelProvider.future);
  return await bitcoinModel.getBalance();
});

final unspentUtxosProvider = FutureProvider.autoDispose<List<LocalUtxo>>((ref) async {
  final bitcoinModel = await ref.watch(bitcoinModelProvider.future);
  return await bitcoinModel.listUnspent();
});

final getPsbtInputProvider = FutureProvider.autoDispose<Input>((ref) async {
  final bitcoinModel = await ref.watch(bitcoinModelProvider.future);
  final unspentUtxos = await ref.watch(unspentUtxosProvider.future);
  return await bitcoinModel.getPsbtInput(unspentUtxos.first, true);
});

final bitcoinFeeRatePerBlockProvider = FutureProvider<BitcoinFeeModel>((ref) async {
  final bitcoinModel = await ref.watch(bitcoinModelProvider.future);
  return bitcoinModel.estimateFeeRate();
});

final getCustomFeeRateProvider = FutureProvider.autoDispose<double>((ref) async {
  final blocks = ref.watch(sendBlocksProvider).toInt();
  final feeRate = await ref.watch(bitcoinFeeRatePerBlockProvider.future);
  switch (blocks) {
    case 1:
      return feeRate.fastestFee;
    case 2:
      return feeRate.halfHourFee;
    case 3:
      return feeRate.hourFee;
    case 4:
      return feeRate.economyFee;
    case 5:
      return feeRate.minimumFee;
    default:
      return feeRate.fastestFee;
  }
});

final buildBitcoinTransactionProvider = FutureProvider.autoDispose.family<(PartiallySignedTransaction, TransactionDetails), TransactionBuilder>((ref, transaction) async {
  final bitcoinModel = await ref.watch(bitcoinModelProvider.future);
  return bitcoinModel.buildBitcoinTransaction(transaction);
});

final buildDrainWalletBitcoinTransactionProvider = FutureProvider.autoDispose.family<(PartiallySignedTransaction, TransactionDetails), TransactionBuilder>((ref, transaction) async {
  final bitcoinModel = await ref.watch(bitcoinModelProvider.future);
  return bitcoinModel.drainWalletBitcoinTransaction(transaction);
});

final signBitcoinPsbtProvider = FutureProvider.autoDispose.family<(PartiallySignedTransaction, TransactionDetails), (PartiallySignedTransaction, TransactionDetails)>((ref, psbt) async {
  final bitcoinModel = await ref.watch(bitcoinModelProvider.future);
  await bitcoinModel.signBitcoinTransaction(psbt);
  return psbt;
});

final broadcastBitcoinTransactionProvider = FutureProvider.autoDispose.family<String, (PartiallySignedTransaction, TransactionDetails)>((ref, signedPsbt) async {
  final bitcoinModel = await ref.watch(bitcoinModelProvider.future);
  return bitcoinModel.broadcastBitcoinTransaction(signedPsbt);
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

final bumpBitcoinTransactionProvider = FutureProvider.autoDispose.family<String, ({String txid, double newFeeRate})>((ref, args) async {
  final bitcoinModel = await ref.watch(bitcoinModelProvider.future);
  final bumpFeeBuilder = BumpFeeTransactionBuilder(txid: args.txid, fee: args.newFeeRate);
  final psbt = await bitcoinModel.bumpFeeTransaction(bumpFeeBuilder);
  final signedPsbt = await ref.watch(signBitcoinPsbtProvider(psbt).future);
  final newTxid = await ref.watch(broadcastBitcoinTransactionProvider(signedPsbt).future);

  return newTxid;
});