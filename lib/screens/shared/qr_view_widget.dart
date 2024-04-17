import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:satsails/providers/transaction_data_provider.dart';

class QRViewWidget extends StatelessWidget {
  final GlobalKey qrKey;
  final WidgetRef ref;

  QRViewWidget({required this.qrKey, required this.ref});

  void showInvalidAddressSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: const Text('The address you scanned is not valid.'),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          // Do something, if needed
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void onQRViewCreated(QRViewController controller, BuildContext context) {
    controller.scannedDataStream.listen((scanData) async {
      try {
        await ref.refresh(setAddressAndAmountProvider(scanData.toString()).future);
        Navigator.pushNamed(context, '/confirm_bitcoin_payment');
      }
      catch (e) {
        showInvalidAddressSnackBar(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: (controller) => onQRViewCreated(controller, context),
    );
  }
}