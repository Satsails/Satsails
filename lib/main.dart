import 'package:flutter/material.dart';
import './channels/greenwallet.dart' as greenwallet;

void main() async {
  runApp(const MainApp());
  await greenwallet.Channel('ios_wallet').walletInit();
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key});

  Future<String> init() async {
    String mnemonic = "jewel never off nice bar puzzle doll onion design erase holiday round";
    Map<String, dynamic> walletInfo = await greenwallet.Channel('ios_wallet').createWallet(connectionType: 'electrum-testnet', mnemonic: mnemonic);
    // Map<String, dynamic> newWallet = await greenwallet.Channel('ios_wallet').createSubAccount(mnemonic: walletInfo['mnemonic']);
    Map<String, dynamic> address = await greenwallet.Channel('ios_wallet').getReceiveAddress(pointer: walletInfo['pointer'], mnemonic: mnemonic, connectionType: 'electrum-testnet');
    print(address);
    // int pointer = await greenwallet.Channel('ios_wallet').getPointer(mnemonic: walletInfo['mnemonic']);
    // Map<String, dynamic> balance = await greenwallet.Channel('ios_wallet').getBalance(pointer: walletInfo['pointer'], mnemonic: mnemonic, connectionType: 'electrum-testnet-liquid');
    // print(balance);
    // List<Object?> transactions = await greenwallet.Channel('ios_wallet').getTransactions(mnemonic: mnemonic, connectionType: 'electrum-testnet-liquid', pointer: walletInfo['pointer']);
    String sendTransaction = await greenwallet.Channel('ios_wallet').sendToAddress(mnemonic: mnemonic, connectionType: 'electrum-testnet', pointer: walletInfo['pointer'], address: "tb1qttvjdp7jx5wpmrqmed4dtuw99a4thpx6u5505c", amount: 2000, assetId: "");
    return sendTransaction;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: init(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
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