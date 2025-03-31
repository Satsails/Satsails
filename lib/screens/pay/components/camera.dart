import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/transaction_data_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:quickalert/quickalert.dart';

class Camera extends ConsumerStatefulWidget {
  const Camera({super.key});

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends ConsumerState<Camera> {
  MobileScannerController? _controller;

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
      showConfirmBtn: false,
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
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code == null) continue;

      await _controller?.stop();

      try {
        await ref.refresh(setAddressAndAmountProvider(code).future);
        final paymentType = ref.read(sendTxProvider).type;
        final assetId = ref.read(sendTxProvider).assetId;
        if (paymentType == PaymentType.Bitcoin) {
          context.pushReplacementNamed('pay_bitcoin');
        } else {
          _showErrorDialog(context, 'Invalid payment type for Bitcoin transaction');
          _controller?.start();
        }
        if (paymentType == PaymentType.Liquid) {
          if (assetId == AssetMapper.reverseMapTicker(AssetId.LBTC)) {
            context.pushReplacementNamed('pay_liquid');
          } else {
            _showErrorDialog(context, 'Invalid payment type for Liquid transaction');
            _controller?.start();
          }
          if (assetId == AssetMapper.reverseMapTicker(AssetId.BRL)) {
            context.pushReplacementNamed('pay_liquid_depix');
          } else {
            _showErrorDialog(context, 'Invalid payment type for liquid Depix transaction');
            _controller?.start();
          }
          if (assetId == AssetMapper.reverseMapTicker(AssetId.USD)) {
            context.pushReplacementNamed('pay_liquid_usdt');
          } else {
            _showErrorDialog(context, 'Invalid payment type for liquid Usdt transaction');
            _controller?.start();
          }
          if (assetId == AssetMapper.reverseMapTicker(AssetId.EUR)) {
            context.pushReplacementNamed('pay_liquid_eur');
          } else {
            _showErrorDialog(context, 'Invalid payment type for liquid EURx transaction');
            _controller?.start();
          }
        } else {
          _showErrorDialog(context, 'Invalid payment type for Liquid transaction');
          _controller?.start();
        }
        if (paymentType == PaymentType.Lightning) {
          context.pushReplacementNamed('pay_lightning');
        } else {
          _showErrorDialog(context, 'Invalid payment type for lightning transaction');
          _controller?.start();
        }
        if (paymentType == PaymentType.Lightning) {
          context.pushReplacementNamed('pay_lightning');
        } else {
          _showErrorDialog(context, 'Invalid payment type for Ethereum transaction');
          _controller?.start();
        }
      } catch (e) {
        _showErrorDialog(context, e.toString());
        _controller?.start();
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final squareSize = screenSize.width * 0.6; // 60% of screen width

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera view filling the entire screen
          Positioned.fill(
            child: MobileScanner(
              controller: _controller!,
              onDetect: (capture) => _onDetect(capture, context),
            ),
          ),
          // Centered square guide for scanning
          Align(
            alignment: Alignment.center,
            child: Container(
              width: squareSize,
              height: squareSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(10), // Optional: rounded corners
              ),
            ),
          ),
          // Back button at top-left
          Positioned(
            top: 40.0,
            left: 10.0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30.0),
              onPressed: () => context.pop(),
            ),
          ),
          // Flash toggle button at bottom
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
    );
  }
}