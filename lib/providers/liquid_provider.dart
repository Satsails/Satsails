import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lwk_dart/lwk_dart.dart';
import 'package:satsails/models/liquid_model.dart';
import 'package:satsails/providers/liquid_config_provider.dart';

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