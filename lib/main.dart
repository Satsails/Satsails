import 'dart:async';
import 'dart:ui';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/models/eulen_transfer_model.dart';
import 'package:Satsails/models/firebase_model.dart';
import 'package:Satsails/models/nox_transfer_model.dart';
import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/restart_widget.dart';
import 'package:Satsails/screens/shared/transaction_notifications_wrapper.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
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

  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.playIntegrity,
  //   appleProvider: AppleProvider.appAttest
  // );

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    return true;
  };

  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(WalletBalanceAdapter());
  Hive.registerAdapter(SideswapPegStatusAdapter());
  Hive.registerAdapter(SideswapCompletedSwapAdapter());
  Hive.registerAdapter(EulenTransferAdapter());
  Hive.registerAdapter(NoxTransferAdapter());
  Hive.registerAdapter(SideShiftAdapter());


  await LibLwk.init();
  await initialize();

  try {
    await FlutterBranchSdk.init(
        enableLogging: false,
        branchAttributionLevel: BranchAttributionLevel.NONE);
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
  late final GoRouter _router;
  late final StreamSubscription<Map> _branchSubscription;

  // No longer using a Timer. We'll use a nullable DateTime.
  DateTime? _pauseTime;

  bool _isFirstResume = true;
  bool _isBlurred = false;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter('/splash');
    WidgetsBinding.instance.addObserver(this);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    _branchSubscription = FlutterBranchSdk.listSession().listen((data) async {
      if (data.containsKey("affiliateCode")) {
        final insertedAffiliateCode = data["affiliateCode"];
        final upperCaseCode = insertedAffiliateCode.toUpperCase();
        final box = await Hive.openBox('user');
        final currentInsertedAffiliateCode =
        box.get('affiliateCode', defaultValue: '');
        if (insertedAffiliateCode != null &&
            currentInsertedAffiliateCode.isEmpty) {
          box.put('affiliateCode', upperCaseCode);
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      switch (state) {
        case AppLifecycleState.resumed:
          _isBlurred = false;
          if (_isFirstResume) {
            _isFirstResume = false;
            _pauseTime = null;
            break;
          }

          final gracePeriod = const Duration(seconds: 180);
          if (_pauseTime != null) {
            final elapsed = DateTime.now().difference(_pauseTime!);
            if (elapsed > gracePeriod) {
              _router.go('/splash');
            }
          }

          // Reset the pause time for the next cycle.
          _pauseTime = null;
          break;

        case AppLifecycleState.inactive:
          _isBlurred = true;
          if (_pauseTime == null) {
            _pauseTime = DateTime.now();
          }
          break;

        case AppLifecycleState.paused:
          _isBlurred = true;
          _pauseTime = DateTime.now();
          break;

        case AppLifecycleState.detached:
        case AppLifecycleState.hidden:
        _isBlurred = true;
        if (_pauseTime == null) {
          _pauseTime = DateTime.now();
        }
        break;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _branchSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(settingsProvider).language;

    I18n.define(Locale(language));

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          ScreenUtilInit(
            designSize: const Size(430, 932),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp.router(
                routerConfig: _router,
                locale: Locale(language),
                themeMode: ThemeMode.dark,
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  scaffoldBackgroundColor: Colors.black,
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Colors.black,
                    elevation: 0,
                  ),
                ),
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
          ),
          // This is the privacy blur overlay
          if (_isBlurred)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
        ],
      ),
    );
  }
}