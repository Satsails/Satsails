import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:satsails/models/bitcoin_config_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mnemonic_provider.dart';

final bitcoinConfigProvider = FutureProvider<BitcoinConfig>((ref) async {
  final mnemonic = await ref.watch(mnemonicProvider.future);

  final config = BitcoinConfig(
      mnemonic: mnemonic.mnemonic,
      network: Network.Bitcoin,
      externalKeychain: KeychainKind.External,
      internalKeychain: KeychainKind.Internal,
      isElectrumBlockchain: true,
  );
  return config;
});

final createInternalDescriptorProvider = FutureProvider<Descriptor>((ref) async {
  final config = await ref.watch(bitcoinConfigProvider.future);
  BitcoinConfigModel bitcoinConfigModel = BitcoinConfigModel(config);
  return await bitcoinConfigModel.createInternalDescriptor();
});

final createExternalDescriptorProvider = FutureProvider<Descriptor>((ref) async {
  final config = await ref.watch(bitcoinConfigProvider.future);
  BitcoinConfigModel bitcoinConfigModel = BitcoinConfigModel(config);
  return await bitcoinConfigModel.createExternalDescriptor();
});

final initializeBlockchainProvider = FutureProvider<Blockchain>((ref) async {
  final config = await ref.watch(bitcoinConfigProvider.future);
  BitcoinConfigModel bitcoinConfigModel = BitcoinConfigModel(config);
  return await bitcoinConfigModel.initializeBlockchain();
});

final restoreWalletProvider = FutureProvider<Wallet>((ref) async {
  final config = await ref.watch(bitcoinConfigProvider.future);
  final externalDescriptor = await ref.watch(createExternalDescriptorProvider.future);
  final internalDescriptor = await ref.watch(createInternalDescriptorProvider.future);
  BitcoinConfigModel bitcoinConfigModel = BitcoinConfigModel(config);
  return await bitcoinConfigModel.restoreWallet(externalDescriptor, internalDescriptor);
});