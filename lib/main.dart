import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './channels/greenwallet.dart' as greenwallet;
import 'pages/creation/start.dart';
import 'pages/settings/components/seed_words.dart';
import 'pages/settings/settings.dart';
import 'pages/creation/set_pin.dart';
import 'pages/login/open_pin.dart';
import 'pages/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final _storage = FlutterSecureStorage();
  String? mnemonic = await _storage.read(key: 'mnemonic');
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsProvider(),
      child: MainApp(initialRoute: mnemonic == null ? '/' : '/settings'),
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
      routes: {
        '/': (context) => const Start(),
        '/seed_words': (context) => const SeedWords(),
        '/open_pin': (context) => OpenPin(),
        '/settings': (context) => Settings(),
        '/set_pin': (context) => const SetPin(),
        '/home': (context) => Home(),
      },
    );
  }
}