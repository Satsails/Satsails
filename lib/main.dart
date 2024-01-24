import 'package:flutter/material.dart';
import './channels/greenwallet.dart' as greenwallet;

void main() async {
  runApp(const MainApp());
  await greenwallet.Channel('ios_wallet').walletInit();
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key});

  Future<void> init() async {
    await greenwallet.Channel('ios_wallet').createWallet(connectionType: 'mainnet');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: init(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            else
              return const Scaffold(
                body: Center(
                  child: Text('Hello World'),
                ),
              );
          }
        },
      ),
    );
  }
}