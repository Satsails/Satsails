import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/transaction_data_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:quickalert/quickalert.dart';

/// Same name as before, but internally uses MobileScanner
class QRViewWidget extends ConsumerStatefulWidget {
  /// We don’t use [qrKey] here anymore, but you can keep it if desired
  final GlobalKey? qrKey;
  final WidgetRef ref;

  const QRViewWidget({
    super.key,
    this.qrKey,
    required this.ref,
  });

  @override
  _QRViewWidgetState createState() => _QRViewWidgetState();
}

class _QRViewWidgetState extends ConsumerState<QRViewWidget> {
  PermissionStatus _status = PermissionStatus.denied;

  /// The new scanner controller
  late final MobileScannerController _controller;
  bool _isProcessing = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
    _checkCameraPermission();
  }

  @override
  void dispose() {
    // Dispose the controller if desired
    _controller.dispose();
    super.dispose();
  }

  /// Step A: Check existing camera permission
  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    setState(() {
      _status = status;
    });
    if (!status.isGranted) {
      await _requestCameraPermission();
    }
  }

  /// Step B: Request camera permission if not granted
  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      setState(() {
        _status = status;
      });
    }
  }

  /// Processing the scanned data
  Future<void> _processScanData(String? code, BuildContext context, WidgetRef ref) async {
    if (code == null || _isProcessing || _hasNavigated) return;

    _isProcessing = true;

    // Pause scanning to prevent multiple detections
    _controller.stop();

    try {
      // Attempt to parse the QR data
      await ref.refresh(setAddressAndAmountProvider(code).future);
      final paymentType = ref.read(sendTxProvider).type;

      _navigateToPaymentScreen(paymentType, context, ref);
    } catch (e) {
      await _showErrorDialog(context, e.toString(), ref);
      // Resume scanning if desired
      _controller.start();
    } finally {
      _isProcessing = false;
    }
  }

  /// Navigates based on payment type
  Future<void> _navigateToPaymentScreen(
      PaymentType paymentType,
      BuildContext context,
      WidgetRef ref,
      ) async {
    _hasNavigated = true;
    _controller.stop();

    switch (paymentType) {
      case PaymentType.Bitcoin:
        context.pushReplacement('/home/pay/confirm_bitcoin_payment');
        break;
      case PaymentType.Lightning:
        context.pushReplacement('/home/pay/confirm_custodial_lightning_payment');
        break;
      case PaymentType.Liquid:
        context.pushReplacement('/home/pay/confirm_liquid_payment');
        break;
      default:
        await _showScanFailedDialog(context, ref);
        _controller.start();
        break;
    }
  }

  /// Shows a “Scan failed” dialog
  Future<void> _showScanFailedDialog(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
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
                'Scan failed!'.i18n(ref),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Something went wrong, please try again.'.i18n(ref),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
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
                // Optionally resume the camera
                _controller.start();
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows an error dialog for other exceptions
  Future<void> _showErrorDialog(BuildContext context, String message, WidgetRef ref) async {
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

  @override
  Widget build(BuildContext context) {
    // If camera permission is granted, show the scanner
    if (_status.isGranted) {
      return MobileScanner(
        // Controller handles the camera, flash, etc.
        controller: _controller,
        // onDetect is called whenever a barcode is recognized
        onDetect: (barcodeCapture) {
          // barcodeCapture.barcodes is a list of Barcodes
          for (final barcode in barcodeCapture.barcodes) {
            final String? code = barcode.rawValue;
            if (code != null && !_isProcessing && !_hasNavigated) {
              _processScanData(code, context, widget.ref);
              break; // Optionally stop after the first recognized code
            }
          }
        },
      );
    } else {
      // If camera permission is NOT granted, show permission request screen
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                'lib/assets/frame.svg',
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.5,
                color: Colors.orange,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.1,
                  vertical: MediaQuery.of(context).size.width * 0.05,
                ),
                child: CustomButton(
                  text: 'Request camera permission'.i18n(widget.ref),
                  onPressed: _requestCameraPermission,
                  primaryColor: Colors.orange,
                  secondaryColor: Colors.orange,
                  textColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
