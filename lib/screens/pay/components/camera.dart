import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/transaction_data_provider.dart';
import 'package:Satsails/screens/pay/components/confirm_non_native_asset_payment.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:quickalert/quickalert.dart';

class Camera extends ConsumerStatefulWidget {
  final PaymentType paymentType;

  const Camera({
    super.key,
    required this.paymentType,
  });

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends ConsumerState<Camera> {
  MobileScannerController? _controller;
  // 1. Add a guard flag to prevent multiple pops.
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // 2. Create a safe pop method.
  void _popSafely() {
    if (_isPopping) return;
    _isPopping = true;
    context.pop();
  }

  void _toggleFlash() {
    _controller?.toggleTorch();
  }

  void _showErrorDialog(BuildContext context, String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops!',
      textColor: Colors.white70,
      titleColor: Colors.redAccent,
      backgroundColor: Colors.black87,
      showCancelBtn: false,
      showConfirmBtn: true,
      confirmBtnText: 'OK',
      confirmBtnColor: Colors.redAccent,
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        ref.read(sendTxProvider.notifier).resetToDefault();
        _controller?.start();
      },
      widget: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(
          message.i18n,
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

  Future<void> _onDetect(BarcodeCapture capture, BuildContext context) async {
    // Prevent detection from running if we are already popping.
    if (_isPopping) return;

    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code == null) continue;

      await _controller?.stop();

      if (widget.paymentType == PaymentType.NonNative) {
        ref.read(nonNativeAddressProvider.notifier).state = code;
      } else {
        await ref.refresh(setAddressAndAmountProvider(code).future);
      }

      // 3. Use the safe pop method.
      _popSafely();
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final squareSize = screenSize.width * 0.6;

    // 4. Remove the incorrect onPopInvoked callback.
    return PopScope(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: MobileScanner(
                controller: _controller!,
                onDetect: (capture) => _onDetect(capture, context),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: squareSize,
                height: squareSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Positioned(
              top: 40.0,
              left: 10.0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
                // 5. Use the safe pop method here as well.
                onPressed: () => _popSafely(),
              ),
            ),
            Positioned(
              bottom: 20.0,
              left: 20.0,
              right: 20.0,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  IconButton(
                    icon: const Icon(Icons.flashlight_on_rounded),
                    color: Colors.white,
                    onPressed: () => _toggleFlash(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}