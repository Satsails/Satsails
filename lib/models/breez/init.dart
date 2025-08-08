import 'dart:async';

import 'package:Satsails/models/breez/sdk_instance.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

// In your services/breez/init.dart file

Future<void> initializeSDK(String mnemonic) async {
  // It now calls the shared function to build the request
  final connectRequest = await createConnectRequest(mnemonic);
  return await breezSDKLiquid.connect(req: connectRequest);
}

Future<ConnectRequest> createConnectRequest(String mnemonic) async {
  final appDir = await getApplicationDocumentsDirectory();

  final apiKey = dotenv.env['BREEZ_API_KEY'];

  if (apiKey == null) {
    throw Exception("BREEZ_API_KEY is not set in .env file");
  }

  Config config = defaultConfig(network: LiquidNetwork.mainnet, breezApiKey: apiKey);
  config = config.copyWith(workingDir: appDir.path);

  return ConnectRequest(mnemonic: mnemonic, config: config);
}