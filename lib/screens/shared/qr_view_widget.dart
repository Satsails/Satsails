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
  QRViewController? _controller; // Reference to the controller
  bool _isProcessing = false; // Flag to prevent multiple scans
  bool _hasNavigated = false; // Flag to prevent multiple navigations

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
    _controller?.dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      PermissionStatus newStatus = await Permission.camera.request();
      if (newStatus.isPermanentlyDenied) {
        openAppSettings();
      } else if (newStatus.isDenied) {
        setState(() {
          _status = PermissionStatus.denied;
        });
      } else if (newStatus.isGranted) {
        setState(() {
          _status = PermissionStatus.granted;
        });
      }
    } else {
      setState(() {
        _status = PermissionStatus.granted;
      });
    }
  }

  void _handleQRViewCreated(QRViewController controller, BuildContext context, WidgetRef ref) {
    _controller = controller; // Store the controller reference
    widget.onQRViewCreated?.call(controller);

    controller.scannedDataStream.listen((scanData) async {
      if (_isProcessing || _hasNavigated) {
        // Prevent processing if already handling a scan or navigating
        return;
      }
      _isProcessing = true; // Set the processing flag

      await controller.pauseCamera(); // Await pausing the camera
      debugPrint('Camera paused');

      try {
        // Refresh and set address and amount
        await widget.ref.refresh(setAddressAndAmountProvider(scanData.code ?? '').future);
        debugPrint('Data refreshed with scan data: ${scanData.code}');

        // Determine payment type and navigate accordingly
        final paymentType = widget.ref.read(sendTxProvider.notifier).state.type;
        switch (paymentType) {
          case PaymentType.Bitcoin:
            await controller.stopCamera(); // Await stopping the camera
            debugPrint('Camera stopped for Bitcoin payment');
            _hasNavigated = true; // Set navigation flag
            await Future.delayed(Duration(milliseconds: 300)); // Slight delay to ensure camera stops
            context.pushReplacement('/home/pay/confirm_bitcoin_payment'); // Replace current route
            break;
          case PaymentType.Lightning:
            await controller.stopCamera(); // Await stopping the camera
            debugPrint('Camera stopped for Lightning payment');
            final hasCustodialLn = ref.read(coinosLnProvider).token.isNotEmpty;
            _hasNavigated = true; // Set navigation flag
            await Future.delayed(Duration(milliseconds: 300)); // Slight delay
            hasCustodialLn
                ? context.pushReplacement('/home/pay/confirm_custodial_lightning_payment')
                : context.pushReplacement('/home/pay/confirm_lightning_payment');
            break;
          case PaymentType.Liquid:
            await controller.stopCamera(); // Await stopping the camera
            debugPrint('Camera stopped for Liquid payment');
            _hasNavigated = true; // Set navigation flag
            await Future.delayed(Duration(milliseconds: 300)); // Slight delay
            context.pushReplacement('/home/pay/confirm_liquid_payment'); // Replace current route
            break;
          default:
            await _showScanFailedDialog(context, ref);
            break;
        }
      } catch (e) {
        debugPrint('Error during scan processing: $e');
        await _showErrorDialog(context, e.toString(), controller);
      } finally {
        _isProcessing = false; // Reset the processing flag
      }
    });
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
                _controller?.resumeCamera(); // Resume camera after dialog is dismissed
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
                controller.resumeCamera(); // Resume camera after error
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
