import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../channels/greenwallet.dart' as greenwallet;

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {
    super.initState();
    checkForWallets();
  }

  void checkForWallets() async {
    final _storage = FlutterSecureStorage();
    String mnemonic = await _storage.read(key: 'mnemonic') ?? '';
    // Map<String, dynamic> walletInfo = await greenwallet.Channel('ios_wallet').fetchAllSubAccounts(mnemonic: mnemonic, connectionType: 'electrum-liquid');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text('Home')),
    );
  }
}