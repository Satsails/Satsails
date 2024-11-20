import 'package:Satsails/providers/coinos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/transaction_data_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/translations.dart';

class QRViewWidget extends StatefulWidget {
  final GlobalKey qrKey;
  final WidgetRef ref;
  final Function(QRViewController)? onQRViewCreated;

  const QRViewWidget({
    super.key,
    required this.qrKey,
    required this.ref,
    this.onQRViewCreated,
  });

  @override
  _QRViewWidgetState createState() => _QRViewWidgetState();
}

class _QRViewWidgetState extends State<QRViewWidget> {
  PermissionStatus _status = PermissionStatus.denied;
  QRViewController? _controller;
  bool _isProcessing = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    setState(() {
      _status = status;
    });
    if (!status.isGranted) {
      await _requestCameraPermission();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

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

  void _handleQRViewCreated(QRViewController controller, BuildContext context, WidgetRef ref) {
    _controller = controller;
    widget.onQRViewCreated?.call(controller);

    controller.scannedDataStream.listen((scanData) {
      if (!_isProcessing && !_hasNavigated) {
        _processScanData(scanData.code, context, ref);
      }
    });
  }

  Future<void> _processScanData(String? code, BuildContext context, WidgetRef ref) async {
    if (code == null || _isProcessing || _hasNavigated) return;

    _isProcessing = true;
    await _controller?.pauseCamera();
    debugPrint('Camera paused');

    try {
      await widget.ref.refresh(setAddressAndAmountProvider(code).future);
      debugPrint('Data refreshed with scan data: $code');

      final paymentType = widget.ref.read(sendTxProvider).type;
      _navigateToPaymentScreen(paymentType, context, ref);
    } catch (e) {
      await _showErrorDialog(context, e.toString(), _controller!);
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _navigateToPaymentScreen(PaymentType paymentType, BuildContext context, WidgetRef ref) async {
    _hasNavigated = true;

    switch (paymentType) {
      case PaymentType.Bitcoin:
        _controller = null;
        context.pushReplacement('/home/pay/confirm_bitcoin_payment');
        break;

      case PaymentType.Lightning:
        _controller = null;
        context.pushReplacement('/home/pay/confirm_custodial_lightning_payment');
        break;

      case PaymentType.Liquid:
        _controller = null;
          context.pushReplacement('/home/pay/confirm_liquid_payment');
        break;

      default:
        await _showScanFailedDialog(context, ref);
        break;
    }
  }

  Future<void> _showScanFailedDialog(BuildContext context, WidgetRef ref) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 20.0, horizontal: 24.0),
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
                'Scan failed!'.i18n(widget.ref),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Something went wrong, please try again.'.i18n(widget.ref),
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
                _controller?.resumeCamera();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorDialog(BuildContext context, String errorMessage, QRViewController controller) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 20.0, horizontal: 24.0),
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
                errorMessage.i18n(widget.ref),
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
                controller.resumeCamera();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_status.isGranted) {
      return QRView(
        key: widget.qrKey,
        onQRViewCreated: (controller) => _handleQRViewCreated(controller, context, widget.ref),
        overlay: QrScannerOverlayShape(
          borderColor: Colors.orange,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.6,
        ),
      );
    } else {
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
                  onPressed: () => _requestCameraPermission(),
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
