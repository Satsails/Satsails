import 'dart:async';

import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/models/boltz_model.dart';
import 'package:Satsails/models/coinos_ln_model.dart';
import 'package:Satsails/models/eulen_transfer_model.dart';
import 'package:Satsails/models/firebase_model.dart';
import 'package:Satsails/models/nox_transfer_model.dart';
import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/restart_widget.dart';
import 'package:Satsails/screens/shared/transaction_notifications_wrapper.dart';
import 'package:Satsails/screens/spash/splash.dart';
import 'package:boltz/boltz.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:lwk/lwk.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import './app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp();
  await FirebaseService.getAndRefreshFCMToken();
  await FirebaseService.listenForForegroundPushNotifications();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(WalletBalanceAdapter());
  Hive.registerAdapter(SideswapPegStatusAdapter());
  Hive.registerAdapter(SideswapCompletedSwapAdapter());
  Hive.registerAdapter(CoinosPaymentAdapter());
  Hive.registerAdapter(EulenTransferAdapter());
  Hive.registerAdapter(NoxTransferAdapter());
  Hive.registerAdapter(SideShiftAdapter());
  Hive.registerAdapter(LbtcBoltzAdapter());
  Hive.registerAdapter(ExtendedLbtcLnV2SwapAdapter());
  Hive.registerAdapter(SwapTypeAdapter());
  Hive.registerAdapter(ChainAdapter());
  Hive.registerAdapter(PreImageAdapter());
  Hive.registerAdapter(KeyPairAdapter());
  Hive.registerAdapter(LBtcSwapScriptV2StrAdapter());

  await LibLwk.init();
  await BoltzCore.init();

  try {
    await FlutterBranchSdk.init(enableLogging: false, branchAttributionLevel: BranchAttributionLevel.NONE);
  } catch (e) {
    // Ignoring errors
  }

  runApp(
    const OverlaySupport.global(
      child: RestartWidget(
        child: ProviderScope(
          child: TransactionNotificationsListener(
            child: MainApp(),
          ),
        ),
      ),
    ),
  );
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> with WidgetsBindingObserver {
  Timer? _lockTimer;
  Timer? _syncTimer;
  Timer? _purchaseTimer;
  final int lockThresholdInSeconds = 20;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    _initializeRouter();
    FlutterBranchSdk.listSession().listen((data) async {
      if (data.containsKey("affiliateCode")) {
        final insertedAffiliateCode = data["affiliateCode"];
        final upperCaseCode = insertedAffiliateCode.toUpperCase();
        final box = await Hive.openBox('user');
        final currentInsertedAffiliateCode = box.get('affiliateCode', defaultValue: '');
        if (insertedAffiliateCode != null && currentInsertedAffiliateCode.isEmpty) {
          box.put('affiliateCode', upperCaseCode);
        }
      }
    });
  }

  Future<void> _initializeRouter() async {
    final authModel = ref.read(authModelProvider);
    final mnemonic = await authModel.getMnemonic();

    final initialRoute = (mnemonic == null || mnemonic.isEmpty) ? '/' : '/open_pin';

    setState(() {
      _router = AppRouter.createRouter(initialRoute);
    });

    _startSyncTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelLockTimer();
    _cancelSyncTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _startLockCountdown();
      _cancelSyncTimer();
    } else if (state == AppLifecycleState.resumed) {
      _cancelLockTimer();
      _startSyncTimer();
    }
  }

  void _startLockCountdown() {
    _cancelLockTimer();
    _lockTimer = Timer(Duration(seconds: lockThresholdInSeconds), _lockApp);
  }

  void _cancelLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = null;
  }

  Future<void> _lockApp() async {
    ref.read(sendTxProvider.notifier).resetToDefault();
    ref.read(sendBlocksProvider.notifier).state = 1;
    ref.read(appLockedProvider.notifier).state = true;
    final authModel = ref.read(authModelProvider);

    final mnemonic = await authModel.getMnemonic();
    if (mnemonic == null || mnemonic.isEmpty) {
      _router!.go('/');
    } else {
      _router!.go('/open_pin');
    }
  }

  void _startSyncTimer() {
    _cancelSyncTimer();

    _syncTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      final appIsLocked = ref.read(appLockedProvider) == true;
      final shouldUpdateMemory = ref.read(shouldUpdateMemoryProvider);
      if (!appIsLocked && shouldUpdateMemory) {
        ref.read(backgroundSyncNotifierProvider.notifier).performSync();
      } else {
        print('Skipping sync operations');
      }
    });

    _purchaseTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      final auth = ref.watch(userProvider).jwt;
      final appIsLocked = ref.read(appLockedProvider) == true;
      if (!appIsLocked && auth.isNotEmpty) {
        ref.read(updateCurrencyProvider);
        ref.read(getFiatPurchasesProvider);
      }
    });
  }

  void _cancelSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _purchaseTimer?.cancel();
    _purchaseTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(settingsProvider).language;

    I18n.define(Locale(language));

    if (_router == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Splash(),
      );
    }

    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: _router!,
          locale: Locale(language),
          themeMode: ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('pt'),
          ],
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: I18n(
                initialLocale: Locale(language),
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}
