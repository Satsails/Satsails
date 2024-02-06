import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../channels/greenwallet.dart' as greenwallet;

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isSwitched = false;

  @override
  void initState() {
    super.initState();
    // checkForWallets();
  }

  void checkForWallets() async {
    final _storage = const FlutterSecureStorage();
    String mnemonic = await _storage.read(key: 'mnemonic') ?? '';
    // Map<String, dynamic> walletInfo = await greenwallet.Channel('ios_wallet').fetchAllSubAccounts(mnemonic: mnemonic, connectionType: 'electrum-liquid');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).padding.top + kToolbarHeight,
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.blue,
                  height: MediaQuery.of(context).padding.top + kToolbarHeight,
                ),
              ),
            ],
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.white,
                title: Opacity(
                  opacity: 0.7,
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      filled: true,
                      hintStyle: TextStyle(color: Colors.grey[800]),
                      hintText: "Search for a transaction",
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                leading: Opacity(
                  opacity: 0.7,
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.black),
                    onPressed: () {
                    },
                  ),
                ),
                actions: <Widget>[
                  Opacity(
                    opacity: 0.7,
                    child: IconButton(
                      icon: const Icon(Icons.candlestick_chart_rounded, color: Colors.black),
                      onPressed: () {
                      },
                    ),
                  ),
                  Opacity(
                    opacity: 0.7,
                    child: IconButton(
                      icon: const Icon(Icons.currency_exchange_sharp, color: Colors.black),
                      onPressed: () {
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
   }
  }
