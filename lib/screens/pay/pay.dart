import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/transaction_data_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/screens/shared/qr_view_widget.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:quickalert/quickalert.dart';

class Pay extends ConsumerStatefulWidget {
  Pay({Key? key}) : super(key: key);

  @override
  _PayState createState() => _PayState();
}

class _PayState extends ConsumerState<Pay> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  Future<void> _pasteFromClipboard(BuildContext context) async {
    final data = await Clipboard.getData('text/plain');
    if (data != null) {
      try {
        await ref.refresh(setAddressAndAmountProvider(data.text ?? '').future);

        // Read the payment type without causing a rebuild
        final paymentType = ref.read(sendTxProvider.notifier).state.type;

        switch (paymentType) {
          case PaymentType.Bitcoin:
            await controller?.pauseCamera();
            context.push('/home/pay/confirm_bitcoin_payment');
            break;
          case PaymentType.Lightning:
            await controller?.pauseCamera();
            context.push('/home/pay/confirm_custodial_lightning_payment');
            break;
          case PaymentType.Liquid:
            await controller?.pauseCamera();
            context.push('/home/pay/confirm_liquid_payment');
            break;
          default:
            _showErrorDialog(context, 'Scan failed!');
        }
      } catch (e) {
        _showErrorDialog(context, e.toString());
      }
    }
  }


  void _toggleFlash() {
    controller?.toggleFlash();
  }

  void _showErrorDialog(BuildContext context, String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops!', // Updated Title
      textColor: Colors.white70, // Slightly lighter for better contrast
      titleColor: Colors.redAccent, // More attention-grabbing color
      backgroundColor: Colors.black87, // Softer black for aesthetics
      showCancelBtn: false,
      showConfirmBtn: false,
      widget: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          message.i18n(ref),
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Isolate QR Code Scanner View within a separate ProviderScope
          Positioned.fill(
            child: ProviderScope(
              child: QRViewWidget(
                qrKey: qrKey,
                onQRViewCreated: (QRViewController ctrl) {
                  controller = ctrl;
                },
                ref: ref,
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: 40.0,
            left: 10.0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
              onPressed: () => context.pop(),
            ),
          ),
          // Bottom Buttons
          Positioned(
            bottom: 20.0,
            left: 20.0,
            right: 20.0,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: screenSize.width * 0.4,
                  child: ElevatedButton(
                    onPressed: () => _pasteFromClipboard(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'Paste'.i18n(ref),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  width: screenSize.width * 0.4,
                  child: ElevatedButton(
                    onPressed: _toggleFlash,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'Flash'.i18n(ref),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
