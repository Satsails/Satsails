import 'package:flutter/material.dart';
import './channels/greenwallet.dart' as greenwallet;

void main() async {
  runApp(const MainApp());
  await greenwallet.Channel('ios_wallet').walletInit();
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: FutureBuilder<String>(
      //   future: greenwallet.Channel('ios_wallet').wa(),
      //   builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const CircularProgressIndicator();
      //     } else {
      //       if (snapshot.hasError)
      //         return Text('Error: ${snapshot.error}');
      //       else
      //         return Text('Loaded: ${snapshot.data}');
      //     }
      //   },
      // ),
      home: const Scaffold(
        body: Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}