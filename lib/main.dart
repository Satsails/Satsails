import 'package:Satsails/models/boltz/boltz_model.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/screens/pay/components/confirm_lightning_payment.dart';
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
import 'package:Satsails/screens/support/info.dart';
import 'package:Satsails/screens/home/components/search_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:Satsails/models/adapters/transaction_adapters.dart';
import 'package:responsive_framework/responsive_framework.dart';


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
  Hive.registerAdapter(ExtendedKeyPairAdapter());
  Hive.registerAdapter(ExtendedPreImageAdapter());
  Hive.registerAdapter(ExtendedLBtcSwapScriptV2StrAdapter());
  Hive.registerAdapter(BoltzAdapter());

  await BoltzCore.init();
  await LwkCore.init();

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProviderScope(
        child: MainApp(),
      ),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<String?> mnemonicFuture = ref.read(authModelProvider).getMnemonic();
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

          return MaterialApp(
            initialRoute: initialRoute,
            debugShowCheckedModeBanner: false,
            builder: (context, child) => ResponsiveBreakpoints.builder(child: child!,
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
            ),
            routes: {
              '/': (context) => const Start(),
              '/seed_words': (context) => const SeedWords(),
              '/open_pin': (context) => OpenPin(),
              '/charge': (context) => Charge(),
              '/accounts': (context) => const Accounts(),
              '/receive': (context) => Receive(),
              '/settings': (context) => const Settings(),
              '/analytics': (context) => Analytics(),
              '/set_pin': (context) => const SetPin(),
              '/exchange': (context) => Exchange(),
              '/info': (context) => Info(),
              '/apps': (context) => const Services(),
              '/pay': (context) => Pay(),
              '/home': (context) => const Home(),
              '/recover_wallet': (context) => const RecoverWallet(),
              '/search_modal': (context) => SearchModal(),
              '/confirm_bitcoin_payment': (context) => ConfirmBitcoinPayment(),
              '/confirm_liquid_payment': (context) => ConfirmLiquidPayment(),
              '/confirm_lightning_payment': (context) => ConfirmLightningPayment(),
            },
          );
        }
      },
    );
  }
}
