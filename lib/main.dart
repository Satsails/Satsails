import 'dart:async';
import 'dart:io';
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
import 'models/auth_model.dart';

/// The main entry point for the application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable edge-to-edge with transparent bars
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  await _initializeApp();

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
  // Run non-dependent initializations in parallel
  await Future.wait([
    // Lock orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]),

    // Load environment variables
    dotenv.load(fileName: ".env"),

    // Initialize Firebase
    Firebase.initializeApp().then((_) {
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
        return true;
      };
    }),

    _initHive(),
  ]);

  // Sequential initializations
  await migrateMnemonicToAppGroup();
  await LibLwk.init();
  await FlutterBreezLiquid.init();
}

/// Initializes Hive and registers adapters.
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
