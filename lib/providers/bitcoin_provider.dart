import 'package:Satsails/models/bitcoin_model.dart';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bitcoin_config_provider.dart';

// Asynchronous setup of Bitcoin object
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

// Synchronous BitcoinModel provider, initialized once bitcoinProvider resolves
final bitcoinModelProvider = Provider<BitcoinModel>((ref) {
  final bitcoin = ref.watch(bitcoinProvider).value;
  if (bitcoin == null) {
    throw Exception('Bitcoin provider is not yet initialized');
  }
  return BitcoinModel(bitcoin);
});

// Asynchronous sync operation
final syncBitcoinProvider = FutureProvider.autoDispose<void>((ref) async {
  final bitcoinModel = ref.watch(bitcoinModelProvider);
  return bitcoinModel.sync();
});

// Synchronous providers using bitcoinModelProvider
final lastUsedAddressProvider = Provider.autoDispose<int>((ref) {
  final bitcoinModel = ref.watch(bitcoinModelProvider);
  return bitcoinModel.getAddress();
});

final lastUsedAddressProviderString = Provider.autoDispose<String>((ref) {
  final bitcoinModel = ref.watch(bitcoinModelProvider);
  return bitcoinModel.getAddressString();
});

final bitcoinAddressProvider = Provider.autoDispose<String>((ref) {
  final bitcoinModel = ref.watch(bitcoinModelProvider);
  final addressIndex = ref.watch(addressProvider).bitcoinAddressIndex;
  return bitcoinModel.getCurrentAddress(addressIndex);
});

final bitcoinAddressInfoProvider = Provider.autoDispose<AddressInfo>((ref) {
  final bitcoinModel = ref.watch(bitcoinModelProvider);
  final addressIndex = ref.watch(addressProvider).bitcoinAddressIndex;
  return bitcoinModel.getAddressInfo(addressIndex);
});

final getBitcoinTransactionsProvider = Provider.autoDispose<List<TransactionDetails>>((ref) {
  final bitcoinModel = ref.watch(bitcoinModelProvider);
  return bitcoinModel.getTransactions();
});

final getBitcoinBalanceProvider = Provider.autoDispose<Balance>((ref) {
  final bitcoinModel = ref.watch(bitcoinModelProvider);
  return bitcoinModel.getBalance();
});

final unspentUtxosProvider = Provider.autoDispose<List<LocalUtxo>>((ref) {
  final bitcoin = ref.watch(bitcoinProvider).value;
  if (bitcoin == null) {
    throw Exception('Bitcoin provider is not yet initialized');
  }
  return bitcoin.wallet.listUnspent();
});

final getPsbtInputProvider = Provider.autoDispose<Input>((ref) {
  final bitcoinModel = ref.watch(bitcoinModelProvider);
  final unspentUtxos = ref.watch(unspentUtxosProvider);
  return bitcoinModel.getPsbtInput(unspentUtxos.first, true);
});

// Asynchronous fee rate estimation
final bitcoinFeeRatePerBlockProvider = FutureProvider<BitcoinFeeModel>((ref) async {
  final bitcoinModel = ref.watch(bitcoinModelProvider);
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

// Asynchronous transaction building
final buildBitcoinTransactionProvider = FutureProvider.autoDispose.family<(PartiallySignedTransaction, TransactionDetails), TransactionBuilder>((ref, transaction) async {
  final bitcoinModel = ref.watch(bitcoinModelProvider);
  return bitcoinModel.buildBitcoinTransaction(transaction);
});

final buildDrainWalletBitcoinTransactionProvider = FutureProvider.autoDispose.family<(PartiallySignedTransaction, TransactionDetails), TransactionBuilder>((ref, transaction) async {
  final bitcoinModel = ref.watch(bitcoinModelProvider);
  return bitcoinModel.drainWalletBitcoinTransaction(transaction);
});

// Synchronous PSBT signing
final signBitcoinPsbtProvider = Provider.family.autoDispose<(PartiallySignedTransaction, TransactionDetails), (PartiallySignedTransaction, TransactionDetails)>((ref, psbt) {
  final bitcoinModel = ref.watch(bitcoinModelProvider);
  bitcoinModel.signBitcoinTransaction(psbt);
  return psbt;
});

// Asynchronous transaction broadcasting
final broadcastBitcoinTransactionProvider = FutureProvider.autoDispose.family<String, (PartiallySignedTransaction, TransactionDetails)>((ref, signedPsbt) async {
  final bitcoinModel = ref.watch(bitcoinModelProvider);
  return bitcoinModel.broadcastBitcoinTransaction(signedPsbt);
});

final sendBitcoinTransactionProvider = FutureProvider.autoDispose<String>((ref) async {
  final feeRate = await ref.watch(getCustomFeeRateProvider.future);
  final sendTx = ref.read(sendTxProvider);
  final transactionBuilder = TransactionBuilder(sendTx.amount, sendTx.address, feeRate);

  final psbt = sendTx.drain
      ? await ref.watch(buildDrainWalletBitcoinTransactionProvider(transactionBuilder).future)
      : await ref.watch(buildBitcoinTransactionProvider(transactionBuilder).future);

  final signedPsbt = ref.watch(signBitcoinPsbtProvider(psbt));
  return await ref.watch(broadcastBitcoinTransactionProvider(signedPsbt).future);
});