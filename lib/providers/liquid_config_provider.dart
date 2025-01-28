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

  try {
    final wallet = await LiquidConfigModel.createWallet(mnemonic, Network.testnet);
    return LiquidConfig(
      mnemonic: mnemonic,
      network: Network.testnet,
      wallet: wallet,
    );
  } catch (e) {
    final errorMessage = e.toString();
    if (errorMessage.contains('UpdateHeightTooOld') ||
        errorMessage.contains('UpdateOnDifferentStatus')) {
      // Delete database only for specific errors
      await authModel.deleteLwkDb();
      final wallet = await LiquidConfigModel.createWallet(mnemonic, Network.testnet);
      return LiquidConfig(
        mnemonic: mnemonic,
        network: Network.testnet,
        wallet: wallet,
      );
    } else {
      throw Exception('Error please contact support: Failure to launch liquid wallet');
    }
  }
});