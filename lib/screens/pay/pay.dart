import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:btc_address_validate_swan/btc_address_validate_swan.dart';

class Pay extends ConsumerWidget {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;


  Future<bool> checkIfAddressIsValid(String address) async {
    // bool liquidValid =
    //     await greenwallet.Channel('ios_wallet').checkAddressValidity(
    //   mnemonic: mnemonic,
    //   address: address,
    //   connectionType: NetworkSecurityCase.liquidSS.network,
    // );
    bool liquidValid = false;
    if (liquidValid) {
    } else {
      try {
        validate(address);
        return true;
      } catch (e) {
        return false;
      }
    }
  }

  void showInvalidAddressDialog(BuildContext context) {
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

  void _onQRViewCreated(QRViewController controller, BuildContext context) {
    controller.scannedDataStream.listen((scanData) async {
      if (await checkIfAddressIsValid(scanData as String)) {
        Navigator.pushNamed(
          context,
          '/confirm_payment',
          arguments: {
            'address': scanData,
            'isLiquid': true,
          },
        );
      } else {
        showInvalidAddressDialog(context);
      }
    });
  }

  void _toggleFlash() {
    controller.toggleFlash();
  }

  void _pasteFromClipboard(BuildContext context) async {
    final data = await Clipboard.getData('text/plain');
    if (data != null) {
      if (await checkIfAddressIsValid(data.text as String)) {
        Navigator.pushNamed(
          context,
          '/confirm_payment',
          arguments: {
            'address': data.text,
            'isLiquid': true,
            // Assuming isLiquid is a boolean variable in your class
          },
        );
      } else {
        showInvalidAddressDialog(context);
      }
    }
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                onQRViewCreated: (controller) => _onQRViewCreated(controller, context),
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
                    onPressed: () => _pasteFromClipboard(context),
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