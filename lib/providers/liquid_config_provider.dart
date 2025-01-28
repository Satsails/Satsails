import 'package:Satsails/providers/auth_provider.dart';
import 'package:lwk/lwk.dart';
import 'package:Satsails/models/liquid_config_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final liquidConfigProvider = FutureProvider<LiquidConfig>((ref) async {
  final authModel = ref.read(authModelProvider);
  final mnemonic = await authModel.getMnemonic();
  if (mnemonic == null || mnemonic.isEmpty) {
    throw Exception('Mnemonic is null or empty');
  }

  final wallet = await LiquidConfigModel.createWallet(mnemonic, Network.mainnet);

  return LiquidConfig(
    mnemonic: mnemonic,
    network: Network.mainnet,
    wallet: wallet,
  );
});
