import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lwk_dart/lwk_dart.dart';
import 'package:satsails/models/liquid_model.dart';
import 'package:satsails/models/send_tx_model.dart';
import 'package:satsails/providers/auth_provider.dart';
import 'package:satsails/providers/liquid_config_provider.dart';
import 'package:satsails/providers/send_tx_provider.dart';

final initializeLiquidProvider = FutureProvider<Liquid>((ref) {
  return ref.watch(liquidConfigProvider.future).then((config) {
    return Liquid(liquid: config, electrumUrl: 'blockstream.info:995');
  });
});

final syncLiquidProvider = FutureProvider.autoDispose<void>((ref) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.sync();
  });
});

final liquidAddressProvider = FutureProvider.autoDispose<String>((ref) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.getAddress();
  });
});

final liquidBalanceProvider = FutureProvider<Balances>((ref) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.balance();
  });
});

final liquidTransactionsProvider = FutureProvider<List<Tx>>((ref) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.txs();
  });
});

final getCustomFeeRateProvider = FutureProvider.autoDispose<double>((ref) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    final blocks = ref.watch(sendTxProvider).blocks;
    return liquidModel.getLiquidFees(blocks);
  });
});

final buildLiquidTransactionProvider = FutureProvider.family.autoDispose<String, TransactionBuilder>((ref, params) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.build_lbtc_tx(params);
  });
});

final signLiquidPsetProvider = FutureProvider.family.autoDispose<Uint8List, String>((ref, pset) async {
  final liquid = await ref.watch(initializeLiquidProvider.future);
  final LiquidModel liquidModel = LiquidModel(liquid);
  final mnemonic = await ref.watch(authModelProvider).getMnemonic();
  final SignParams signParams = SignParams(
    pset: pset,
    mnemonic: mnemonic!,
  );
  return await liquidModel.sign(signParams);
});

final broadcastLiquidTransactionProvider = FutureProvider.family.autoDispose<String, Uint8List>((ref, signedTxBytes) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.broadcast(signedTxBytes);
  });
});

final sendLiquidTransactionProvider = FutureProvider.family.autoDispose<String, SendTx>((ref, params) async {
  final feeRate = await ref.watch(getCustomFeeRateProvider.future);
  final TransactionBuilder transactionBuilder = TransactionBuilder(
    amount: params.amount,
    outAddress: params.address,
    fee: feeRate,
    assetId: params.assetId ?? '',
  );
  final pset = await ref.watch(buildLiquidTransactionProvider(transactionBuilder).future);
  final signedTxBytes = await ref.watch(signLiquidPsetProvider(pset).future);
  return ref.watch(broadcastLiquidTransactionProvider(signedTxBytes).future);
});


