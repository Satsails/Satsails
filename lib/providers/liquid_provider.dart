import 'dart:typed_data';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lwk/lwk.dart';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/liquid_model.dart';
import 'package:Satsails/providers/liquid_config_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';

final initializeLiquidProvider = FutureProvider<Liquid>((ref) {
  final electrumUrl = ref.watch(
    settingsProvider.select((settings) => settings.liquidElectrumNode),
  );

  ref.watch(
    settingsProvider.select((settings) => settings.online),
  );

  return ref.watch(liquidConfigProvider.future).then((config) {
    return Liquid(liquid: config, electrumUrl: electrumUrl);
  });
});

final syncLiquidProvider = FutureProvider<void>((ref) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.sync();
  });
});

final liquidLastUsedAddressProvider = FutureProvider.autoDispose<int>((ref) async {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.getAddress();
  });
});

final liquidLastUsedAddressStringProvider = FutureProvider.autoDispose<String>((ref) async {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.getLatestAddress();
  });
});

final liquidAddressProvider = FutureProvider.autoDispose<Address>((ref) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    final addressIndex = ref.watch(addressProvider).liquidAddressIndex;
    return liquidModel.getAddressOfIndex(addressIndex);
  });
});

final liquidNextAddressProvider = FutureProvider.autoDispose<String>((ref) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    final addressIndex = ref.watch(addressProvider).liquidAddressIndex;
    return liquidModel.getAddressOfIndexString(addressIndex + 1);
  });
});

final liquidBalanceProvider = FutureProvider.autoDispose<Balances>((ref) {
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

final liquidUnspentUtxosProvider = FutureProvider.autoDispose<List<TxOut>>((ref) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.listUnspent();
  });
});

final getCustomFeeRateProvider = FutureProvider.autoDispose<double>((ref) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    final blocks = ref.watch(sendBlocksProvider).toInt();
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

final buildLiquidPayjoinTransactionProvider = FutureProvider.family.autoDispose<PayjoinTx, TransactionBuilder>((ref, params) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.buildPayjoinAssetTx(params);
  });
});

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

final signLiquidPsetProvider = FutureProvider.family.autoDispose<String, String>((ref, pset) async {
  final liquid = await ref.watch(initializeLiquidProvider.future);
  final LiquidModel liquidModel = LiquidModel(liquid);
  final authModel = ref.read(authModelProvider);
  final mnemonic = await authModel.getMnemonic();
  final SignParams signParams = SignParams(
    pset: pset,
    mnemonic: mnemonic!,
  );
  return await liquidModel.sign(signParams);
});

final signLiquidPsetStringProvider = FutureProvider.family.autoDispose<String, String>((ref, pset) async {
  final liquid = await ref.watch(initializeLiquidProvider.future);
  final LiquidModel liquidModel = LiquidModel(liquid);
  final authModel = ref.read(authModelProvider);
  final mnemonic = await authModel.getMnemonic();
  final SignParams signParams = SignParams(
    pset: pset,
    mnemonic: mnemonic!,
  );
  return await liquidModel.signedPsetString(signParams);
});

final broadcastLiquidTransactionProvider = FutureProvider.family.autoDispose<String, String>((ref, signedPset) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.broadcast(signedPset);
  });
});

final sendLiquidTransactionProvider = FutureProvider.autoDispose<String>((ref) async {
  final feeRate = await ref.watch(getCustomFeeRateProvider.future);
  final sendTx = ref.read(sendTxProvider);
  final transactionBuilder = TransactionBuilder(
    amount: sendTx.amount,
    outAddress: sendTx.address,
    fee: feeRate,
    assetId: sendTx.assetId,
  );
  String pset;
  if (sendTx.drain) {
    pset = await ref.watch(buildDrainLiquidTransactionProvider(transactionBuilder).future);
  } else {
    pset = sendTx.assetId == AssetMapper.reverseMapTicker(AssetId.LBTC) ? await ref.watch(buildLiquidTransactionProvider(transactionBuilder).future): await ref.watch(buildLiquidAssetTransactionProvider(transactionBuilder).future);
  }
  final signedTxBytes = await ref.watch(signLiquidPsetProvider(pset).future);
  return ref.watch(broadcastLiquidTransactionProvider(signedTxBytes).future);
});

final liquidPayjoinTransaction = FutureProvider.autoDispose<String>((ref) async {
  final feeRate = await ref.watch(getCustomFeeRateProvider.future);
  final sendTx = ref.watch(sendTxProvider);
  final transactionBuilder = TransactionBuilder(
    amount: sendTx.amount,
    outAddress: sendTx.address,
    fee: feeRate,
    assetId: sendTx.assetId,
  );
  final unsigedPset =  await ref.read(buildLiquidPayjoinTransactionProvider(transactionBuilder).future);

  final pset = await ref.read(signLiquidPsetStringProvider(unsigedPset.pset).future);

  return await ref.read(broadcastLiquidTransactionProvider(pset).future);
});


