import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:satsails_wallet/screens/creation/start.dart';
import 'package:satsails_wallet/screens/settings/components/seed_words.dart';
import 'package:satsails_wallet/screens/settings/settings.dart';
import 'package:satsails_wallet/screens/receive/receive.dart';
import 'package:satsails_wallet/screens/accounts/accounts.dart';
import 'package:satsails_wallet/screens/creation/set_pin.dart';
import 'package:satsails_wallet/screens/analytics/analytics.dart';
import 'package:satsails_wallet/screens/login/open_pin.dart';
import 'package:satsails_wallet/screens/services/services.dart';
import 'package:satsails_wallet/screens/charge/charge.dart';
import 'package:satsails_wallet/screens/home/home.dart';
import 'package:satsails_wallet/screens/pay/pay.dart';
import 'package:satsails_wallet/screens/pay/components/confirm_payment.dart';
import 'package:satsails_wallet/screens/exchange/exchange.dart';
import 'package:satsails_wallet/screens/support/info.dart';
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
        return null;
      },

      routes: {
        '/': (context) => const Start(),
        '/seed_words': (context) => const SeedWords(),
        '/open_pin': (context) => OpenPin(),
        '/charge': (context) => Charge(),
        '/accounts': (context) => const Accounts(),
        '/receive': (context) => Receive(),
        '/settings': (context) => Settings(),
        '/analytics': (context) => Analytics(),
        '/set_pin': (context) => const SetPin(),
        '/exchange': (context) => Exchange(),
        '/info': (context) => Info(),
        '/apps': (context) => Services(),
        '/pay': (context) => Pay(),
        '/home': (context) => Home(),
      },
    );
  }
}
