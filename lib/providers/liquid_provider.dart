import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lwk_dart/lwk_dart.dart';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/liquid_model.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/liquid_config_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';

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

final liquidAddressProvider = FutureProvider.autoDispose<Address>((ref) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.getAddress();
  });
});

final liquidNextAddressProvider = FutureProvider.autoDispose<String>((ref) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.getNextAddress();
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

final liquidUnspentUtxosProvider = FutureProvider<List<TxOut>>((ref) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.listUnspent();
  });
});

final getCustomFeeRateProvider = FutureProvider.autoDispose<double>((ref) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    final blocks = ref.watch(sendBlocksProvider.notifier).state.toInt();
    return liquidModel.getLiquidFees(blocks);
  });
});

final buildLiquidTransactionProvider = FutureProvider.family.autoDispose<String, TransactionBuilder>((ref, params) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.buildLbtcTx(params);
  });
});

final buildLiquidAssetTransactionProvider = FutureProvider.family.autoDispose<String, TransactionBuilder>((ref, params) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.buildAssetTx(params);
  });
});

// temporary until library supports build a drain method
final buildDrainLiquidTransactionProvider = FutureProvider.family.autoDispose<String, TransactionBuilder>((ref, params) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.buildDrainWalletTx(params);
  });
});

final decodeLiquidPsetProvider = FutureProvider.family.autoDispose<PsetAmounts, String>((ref, pset) async {
  final liquid = await ref.watch(initializeLiquidProvider.future);
  final LiquidModel liquidModel = LiquidModel(liquid);
  return await liquidModel.decode(pset);
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

final signLiquidPsetStringProvider = FutureProvider.family.autoDispose<String, String>((ref, pset) async {
  final liquid = await ref.watch(initializeLiquidProvider.future);
  final LiquidModel liquidModel = LiquidModel(liquid);
  final mnemonic = await ref.watch(authModelProvider).getMnemonic();
  final SignParams signParams = SignParams(
    pset: pset,
    mnemonic: mnemonic!,
  );
  return await liquidModel.signedPsetString(signParams);
});

final broadcastLiquidTransactionProvider = FutureProvider.family.autoDispose<String, Uint8List>((ref, signedTxBytes) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.broadcast(signedTxBytes);
  });
});

final sendLiquidTransactionProvider = FutureProvider.autoDispose<String>((ref) async {
  final feeRate = await ref.watch(getCustomFeeRateProvider.future);
  final sendTx = ref.watch(sendTxProvider.notifier);
  final transactionBuilder = TransactionBuilder(
    amount: sendTx.state.amount,
    outAddress: sendTx.state.address,
    fee: feeRate,
    assetId: sendTx.state.assetId,
  );
  final pset = sendTx.state.assetId == AssetMapper.reverseMapTicker(AssetId.LBTC)
      ? await ref.watch(buildLiquidTransactionProvider(transactionBuilder).future)
      : await ref.watch(buildLiquidAssetTransactionProvider(transactionBuilder).future);
  final signedTxBytes = await ref.watch(signLiquidPsetProvider(pset).future);
  return ref.watch(broadcastLiquidTransactionProvider(signedTxBytes).future);
});


