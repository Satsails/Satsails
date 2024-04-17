import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:satsails/providers/transaction_data_provider.dart';
import 'package:satsails/screens/shared/qr_view_widget.dart';

class Pay extends ConsumerWidget {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

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

  Pay({super.key});

  Future<void> _pasteFromClipboard(BuildContext context, WidgetRef ref) async {
    final data = await Clipboard.getData('text/plain');
    if (data != null){
      try {
        await ref.refresh(setAddressAndAmountProvider(data.text ?? '').future);
        Navigator.pushNamed(context, '/confirm_bitcoin_payment');
      }
      catch (e) {
        showInvalidAddressSnackBar(context);
      }
    }
  }

  void _toggleFlash() {
    controller.toggleFlash();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          QRViewWidget(
            qrKey: qrKey,
            ref: ref,
          ),
          Positioned(
            top: 40.0,
            left: 10.0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () => _pasteFromClipboard(context, ref),
                      icon: const Icon(Icons.content_paste, color: Colors.white),
                      label: const Text(
                          'Paste', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orangeAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: _toggleFlash,
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                      label: const Text(
                          'Flash', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orangeAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}