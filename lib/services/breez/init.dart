import 'dart:async';

import 'package:Satsails/services/breez/sdk_instance.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initializeSDK(String mnemonic) async {

  final appDir = await getApplicationDocumentsDirectory();

  final apiKey = dotenv.env['BREEZ_API_KEY']!;

  Config config = defaultConfig(network: LiquidNetwork.mainnet, breezApiKey: apiKey);

  config = config.copyWith(workingDir: appDir.path);

  ConnectRequest connectRequest = ConnectRequest(mnemonic: mnemonic, config: config);

  return await breezSDKLiquid.connect(req: connectRequest);
}