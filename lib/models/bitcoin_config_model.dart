import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:path_provider/path_provider.dart'; // Import this package

class BitcoinConfigModel {
  final BitcoinConfig config;

  BitcoinConfigModel(this.config);

  Future<Descriptor> _createDescriptor(KeychainKind keychain) async {
    Mnemonic mnemonic = await Mnemonic.fromString(config.mnemonic);

    final descriptorSecretKey = await DescriptorSecretKey.create(
      network: config.network,
      mnemonic: mnemonic,
    );

    final descriptor = await Descriptor.newBip84(
      secretKey: descriptorSecretKey,
      network: config.network,
      keychain: keychain,
    );

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
          config: BlockchainConfig.electrum(
            config: ElectrumConfig(
              stopGap: BigInt.from(10),
              timeout: 5,
              retry: 5,
              url: "ssl://${config.electrumUrl}",
              validateDomain: false,
            ),
          ),
        );
        return blockchain;
      } catch (_) {
        throw Exception('Failed to initialize blockchain');
      }
    } else {
      final blockchain = await Blockchain.create(
        config: BlockchainConfig.esplora(
          config: EsploraConfig(
            baseUrl: 'https://blockstream.info/api/',
            stopGap: BigInt.from(10),
          ),
        ),
      );
      return blockchain;
    }
  }

  Future<Wallet> restoreWallet(Descriptor descriptor, Descriptor change) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final dbPath = '${appDocDir.path}/bdk_wallet.sqlite';

    final wallet = await Wallet.create(
      descriptor: descriptor,
      changeDescriptor: change,
      network: config.network,
      databaseConfig: DatabaseConfig.sqlite(
        config: SqliteDbConfiguration(
          path: dbPath,
        ),
      ),
    );
    return wallet;
  }
}

class BitcoinConfig {
  final String mnemonic;
  final Network network;
  final KeychainKind externalKeychain;
  final KeychainKind internalKeychain;
  final bool isElectrumBlockchain;
  final String electrumUrl;

  BitcoinConfig({
    required this.mnemonic,
    required this.network,
    required this.externalKeychain,
    required this.internalKeychain,
    required this.isElectrumBlockchain,
    required this.electrumUrl,
  });
}
