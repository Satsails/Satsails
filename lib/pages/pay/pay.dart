import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../helpers/networks.dart';
import '../../../channels/greenwallet.dart' as greenwallet;
import 'package:btc_address_validate_swan/btc_address_validate_swan.dart';

class Pay extends StatefulWidget {
  @override
  _PayState createState() => _PayState();
}

class _PayState extends State<Pay> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isLiquid = false;
  late QRViewController controller;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> checkIfAddressIsValid(String address) async {
    const storage = FlutterSecureStorage();
    String mnemonic = await storage.read(key: 'mnemonic') ?? "";
    bool liquidValid =
        await greenwallet.Channel('ios_wallet').checkAddressValidity(
      mnemonic: mnemonic,
      address: address,
      connectionType: NetworkSecurityCase.liquidSS.network,
    );
    if (liquidValid) {
      isLiquid = true;
      return true;
    } else {
      try {
        validate(address);
        return true;
      } catch (e) {
        return false;
      }
    }
  }

  void showInvalidAddressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invalid Address'),
          content: Text('The address you scanned is not valid.'),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      if (await checkIfAddressIsValid(scanData as String)) {
        Navigator.pushNamed(
          context,
          '/confirm_payment',
          arguments: {
            'address': scanData,
            'isLiquid': isLiquid,
          },
        );
      } else {
        showInvalidAddressDialog();
      }
    });
  }

  void _toggleFlash() {
    controller?.toggleFlash();
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null) {
      if (await checkIfAddressIsValid(data.text as String)) {
        Navigator.pushNamed(
          context,
          '/confirm_payment',
          arguments: {
            'address': data.text,
            'isLiquid': isLiquid,
            // Assuming isLiquid is a boolean variable in your class
          },
        );
      } else {
        showInvalidAddressDialog();
      }
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Pay'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Scan any QR code to pay', style: TextStyle(fontSize: 20)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Expanded(
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Align(
              alignment: Alignment.center,
              heightFactor: 1.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _pasteFromClipboard,
                    child: Text('Paste from clipboard'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _toggleFlash,
                    child: Text('Toggle Flash'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
