import 'dart:typed_data';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
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

  return ref.watch(liquidConfigProvider.future).then((config) {
    return Liquid(liquid: config, electrumUrl: electrumUrl);
  });
});

final syncLiquidProvider = FutureProvider.autoDispose<void>((ref) {
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

final liquidAddressProvider = FutureProvider.autoDispose<Address>((ref) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    final addressIndex = ref.watch(addressProvider).liquidAddressIndex;
    return liquidModel.getAddressOfIndex(addressIndex);
  });
});

final liquidAddressOfIndexProvider = FutureProvider.autoDispose.family<String, int>((ref, index) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.getAddressOfIndexString(index);
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

final liquidTransactionsProvider = FutureProvider.autoDispose<List<Tx>>((ref) {
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

final broadcastLiquidTransactionProvider = FutureProvider.family.autoDispose<String, Uint8List>((ref, signedTxBytes) {
  return ref.watch(initializeLiquidProvider.future).then((liquid) {
    LiquidModel liquidModel = LiquidModel(liquid);
    return liquidModel.broadcast(signedTxBytes);
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


