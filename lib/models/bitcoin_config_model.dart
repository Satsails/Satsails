import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class BitcoinConfigModel extends StateNotifier<BitcoinConfig> {
  BitcoinConfigModel(super.state);

  Future<Descriptor> createInternalDescriptor() async {
    if (state.mnemonic == "") {
      throw Exception('Mnemonic is required');
    }

    Mnemonic mnemonic = await Mnemonic.fromString(state.mnemonic!).then((value) => value);

    final descriptorSecretKey = await DescriptorSecretKey.create(
      network: state.network,
      mnemonic: mnemonic,
    );
    final descriptor = await Descriptor.newBip84(
        secretKey: descriptorSecretKey,
        network: state.network,
        keychain: state.internalKeychain );
    return descriptor;
  }

  Future<Descriptor> createExternalDescriptor() async {
    if (state.mnemonic == "") {
      throw Exception('Mnemonic is required');
    }

    Mnemonic mnemonic = await Mnemonic.fromString(state.mnemonic!).then((value) => value);

    final descriptorSecretKey = await DescriptorSecretKey.create(
      network: state.network,
      mnemonic: mnemonic,
    );

    final descriptor = await Descriptor.newBip84(
        secretKey: descriptorSecretKey,
        network: state.network,
        keychain: state.externalKeychain );
    final test = await descriptor.asString();

    return descriptor;
  }
  Future<Blockchain> initializeBlockchain() async {
    if (state.isElectrumBlockchain) {
      try {
        final blockchain = await Blockchain.create(
            config: const BlockchainConfig.electrum(
                config: ElectrumConfig(
                    stopGap: 20,
                    timeout: 5,
                    retry: 5,
                    url: "ssl://electrum.blockstream.info:50002",
                    validateDomain: false)));
        return blockchain; // Added return statement here
      } catch (_) {
        rethrow;
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
        network: state.network,
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

  BitcoinConfig copyWith({
    String? mnemonic,
    Network? network,
    KeychainKind? keychain,
    bool? isElectrumBlockchain,
  }) {
    return BitcoinConfig(
      mnemonic: mnemonic ?? this.mnemonic,
      network: network ?? this.network,
      externalKeychain: keychain ?? this.externalKeychain,
      internalKeychain: keychain ?? this.internalKeychain,
      isElectrumBlockchain: isElectrumBlockchain ?? this.isElectrumBlockchain,
    );
  }
}
