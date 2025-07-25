import 'dart:async';
import 'dart:io';

import 'package:Satsails/models/breez/sdk_instance.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter/foundation.dart';
// ANCHOR: init-sdk-app-group
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

const String appGroup = 'group.com.example.application';
const String mnemonicKey = 'BREEZ_SDK_LIQUID_SEED_MNEMONIC';

// Future<void> initSdk() async {
//   // Read the mnemonic from secure storage using the app group
//   final FlutterSecureStorage storage = const FlutterSecureStorage(
//     iOptions: IOSOptions(
//       accessibility: KeychainAccessibility.first_unlock,
//       groupId: appGroup,
//     ),
//   );
//   final String? mnemonic = await storage.read(key: mnemonicKey);
//   if (mnemonic == null) {
//     throw Exception('Mnemonic not found');
//   }
//
//   // Create the default config, providing your Breez API key
//   Config config = defaultConfig(network: LiquidNetwork.mainnet, breezApiKey: "<your-Breez-API-key>");
//
//   // Set the working directory to the app group path
//   config = config.copyWith(workingDir: await getWorkingDir());
//
//   ConnectRequest connectRequest = ConnectRequest(mnemonic: mnemonic, config: config);
//
//   await breezSDKLiquid.connect(req: connectRequest);
// }

// Future<String> getWorkingDir() async {
//   String path = '';
//   if (defaultTargetPlatform == TargetPlatform.android) {
//     final Directory documentsDir = await getApplicationDocumentsDirectory();
//     path = documentsDir.path;
//   } else if (defaultTargetPlatform == TargetPlatform.iOS) {
//     final Directory? sharedDirectory = await AppGroupDirectory.getAppGroupDirectory(
//       appGroup,
//     );
//     if (sharedDirectory == null) {
//       throw Exception('Could not get shared directory');
//     }
//     path = sharedDirectory.path;
//   }
//   return "$path/breezSdkLiquid";
// }
// ANCHOR_END: init-sdk-app-group
