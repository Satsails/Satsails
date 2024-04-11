import 'package:bdk_flutter/bdk_flutter.dart';

class BitcoinConfigModel {
  final BitcoinConfig config;

  BitcoinConfigModel(this.config);

  Future<Descriptor> _createDescriptor(KeychainKind keychain) async {
    Mnemonic mnemonic = await Mnemonic.fromString(config.mnemonic).then((value) => value);

    final descriptorSecretKey = await DescriptorSecretKey.create(
      network: config.network,
      mnemonic: mnemonic,
    );

    final descriptor = await Descriptor.newBip84(
        secretKey: descriptorSecretKey,
        network: config.network,
        keychain: keychain);

    return descriptor;
  }

  Future<Descriptor> createInternalDescriptor() async {
    return _createDescriptor(config.internalKeychain);
  }

  Future<Descriptor> createExternalDescriptor() async {
    return _createDescriptor(config.externalKeychain);
  }

  Future<Blockchain> initializeBlockchain() async {
    if (config.isElectrumBlockchain) {
      try {
        final blockchain = await Blockchain.create(
            config: const BlockchainConfig.electrum(
                config: ElectrumConfig(
                    stopGap: 20,
                    timeout: 2,
                    retry: 2,
                    url: "ssl://electrum.blockstream.info:50002",
                    validateDomain: false)));
        return blockchain;
      } catch (_) {
        throw Exception('Failed to initialize blockchain');
      }
    } else {
      final blockchain = await Blockchain.create(
          config: const BlockchainConfig.esplora(
              config: EsploraConfig(
                  baseUrl: 'https://blockstream.info/api/',
                  stopGap: 10)));
      return blockchain;

    }
  }

  Future<Wallet> restoreWallet(Descriptor descriptor, Descriptor change) async {
    final wallet = await Wallet.create(
        descriptor: descriptor,
        changeDescriptor: change,
        network: config.network,
        databaseConfig: const DatabaseConfig.memory());
    return wallet;
  }
}

class BitcoinConfig {
  final String mnemonic;
  final Network network;
  final KeychainKind externalKeychain;
  final KeychainKind internalKeychain;
  final bool isElectrumBlockchain;

  BitcoinConfig({
    required this.mnemonic,
    required this.network,
    required this.externalKeychain,
    required this.internalKeychain,
    required this.isElectrumBlockchain,
  });
}