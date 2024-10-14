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

  @override
  void initState() {
    super.initState();
    Permission.camera.status.then((status) {
      setState(() {
        _status = status;
      });
    });
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

  void onQRViewCreated(QRViewController controller, BuildContext context) {
    widget.onQRViewCreated?.call(controller);
    controller.scannedDataStream.listen((scanData) async {
      try {
        await widget.ref.refresh(setAddressAndAmountProvider(scanData.code ?? '').future);
        controller.pauseCamera();
        switch (widget.ref.read(sendTxProvider.notifier).state.type) {
          case PaymentType.Bitcoin:
            context.push('home/pay/confirm_bitcoin_payment');
            break;
          case PaymentType.Lightning:
            context.push('home/pay/confirm_lightning_payment');
            break;
          case PaymentType.Liquid:
            context.push('home/pay/confirm_liquid_payment');
            break;
          default:
            showDialog(
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
                        child: const Icon(
                            Icons.close, size: 40, color: Colors.white),
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
                      },
                    ),
                  ],
                );
              },
            );
        }
      }
      catch (e) {
        controller.pauseCamera();
        showDialog(
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
                      child: const Icon(
                          Icons.close, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      e.toString().i18n(widget.ref),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_status.isGranted) {
      return QRView(
        key: widget.qrKey,
        onQRViewCreated: (controller) => onQRViewCreated(controller, context),
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
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: MediaQuery.of(context).size.width * 0.05),
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