import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:satsails/screens/creation/start.dart';
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
import 'package:satsails/screens/pay/components/confirm_payment.dart';
import 'package:satsails/screens/exchange/exchange.dart';
import 'package:satsails/screens/support/info.dart';
import 'package:satsails/screens/home/components/search_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


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
      },

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
      },
    );
  }
}
