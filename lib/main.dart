import 'package:flutter/material.dart';
import './channels/greenwallet.dart' as greenwallet;

void main() async {
  runApp(const MainApp());
  await greenwallet.Channel('ios_wallet').walletInit();
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key});

  Future<Map<String, dynamic>> init() async {
    Map<String, dynamic> walletInfo = await greenwallet.Channel('ios_wallet').createWallet(connectionType: 'electrum-mainnet');
    // Map<String, dynamic> newWallet = await greenwallet.Channel('ios_wallet').createSubAccount(mnemonic: walletInfo['mnemonic']);
    // String address = await greenwallet.Channel('ios_wallet').getReceiveAddress(pointer: newWallet['pointer'], mnemonic: walletInfo['mnemonic'], connectionType: 'electrum-mainnet');
    // int pointer = await greenwallet.Channel('ios_wallet').getPointer(mnemonic: walletInfo['mnemonic']);
    Map<String, dynamic> balance = await greenwallet.Channel('ios_wallet').getBalance(pointer: walletInfo['pointer'], mnemonic: walletInfo['mnemonic'], connectionType: 'electrum-mainnet');
    return balance;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: init(),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            else
              return Scaffold(
                body: Center(
                  child: Text('Wallet Info: ${snapshot.data.toString()}'),
                ),
              );
          }
        },
      ),
    );
  }
}