import 'package:lwk_dart/lwk_dart.dart';
import 'package:path_provider/path_provider.dart';

class LiquidConfigModel {
  final LiquidConfig config;

  LiquidConfigModel(this.config);

  static Future<String> getDbDir() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/lwk-db";
      return path;
    } catch (e) {
      print('Error getting current directory: $e');
      rethrow;
    }
  }

  static Future<Descriptor> createDescriptor(String mnemonic, Network network) async {
    final descriptor = await Descriptor.create(
      network: network,
      mnemonic: mnemonic,
    );

    return descriptor;
  }

  static Future<Wallet> createWallet(String mnemonic, Network network) async {
    final dbPath = await getDbDir();
    final descriptor = await createDescriptor(mnemonic, network);

    final wallet = await Wallet.create(
      descriptor: descriptor.descriptor,
      network: network,
      dbPath: dbPath,
    );

    return wallet;
  }
}

class LiquidConfig {
  final String mnemonic;
  final Network network;
  final Wallet wallet;


  LiquidConfig({
    required this.mnemonic,
    required this.network,
    required this.wallet,
  });
}