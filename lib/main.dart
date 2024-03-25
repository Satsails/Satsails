import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satsails_wallet/providers/settings_provider.dart';
import 'package:satsails_wallet/providers/accounts_provider.dart';
import 'package:satsails_wallet/providers/balance_provider.dart';
import 'package:satsails_wallet/pages/creation/start.dart';
import 'package:satsails_wallet/pages/settings/components/seed_words.dart';
import 'package:satsails_wallet/pages/settings/settings.dart';
import 'package:satsails_wallet/pages/receive/receive.dart';
import 'package:satsails_wallet/pages/accounts/accounts.dart';
import 'package:satsails_wallet/pages/creation/set_pin.dart';
import 'package:satsails_wallet/pages/analytics/analytics.dart';
import 'package:satsails_wallet/pages/login/open_pin.dart';
import 'package:satsails_wallet/pages/apps/apps.dart';
import 'package:satsails_wallet/pages/charge/charge.dart';
import 'package:satsails_wallet/pages/home/home.dart';
import 'package:satsails_wallet/pages/pay/pay.dart';
import 'package:satsails_wallet/pages/pay/components/confirm_payment.dart';
import 'package:satsails_wallet/pages/exchange/exchange.dart';
import 'package:satsails_wallet/pages/support/info.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  const storage = FlutterSecureStorage();
  String? mnemonic = await storage.read(key: 'mnemonic');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => AccountsProvider()),
        ChangeNotifierProvider(create: (context) => BalanceProvider()),
      ],
      child: MainApp(initialRoute: mnemonic == null ? '/' : '/open_pin'),
    ),
  );
}

class MainApp extends StatelessWidget {
final String initialRoute;

  const MainApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        if (settings.name == '/confirm_payment') {
          final Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
          final String address = arguments['address'] as String;
          final bool isLiquid = arguments['isLiquid'] as bool;

          return MaterialPageRoute(
            builder: (context) => ConfirmPayment(address: address, isLiquid: isLiquid),
          );
        }
        return null;
      },

      routes: {
        '/': (context) => const Start(),
        '/seed_words': (context) => const SeedWords(),
        '/open_pin': (context) => OpenPin(),
        '/charge': (context) => Charge(),
        '/accounts': (context) => Accounts(balances: {}),
        '/receive': (context) => Receive(),
        '/settings': (context) => Settings(),
        '/analytics': (context) => Analytics(),
        '/set_pin': (context) => const SetPin(),
        '/exchange': (context) => Exchange(),
        '/info': (context) => Info(),
        '/apps': (context) => Apps(),
        '/pay': (context) => Pay(),
        '/home': (context) => Home(),
      },
    );
  }
}
