import 'dart:async';
import 'package:Satsails/app_widget.dart';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/models/eulen_transfer_model.dart';
import 'package:Satsails/models/nox_transfer_model.dart';
import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/restart_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:hive/hive.dart';
import 'package:lwk/lwk.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'models/auth_model.dart';

/// The main entry point for the application.
Future<void> main() async {
  // Ensure that the Flutter binding is initialized before calling native code.
  WidgetsFlutterBinding.ensureInitialized();

  // Run all app initialization tasks concurrently for faster startup.
  await _initializeApp();

  // Run the app with the RestartWidget at the root.
  runApp(
    const OverlaySupport.global(
      child: RestartWidget(
        child: AppWidget(),
      ),
    ),
  );
}

/// Handles all asynchronous app initialization.
Future<void> _initializeApp() async {
  // Use Future.wait to run non-dependent initializations in parallel.
  await Future.wait([
    // Set preferred screen orientation.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]),
    // Load environment variables.
    dotenv.load(fileName: ".env"),
    // Initialize Firebase.
    Firebase.initializeApp().then((_) {
      // Set up Crashlytics after Firebase is initialized.
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
        return true;
      };
    }),
    // Initialize Hive for local storage.
    _initHive(),
  ]);

  // These must run after the above initializations.
  await migrateMnemonicStorage();
  await LibLwk.init();
  await initialize();

  try {
    await FlutterBranchSdk.init(
        enableLogging: false,
        branchAttributionLevel: BranchAttributionLevel.NONE);
  } catch (e) {
    debugPrint("Branch SDK initialization failed: $e");
  }
}

/// Initializes Hive and registers all necessary adapters.
Future<void> _initHive() async {
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(WalletBalanceAdapter());
  Hive.registerAdapter(SideswapPegStatusAdapter());
  Hive.registerAdapter(SideswapCompletedSwapAdapter());
  Hive.registerAdapter(EulenTransferAdapter());
  Hive.registerAdapter(NoxTransferAdapter());
  Hive.registerAdapter(SideShiftAdapter());
}