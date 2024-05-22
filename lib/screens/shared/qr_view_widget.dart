import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/transaction_data_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:fluttertoast/fluttertoast.dart';

class QRViewWidget extends StatefulWidget {
  final GlobalKey qrKey;
  final WidgetRef ref;

  const QRViewWidget({Key? key, required this.qrKey, required this.ref}) : super(key: key);

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
    controller.scannedDataStream.listen((scanData) async {
      try {
        await widget.ref.refresh(setAddressAndAmountProvider(scanData.code ?? '').future);
        controller.pauseCamera();
        switch (widget.ref.read(sendTxProvider.notifier).state.type) {
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
              msg: 'Invalid address'.i18n(widget.ref),
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
          msg: e.toString().i18n(widget.ref),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
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
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomButton(
                  text: 'Request camera permission'.i18n(widget.ref),
                  onPressed: () => _requestCameraPermission(),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}