import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../channels/greenwallet.dart' as greenwallet;
import '../../../helpers/networks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

class Receive extends StatefulWidget {
  @override
  _ReceiveState createState() => _ReceiveState();
}

class _ReceiveState extends State<Receive> {
  int _selectedButtonIndex = -1;
  Map<String, dynamic> _address = {};
  final _storage = FlutterSecureStorage();
  late String mnemonic;

  @override
  void initState() {
    super.initState();
    loadMnemonic();
  }

  Future<void> loadMnemonic() async {
    mnemonic = await _storage.read(key: 'mnemonic') ?? '';
  }

  void _handleButtonPress(int index) async {
    setState(() {
      _selectedButtonIndex = _selectedButtonIndex == index ? -1 : index;

    });

    if (_selectedButtonIndex == 0) {
      print('Lightning');
    } else if (_selectedButtonIndex == 1) {
      _address = await greenwallet.Channel('ios_wallet').getReceiveAddress(
        mnemonic: mnemonic,
        connectionType: NetworkSecurityCase.bitcoinSS.network,
      );
    } else if (_selectedButtonIndex == 2) {
      _address = await greenwallet.Channel('ios_wallet').getReceiveAddress(
        mnemonic: mnemonic,
        connectionType: NetworkSecurityCase.liquidSS.network,
      );
    }
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
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
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
      child: QrImageView(
        data: address ?? '',
        version: QrVersions.auto,
        size: 300.0,
      ),
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
        address ?? 'No address generated yet',
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
      // allow user to navigate back
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // push these to the bottom of the qr code
                  buildElevatedButton(0, 'Lightning'),
                  buildElevatedButton(1, 'Bitcoin'),
                  buildElevatedButton(2, 'Liquid'),
                    ],
                  ),
              // align these to the in center
              // fix this is not working properly (showing incorrect codes)(has to do with indexes)
              buildQrCode(_address['address']),
              buildAddressText(_address['address']),

            ],
          ),
        ),
      ),
    );
  }
}
