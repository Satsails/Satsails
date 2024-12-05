import 'dart:async';
import 'dart:io';

import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/restart_widget.dart';
import 'package:Satsails/screens/shared/transaction_notifications_wrapper.dart';
import 'package:Satsails/screens/spash/splash.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:lwk_dart/lwk_dart.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pusher_beams/pusher_beams.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import './app_router.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await dotenv.load(fileName: ".env");

  await PusherBeams.instance.start(dotenv.env['PUSHERINSTANCE']!);
  PusherBeams.instance.onMessageReceivedInTheForeground((message) async {
    if (Platform.isAndroid || Platform.isIOS) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'pix_payments_channel',
        'PIX Payments',
        channelDescription: 'Notifications for received PIX transactions.',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );
      const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: 'PIX Payments',
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        'Depósito de Depix',
        'Você recebeu um novo depósito de Depix.',
        platformChannelSpecifics,
      );
      final container = ProviderContainer();
      container.read(syncOnAppOpenProvider.notifier).state = true;
    }
  });

  // Initialize Hive for local storage
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(WalletBalanceAdapter());
  Hive.registerAdapter(SideswapPegStatusAdapter());
  Hive.registerAdapter(SideswapCompletedSwapAdapter());

  await LwkCore.init();
  await FlutterBranchSdk.init(enableLogging: false, disableTracking: true);

  FlutterBranchSdk.listSession().listen((data) async {
    if (data.containsKey("affiliateCode")) {
      final insertedAffiliateCode = data["affiliateCode"];
      final upperCaseCode = insertedAffiliateCode.toUpperCase();
      final box = await Hive.openBox('affiliate');
      final currentInsertedAffiliateCode = box.get('insertedAffiliateCode', defaultValue: '');
      if (insertedAffiliateCode != null && currentInsertedAffiliateCode.isEmpty) {
        box.put('insertedAffiliateCode', upperCaseCode);
      }
    }
  });

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
  final int lockThresholdInSeconds = 300; // 5 minutes
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Observe app lifecycle
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    // Initialize the router
    _initializeRouter();
  }

  Future<void> _initializeRouter() async {
    final authModel = ref.read(authModelProvider);
    final mnemonic = await authModel.getMnemonic();

    final initialRoute = (mnemonic == null || mnemonic.isEmpty) ? '/' : '/open_pin';

    setState(() {
      _router = AppRouter.createRouter(initialRoute);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Stop observing
    _cancelLockTimer(); // Cancel the timer if the app is closed
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _startLockCountdown();
    } else if (state == AppLifecycleState.resumed) {
      if (ref.read(syncOnAppOpenProvider)) {
        ref.read(backgroundSyncNotifierProvider.notifier).performSync();
        ref.read(syncOnAppOpenProvider.notifier).state = false;
      }
      _cancelLockTimer();
    }
  }

  void _startLockCountdown() {
    _cancelLockTimer(); // Ensure no previous timer is running
    _lockTimer = Timer(Duration(seconds: lockThresholdInSeconds), _lockApp);
  }

  void _cancelLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = null;
  }

  Future<void> _lockApp() async {
    ref.read(sendTxProvider.notifier).resetToDefault();
    ref.read(sendBlocksProvider.notifier).state = 1;

    final authModel = ref.read(authModelProvider);
    final mnemonic = await authModel.getMnemonic();

    if (mnemonic == null || mnemonic.isEmpty) {
      _router!.go('/');
    } else {
      _router!.go('/open_pin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(settingsProvider).language;

    if (_router == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Splash(),
      );
    }

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
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: I18n(
            child: child!,
          ),
        );
      },
    );
  }
}
