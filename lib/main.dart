import 'package:async/src/result/result.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

import 'providers/settings_provider.dart';
import 'providers/accounts_provider.dart';
import 'providers/balance_provider.dart';

import 'pages/creation/start.dart';
import 'pages/settings/components/seed_words.dart';
import 'pages/settings/settings.dart';
import 'pages/receive/receive.dart';
import 'pages/accounts/accounts.dart';
import 'pages/creation/set_pin.dart';
import 'pages/analytics/analytics.dart';
import 'pages/login/open_pin.dart';
import 'pages/apps/apps.dart';
import 'pages/charge/charge.dart';
import 'pages/home/home.dart';
import 'pages/pay/pay.dart';
import 'pages/pay/components/confirm_payment.dart';
import 'pages/exchange/exchange.dart';
import 'pages/support/info.dart';
import 'gdk.dart';
import 'package:satsails_wallet/data/models/gdk_models.dart';
import 'wallet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  const storage = FlutterSecureStorage();
  String? mnemonic = await storage.read(key: 'mnemonic');

  runApp(
    ProviderScope(
      child: MainApp(initialRoute: mnemonic == null ? '/' : '/open_pin'),
    ),
  );

  final libGdk = LibGdk();
  final result = await libGdk.generateMnemonic12();
  final dir = await getApplicationSupportDirectory();
  final config = GdkConfig(
      dataDir: dir.path,
      logLevel: GdkConfigLogLevelEnum.info);
  final wallet_service = WalletService();
  final connectionParams = GdkConnectionParams(name: 'electrum-testnet');
  wallet_service.init(callback: (value) {
    print(value);
  });
  final connect = await wallet_service.connect(connectionParams: connectionParams);
  final log_in_creds = GdkLoginCredentials(mnemonic: result.asValue!.value);
  final log_in = await wallet_service.loginUser(credentials: log_in_creds);
  final get_transactions = await wallet_service.getTransactions();
  print(get_transactions.asValue?.value);

  final mnemonica = result.asValue?.value;
  print(mnemonica);
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
