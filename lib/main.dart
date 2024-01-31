import 'package:flutter/material.dart';
import './channels/greenwallet.dart' as greenwallet;

void main() async {
  runApp(const MainApp());
  await greenwallet.Channel('ios_wallet').walletInit();
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key});

  Future<List<Object?>> init() async {
    String mnemonic = "jewel never off nice bar puzzle doll onion design erase holiday round";
    Map<String, dynamic> walletInfo = await greenwallet.Channel('ios_wallet').createWallet(connectionType: 'electrum-testnet', mnemonic: mnemonic);
    // Map<String, dynamic> newWallet = await greenwallet.Channel('ios_wallet').createSubAccount(mnemonic: walletInfo['mnemonic']);
    // String address = await greenwallet.Channel('ios_wallet').getReceiveAddress(pointer: walletInfo['pointer'], mnemonic: mnemonic, connectionType: 'electrum-testnet');
    // int pointer = await greenwallet.Channel('ios_wallet').getPointer(mnemonic: walletInfo['mnemonic']);
    // Map<String, dynamic> balance = await greenwallet.Channel('ios_wallet').getBalance(pointer: walletInfo['pointer'], mnemonic: mnemonic, connectionType: 'electrum-testnet');
    List<Object?> transactions = await greenwallet.Channel('ios_wallet').getTransactions(mnemonic: mnemonic, connectionType: 'electrum-testnet', pointer: walletInfo['pointer']);
    print("demins transactions");
    print(transactions);
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: init(),
        builder: (BuildContext context, AsyncSnapshot<List<Object?>> snapshot) {
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