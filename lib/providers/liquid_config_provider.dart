import 'package:lwk_dart/lwk_dart.dart';
import 'package:satsails/models/liquid_config_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mnemonic_provider.dart';

final liquidConfigProvider = FutureProvider<LiquidConfig>( (ref) async {
  final mnemonic = await ref.watch(mnemonicProvider.future);
  if (mnemonic.mnemonic == null || mnemonic.mnemonic == '') {
    throw Exception('Mnemonic is null or empty');
  }
  final wallet = await LiquidConfigModel.createWallet(mnemonic.mnemonic, Network.Mainnet);

  final config = LiquidConfig(
    mnemonic: mnemonic.mnemonic,
    network: Network.Mainnet,
    wallet: wallet,
  );
  return config;
});