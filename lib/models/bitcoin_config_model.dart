import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class BitcoinConfigModel extends StateNotifier<BitcoinConfig> {
  BitcoinConfigModel(super.state);

  Future<Descriptor> createDescriptor() async {
    final descriptorSecretKey = await DescriptorSecretKey.create(
      network: state.network,
      mnemonic: state.mnemonic!,
    );
    final descriptor = await Descriptor.newBip84(
        secretKey: descriptorSecretKey,
        network: state.network,
        keychain: state.keychain );
    return descriptor;
  }

  Future<Blockchain> initializeBlockchain() async {
    if (state.isElectrumBlockchain) {
      final blockchain = await Blockchain.create(
          config: const BlockchainConfig.esplora(
              config: EsploraConfig(
                  baseUrl: 'https://blockstream.info/mainnet/api',
                  stopGap: 10)));
      return blockchain;
    } else {
      final blockchain = await Blockchain.create(
          config: const BlockchainConfig.electrum(
              config: ElectrumConfig(
                  stopGap: 10,
                  timeout: 5,
                  retry: 5,
                  url: "ssl://electrum.blockstream.info:60002",
                  validateDomain: true)));
      return blockchain;
    }
  }

  Future<Wallet> restoreWallet(Descriptor descriptor) async {
    final wallet = await Wallet.create(
        descriptor: descriptor,
        network: Network.Testnet,
        databaseConfig: const DatabaseConfig.memory());
    return wallet;
  }
}
class BitcoinConfig {
  final Mnemonic? mnemonic;
  final Network network;
  final KeychainKind keychain;
  final bool isElectrumBlockchain;

  BitcoinConfig({
    required this.mnemonic,
    required this.network,
    required this.keychain,
    required this.isElectrumBlockchain,
  });

  BitcoinConfig copyWith({
    Mnemonic? mnemonic,
    Network? network,
    KeychainKind? keychain,
    bool? isElectrumBlockchain,
  }) {
    return BitcoinConfig(
      mnemonic: mnemonic,
      network: network ?? this.network,
      keychain: keychain ?? this.keychain,
      isElectrumBlockchain: isElectrumBlockchain ?? this.isElectrumBlockchain,
    );
  }
}
