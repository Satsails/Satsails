import 'package:Satsails/providers/coinos.provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/transaction_data_provider.dart';
import 'package:Satsails/screens/shared/qr_view_widget.dart';

class Pay extends ConsumerWidget {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;

  Pay({Key? key}) : super(key: key);

  Future<void> _pasteFromClipboard(BuildContext context, WidgetRef ref) async {
    final data = await Clipboard.getData('text/plain');
    if (data != null) {
      try {
        await ref.refresh(setAddressAndAmountProvider(data.text ?? '').future);
        switch (ref.read(sendTxProvider.notifier).state.type) {
          case PaymentType.Bitcoin:
            context.push('/home/pay/confirm_bitcoin_payment');
            break;
          case PaymentType.Lightning:
            final hasCustodialLn = ref.read(coinosLnProvider).token.isNotEmpty;
            hasCustodialLn ? context.push('/home/pay/confirm_custodial_lightning_payment') : context.push('/home/pay/confirm_lightning_payment');
            break;
          case PaymentType.Liquid:
            context.push('/home/pay/confirm_liquid_payment');
            break;
          default:
            _showErrorDialog(context, ref, 'Scan failed!');
        }
      } catch (e) {
        _showErrorDialog(context, ref, e.toString());
      }
    }
  }

  void _toggleFlash() {
    controller.toggleFlash();
  }

  void _showErrorDialog(BuildContext context, WidgetRef ref, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.red.withOpacity(0.8),
                child: const Icon(Icons.close, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16.0),
              Text(
                message.i18n(ref),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black54),
              onPressed: () {
                context.pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // QR Code Scanner View
          Positioned.fill(
            child: QRViewWidget(
              qrKey: qrKey,
              onQRViewCreated: (QRViewController ctrl) {
                controller = ctrl;
              },
              ref: ref,
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
                    onPressed: () => _pasteFromClipboard(context, ref),
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
