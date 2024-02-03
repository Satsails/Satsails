import 'package:flutter/material.dart';
import './channels/greenwallet.dart' as greenwallet;
import 'pages/creation/start.dart';
import 'pages/creation/seed_words.dart';

void main() async {
  runApp(const MainApp());
  await greenwallet.Channel('ios_wallet').walletInit();
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Start(),
        '/seed_words': (context) => const SeedWords(),
      },
    );
  }
}