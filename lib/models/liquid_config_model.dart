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

  static Future<Wallet> createWallet(String mnemonic, Network network) async {
    final dbPath = await getDbDir();
    final descriptor = await Descriptor.newConfidential(network: network, mnemonic: mnemonic).then((value) => value);

    final wallet = Wallet.init(
      descriptor: descriptor,
      network: network,
      dbpath: dbPath,
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