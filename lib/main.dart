import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/accounts_provider.dart';
import 'providers/balance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './channels/greenwallet.dart' as greenwallet;
import 'pages/creation/start.dart';
import 'pages/settings/components/seed_words.dart';
import 'pages/settings/settings.dart';
import 'pages/receive/receive.dart';
import 'pages/accounts/accounts.dart';
import 'pages/creation/set_pin.dart';
import 'pages/analytics/analytics.dart';
import 'pages/login/open_pin.dart';
import 'pages/home/home.dart';
import 'pages/pay/pay.dart';
import 'pages/pay/components/confirm_payment.dart';
import 'pages/exchange/exchange.dart';
import 'pages/support/info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  String? mnemonic = await storage.read(key: 'mnemonic');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => AccountsProvider()),
        ChangeNotifierProvider(create: (context) => BalanceProvider()),
      ],
      child: MainApp(initialRoute: mnemonic == null ? '/' : '/home'),
    ),
  );
  await greenwallet.Channel('ios_wallet').walletInit();
}

class MainApp extends StatelessWidget {
  final String initialRoute;

  const MainApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        if (settings.name == '/confirm_payment') {
          final String address = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ConfirmPayment(address: address),
          );
        }

        // Handle other routes if needed
        return null;
      },
      routes: {
        '/': (context) => const Start(),
        '/seed_words': (context) => const SeedWords(),
        '/open_pin': (context) => OpenPin(),
        '/accounts': (context) => Accounts(balances: {}),
        '/receive': (context) => Receive(),
        '/settings': (context) => Settings(),
        '/analytics': (context) => Analytics(),
        '/set_pin': (context) => const SetPin(),
        '/exchange': (context) => Exchange(),
        '/info': (context) => Info(),
        '/pay': (context) => Pay(),
        '/home': (context) => Home(),
      },
    );
  }
}
