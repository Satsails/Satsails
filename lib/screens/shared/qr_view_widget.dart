import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:satsails/providers/transaction_data_provider.dart';


class QRViewWidget extends StatelessWidget {
  final GlobalKey qrKey;
  final WidgetRef ref;

  QRViewWidget({required this.qrKey, required this.ref});

  void onQRViewCreated(QRViewController controller, BuildContext context) {
    controller.scannedDataStream.listen((scanData) async {
      try {
        await ref.refresh(setAddressAndAmountProvider(scanData.toString()).future);
        Navigator.pushNamed(context, '/confirm_bitcoin_payment');
      }
      catch (e) {
        Fluttertoast.showToast(
          msg: 'Error scanning QR code',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
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