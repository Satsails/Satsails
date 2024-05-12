import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/transaction_data_provider.dart';
import 'package:Satsails/screens/shared/qr_view_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Pay extends ConsumerWidget {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  Pay({super.key});

  Future<void> _pasteFromClipboard(BuildContext context, WidgetRef ref) async {
    final data = await Clipboard.getData('text/plain');
    if (data != null){
      try {
        await ref.refresh(setAddressAndAmountProvider(data.text ?? '').future);
        switch (ref.read(sendTxProvider.notifier).state.type) {
          case PaymentType.Bitcoin:
            Navigator.pushReplacementNamed(context, '/confirm_bitcoin_payment');
            break;
          case PaymentType.Lightning:
            Navigator.pushReplacementNamed(context, '/confirm_lightning_payment');
            break;
          case PaymentType.Liquid:
            Navigator.pushReplacementNamed(context, '/confirm_liquid_payment');
            break;
          default:
            Fluttertoast.showToast(
              msg: 'Invalid address',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
        }
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