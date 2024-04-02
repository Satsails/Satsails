import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:satsails/models/bitcoin_config_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mnemonic_provider.dart';

final initializeConfigProvider = FutureProvider<BitcoinConfig>((ref) async {
  final mnemonic = await ref.watch(mnemonicProvider.future);

  final config = BitcoinConfig(
      mnemonic: mnemonic.mnemonic!,
      network: Network.Bitcoin,
      externalKeychain: KeychainKind.External,
      internalKeychain: KeychainKind.Internal,
      isElectrumBlockchain: true,
  );
  return config;
});


final configNotifierProvider = StateNotifierProvider<BitcoinConfigModel, BitcoinConfig>((ref) {
  final initialConfig = ref.watch(initializeConfigProvider);

  return BitcoinConfigModel(initialConfig.when(
    data: (config) => config,
    loading: () => throw 'Loading config',
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});