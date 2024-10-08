import 'dart:async';
import 'dart:io';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/models/boltz/boltz_model.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/charge/components/pix_onboarding.dart';
import 'package:Satsails/screens/charge/components/pix_transaction_details.dart';
import 'package:Satsails/screens/home/main_screen.dart';
import 'package:Satsails/screens/pay/components/confirm_lightning_payment.dart';
import 'package:Satsails/screens/settings/components/support.dart';
import 'package:Satsails/screens/user/start_affiliate.dart';
import 'package:Satsails/screens/settings/components/claim_boltz.dart';
import 'package:Satsails/screens/spash/splash.dart';
import 'package:Satsails/screens/user/user_creation.dart';
import 'package:Satsails/screens/user/user_view.dart';
import 'package:boltz_dart/boltz_dart.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:lwk_dart/lwk_dart.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/screens/creation/start.dart';
import 'package:Satsails/screens/pay/components/confirm_liquid_payment.dart';
import 'package:Satsails/screens/settings/components/seed_words.dart';
import 'package:Satsails/screens/settings/settings.dart';
import 'package:Satsails/screens/receive/receive.dart';
import 'package:Satsails/screens/accounts/accounts.dart';
import 'package:Satsails/screens/creation/set_pin.dart';
import 'package:Satsails/screens/analytics/analytics.dart';
import 'package:Satsails/screens/login/open_pin.dart';
import 'package:Satsails/screens/services/services.dart';
import 'package:Satsails/screens/charge/charge.dart';
import 'package:Satsails/screens/pay/pay.dart';
import 'package:Satsails/screens/creation/recover_wallet.dart';
import 'package:Satsails/screens/pay/components/confirm_bitcoin_payment.dart';
import 'package:Satsails/screens/exchange/exchange.dart';
import 'package:Satsails/screens/home/components/search_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:Satsails/models/adapters/transaction_adapters.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pusher_beams/pusher_beams.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'screens/charge/components/pix.dart';
import 'screens/settings/components/backup_wallet.dart';
import 'package:Satsails/screens/shared/app_notification.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PusherBeams.instance.start('ac5722c9-48df-4a97-9b90-438fc759b42a');

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
        'PIX Payment',
        'You have received a new transaction',
        platformChannelSpecifics,
      );
    }
  });

  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  Hive.registerAdapter(TransactionDetailsAdapter());
  Hive.registerAdapter(BlockTimeAdapter());
  Hive.registerAdapter(OutPointAdapter());
  Hive.registerAdapter(TxOutSecretsAdapter());
  Hive.registerAdapter(TxOutAdapter());
  Hive.registerAdapter(TxAdapter());
  Hive.registerAdapter(BalanceAdapter());
  Hive.registerAdapter(WalletBalanceAdapter());
  Hive.registerAdapter(SideswapPegStatusAdapter());
  Hive.registerAdapter(SideswapCompletedSwapAdapter());
  Hive.registerAdapter(KeyPairAdapter());
  Hive.registerAdapter(PreImageAdapter());
  Hive.registerAdapter(LBtcSwapScriptV2StrAdapter());
  Hive.registerAdapter(ExtendedLbtcLnV2SwapAdapter());
  Hive.registerAdapter(LbtcBoltzAdapter());
  Hive.registerAdapter(BtcBoltzAdapter());
  Hive.registerAdapter(ExtendedBtcLnV2SwapAdapter());
  Hive.registerAdapter(BtcSwapScriptV2StrAdapter());
  Hive.registerAdapter(SwapTypeAdapter());
  Hive.registerAdapter(ChainAdapter());
  await BoltzCore.init();
  await LwkCore.init();

  runApp(
    InAppNotification(
      child: ProviderScope(
        child: MaterialApp(
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
          home: I18n(
            child: MainApp(),
          ),
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQueryData.copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },
        ),
      ),
    ),
  );
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Timer? _lockTimer;
  final int lockThresholdInSeconds = 300;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelLockTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _startLockCountdown();
    } else if (state == AppLifecycleState.resumed) {
      _cancelLockTimer();
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
    final authModel = ref.read(authModelProvider);
    final mnemonic = await authModel.getMnemonic();

    if (mnemonic == null || mnemonic.isEmpty) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
    } else {
      ref.read(sendToSeed.notifier).state = false;
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/open_pin', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<String?> mnemonicFuture = ref.read(authModelProvider).getMnemonic();
    final language = ref.watch(settingsProvider.notifier).state.language;

    return FutureBuilder<String?>(
      future: mnemonicFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Splash();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final mnemonic = snapshot.data;
          final initialRoute = (mnemonic == null || mnemonic.isEmpty) ? '/' : '/open_pin';

          return Stack(
            children: [
              MaterialApp(
                navigatorKey: navigatorKey,
                locale: Locale(language),
                initialRoute: initialRoute,
                themeMode: ThemeMode.dark,
                debugShowCheckedModeBanner: false,
                routes: {
                  '/': (context) => const Start(),
                  '/seed_words': (context) => const SeedWords(),
                  '/open_pin': (context) => OpenPin(),
                  '/charge': (context) => const Charge(),
                  '/accounts': (context) => const Accounts(),
                  '/receive': (context) => Receive(),
                  '/settings': (context) => const Settings(),
                  '/analytics': (context) => const Analytics(),
                  '/set_pin': (context) => const SetPin(),
                  '/exchange': (context) => Exchange(),
                  '/apps': (context) => const Services(),
                  '/pay': (context) => Pay(),
                  '/home': (context) => const MainScreen(),
                  '/recover_wallet': (context) => const RecoverWallet(),
                  '/search_modal': (context) => const SearchModal(),
                  '/confirm_bitcoin_payment': (context) => ConfirmBitcoinPayment(),
                  '/confirm_liquid_payment': (context) => ConfirmLiquidPayment(),
                  '/confirm_lightning_payment': (context) => ConfirmLightningPayment(),
                  '/claim_boltz_transactions': (context) => ClaimBoltz(),
                  '/backup_wallet': (context) => const BackupWallet(),
                  '/pix': (context) => const Pix(),
                  '/pix_onboarding': (context) => const PixOnBoarding(),
                  '/start_affiliate': (context) => const StartAffiliate(),
                  '/pix_transaction_details': (context) => const PixTransactionDetails(),
                  '/user_creation': (context) => const UserCreation(),
                  '/user_view': (context) => const UserView(),
                  '/support': (context) => const Support(),
                },
              ),
              // Including AppNotification to show in-app notifications
              const AppNotification(),
            ],
          );
        }
      },
    );
  }
}
