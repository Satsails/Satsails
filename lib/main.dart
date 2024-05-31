import 'package:Satsails/helpers/life_cycle_handler.dart';
import 'package:Satsails/models/boltz/boltz_model.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/pay/components/confirm_lightning_payment.dart';
import 'package:Satsails/screens/settings/components/claim_boltz.dart';
import 'package:boltz_dart/boltz_dart.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
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
import 'package:Satsails/screens/home/home.dart';
import 'package:Satsails/screens/pay/pay.dart';
import 'package:Satsails/screens/creation/recover_wallet.dart';
import 'package:Satsails/screens/pay/components/confirm_bitcoin_payment.dart';
import 'package:Satsails/screens/exchange/exchange.dart';
import 'package:Satsails/screens/splash/splash.dart';
import 'package:Satsails/screens/home/components/search_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:Satsails/models/adapters/transaction_adapters.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  Hive.registerAdapter(SideswapPegStatusAdapter());
  Hive.registerAdapter(SideswapCompletedSwapAdapter());
  Hive.registerAdapter(KeyPairAdapter());
  Hive.registerAdapter(PreImageAdapter());
  Hive.registerAdapter(LBtcSwapScriptV2StrAdapter());
  Hive.registerAdapter(ExtendedLbtcLnV2SwapAdapter());
  Hive.registerAdapter(BoltzAdapter());
  Hive.registerAdapter(SwapTypeAdapter());
  Hive.registerAdapter(ChainAdapter());

  await BoltzCore.init();
  await LwkCore.init();


  runApp(
    MaterialApp(
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
        child: const ProviderScope(
          child: MainApp(),
        ),
      ),
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final scale = mediaQueryData.textScaleFactor.clamp(1.0, 1.3);
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        );
      },
    ),
  );
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(LifecycleHandler(onAppPaused: handleAppPaused));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(LifecycleHandler(onAppPaused: handleAppPaused));
    super.dispose();
  }

  Future<void> handleAppPaused() async {
    final authModel = ref.read(authModelProvider);
    final mnemonic = await authModel.getMnemonic();

    if (mnemonic == null || mnemonic.isEmpty) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
    } else {
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
            final initialRoute = (mnemonic == null || mnemonic.isEmpty)
                ? '/'
                : '/analytics';

            return MaterialApp(
              navigatorKey: navigatorKey,
              locale: Locale(language),
              initialRoute: initialRoute,
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
                '/home': (context) => const Home(),
                '/recover_wallet': (context) => const RecoverWallet(),
                '/search_modal': (context) => SearchModal(),
                '/confirm_bitcoin_payment': (context) => ConfirmBitcoinPayment(),
                '/confirm_liquid_payment': (context) => ConfirmLiquidPayment(),
                '/confirm_lightning_payment': (context) => ConfirmLightningPayment(),
                '/claim_boltz_transactions': (context) => ClaimBoltz(),
              },
            );
          }
        }
    );
  }
}