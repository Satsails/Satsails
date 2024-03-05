import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../channels/greenwallet.dart' as greenwallet;
import '../../../helpers/networks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import '../transactions/components/transactions_builder.dart';

class Receive extends StatefulWidget {
  @override
  _ReceiveState createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> {
  int _selectedButtonIndex = 1;
  Map<String, dynamic> _address = {};
  List<Object?> _transactions = [];
  final _storage = FlutterSecureStorage();
  late String mnemonic;

  @override
  void initState() {
    super.initState();
    loadMnemonic().then((_) {
      _fetchData();
    });
  }

  Future<void> loadMnemonic() async {
    mnemonic = await _storage.read(key: 'mnemonic') ?? '';
  }

  void _handleButtonPress(int index) {
    setState(() {
      _selectedButtonIndex = _selectedButtonIndex == index ? -1 : index;
    });

    if (_selectedButtonIndex == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lightning is not supported yet'),
        ),
      );
      setState(() {
        _selectedButtonIndex = 1;
      });
    } else if (_selectedButtonIndex == 1 || _selectedButtonIndex == 2) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    final channel = greenwallet.Channel('ios_wallet');

    final connectionType = _selectedButtonIndex == 1
        ? NetworkSecurityCase.bitcoinSS.network
        : NetworkSecurityCase.liquidSS.network;

    final address = await channel.getReceiveAddress(
      mnemonic: mnemonic,
      connectionType: connectionType,
    );

    final transactions = await channel.getTransactions(
      mnemonic: mnemonic,
      connectionType: connectionType,
    );

    setState(() {
      _address = address;
      _transactions = transactions;
    });
  }

  Widget buildElevatedButton(int index, String buttonText) {
    return ElevatedButton(
      onPressed: () => _handleButtonPress(index),
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedButtonIndex == index ? Colors.blue : null,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          buttonText,
          style: TextStyle(
            color: _selectedButtonIndex == index ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget buildQrCode(String? address) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: address != null
          ? QrImageView(
        backgroundColor: Colors.white,
        data: address,
        version: QrVersions.auto,
        size: 300.0,
      )
          : CircularProgressIndicator(),
    );
  }


  Widget buildAddressText(String? address) {
    return GestureDetector(
      onTap: () {
        if (address != null) {
          Clipboard.setData(ClipboardData(text: address));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Address copied to clipboard: $address'),
            ),
          );
        }
      },
      child: Text(
        address ?? '',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
          color: Colors.blue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Receive'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildElevatedButton(0, 'Lightning'),
                buildElevatedButton(1, 'Bitcoin'),
                buildElevatedButton(2, 'Liquid'),
              ],
            ),
            buildQrCode(_address['address']),
            buildAddressText(_address['address']),
            SizedBox(height: 16.0),
            Divider(height: 1),
            buildTransactions(_transactions, context),
          ],
        ),
      ),
    );
  }
}
