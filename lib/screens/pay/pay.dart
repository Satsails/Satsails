import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:satsails/helpers/validate_address.dart';
import 'package:satsails/providers/send_payments_provider.dart';

class Pay extends ConsumerWidget {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  Pay({super.key});

  void showInvalidAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Address'),
          content: const Text('The address you scanned is not valid.'),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: const Text('OK'),
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

  // void _onQRViewCreated(QRViewController controller, BuildContext context) {
  //   controller.scannedDataStream.listen((scanData) {
  //     switch (addressType(scanData as String)) {
  //       case PaymentTYpe.Bitcoin || PaymentTYpe.Liquid || PaymentTYpe.Lightning:
  //         Navigator.pushNamed(context, '/confirm_payment');
  //         break;
  //       default:
  //         showInvalidAddressDialog(context);
  //         break;
  //     }
  //   });
  // }

  void _toggleFlash() {
    controller.toggleFlash();
  }

//   Future<void> _pasteFromClipboard(BuildContext context) async {
//     final data = await Clipboard.getData('text/plain');
//     if (data != null) {
//       switch (addressType(data as String)) {
//         case PaymentTYpe.Bitcoin || PaymentTYpe.Liquid || PaymentTYpe.Lightning:
//           Navigator.pushNamed(context, '/confirm_payment');
//           break;
//         default:
//           showInvalidAddressDialog(context);
//           break;
//       }
//   }
// }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Pay'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Scan any QR code to pay', style: TextStyle(fontSize: 20)),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            // Expanded(
            //   child: QRView(
            //     key: qrKey,
            //     onQRViewCreated: (controller) => _onQRViewCreated(controller, context),
            //   ),
            // ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Align(
              alignment: Alignment.center,
              heightFactor: 1.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ElevatedButton(
                  //   onPressed: () => _pasteFromClipboard(context),
                  //   child: const Text('Paste from clipboard'),
                  // ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _toggleFlash,
                    child: const Text('Toggle Flash'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}