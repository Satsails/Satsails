import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/transaction_data_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // <-- mobile_scanner
import 'package:quickalert/quickalert.dart';

class Pay extends ConsumerStatefulWidget {
  const Pay({Key? key}) : super(key: key);

  @override
  _PayState createState() => _PayState();
}

class _PayState extends ConsumerState<Pay> {
  /// We replace `QRViewController` with `MobileScannerController`.
  MobileScannerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
    // Optionally you could set initialTorchState or facing here:
    // _controller = MobileScannerController(
    //   torchEnabled: false,
    //   facing: CameraFacing.back,
    // );
  }

  @override
  void dispose() {
    // Dispose the controller to clean up the camera resource
    _controller?.dispose();
    super.dispose();
  }

  /// Paste data from clipboard
  Future<void> _pasteFromClipboard(BuildContext context) async {
    final data = await Clipboard.getData('text/plain');
    if (data != null) {
      try {
        await ref.refresh(setAddressAndAmountProvider(data.text ?? '').future);

        final paymentType = ref.read(sendTxProvider).type;

        // Stop scanning (similar to pauseCamera())
        await _controller?.stop();

        switch (paymentType) {
          case PaymentType.Bitcoin:
            context.push('/home/pay/confirm_bitcoin_payment');
            break;
          case PaymentType.Lightning:
            context.push('/home/pay/confirm_custodial_lightning_payment');
            break;
          case PaymentType.Liquid:
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

  /// Toggle torch (replaces toggleFlash)
  void _toggleFlash() {
    _controller?.toggleTorch();
  }

  /// Show an error dialog using quickalert
  void _showErrorDialog(BuildContext context, String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops!',
      textColor: Colors.white70,
      titleColor: Colors.redAccent,
      backgroundColor: Colors.black87,
      showCancelBtn: false,
      showConfirmBtn: false,
      widget: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          message.i18n(ref),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Called when a QR code or barcode is detected
  Future<void> _onDetect(BarcodeCapture capture, BuildContext context) async {
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code == null) continue; // skip if empty

      // Stop scanning so we don't read multiple times
      await _controller?.stop();

      try {
        await ref.refresh(setAddressAndAmountProvider(code).future);

        final paymentType = ref.read(sendTxProvider).type;
        switch (paymentType) {
          case PaymentType.Bitcoin:
            context.push('/home/pay/confirm_bitcoin_payment');
            break;
          case PaymentType.Lightning:
            context.push('/home/pay/confirm_custodial_lightning_payment');
            break;
          case PaymentType.Liquid:
            context.push('/home/pay/confirm_liquid_payment');
            break;
          default:
            _showErrorDialog(context, 'Scan failed!');
        }
      } catch (e) {
        _showErrorDialog(context, e.toString());
        // Optionally resume scanning if the parse fails
        _controller?.start();
      }

      // Break after handling the first recognized code
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 1. MobileScanner view
          Positioned.fill(
            child: MobileScanner(
              controller: _controller!,
              onDetect: (capture) => _onDetect(capture, context),
            ),
          ),

          /// 2. Back Button
          Positioned(
            top: 40.0,
            left: 10.0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
              onPressed: () => context.pop(),
            ),
          ),

          /// 3. Bottom Buttons
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
