import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:satsails/providers/auth_provider.dart';
import 'package:satsails/screens/creation/start.dart';
import 'package:satsails/screens/pay/components/conform_liquid_payment.dart';
import 'package:satsails/screens/settings/components/seed_words.dart';
import 'package:satsails/screens/settings/settings.dart';
import 'package:satsails/screens/receive/receive.dart';
import 'package:satsails/screens/accounts/accounts.dart';
import 'package:satsails/screens/creation/set_pin.dart';
import 'package:satsails/screens/analytics/analytics.dart';
import 'package:satsails/screens/login/open_pin.dart';
import 'package:satsails/screens/services/services.dart';
import 'package:satsails/screens/charge/charge.dart';
import 'package:satsails/screens/home/home.dart';
import 'package:satsails/screens/pay/pay.dart';
import 'package:satsails/screens/creation/recover_wallet.dart';
import 'package:satsails/screens/pay/components/confirm_bitcoin_payment.dart';
import 'package:satsails/screens/exchange/exchange.dart';
import 'package:satsails/screens/splash/splash.dart';
import 'package:satsails/screens/support/info.dart';
import 'package:satsails/screens/home/components/search_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:satsails/models/adapters/transaction_adapters.dart';
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
          final initialRoute = (mnemonic == null || mnemonic.isEmpty) ? '/' : '/confirm_liquid_payment';


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
            },
          );
        }
      },
    );
  }
}
