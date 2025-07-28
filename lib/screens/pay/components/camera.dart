import 'package:Satsails/models/address_model.dart';
import 'package:Satsails/providers/breez_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/screens/pay/components/confirm_non_native_asset_payment.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:quickalert/quickalert.dart';
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:lwk/lwk.dart' as lwk;
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart' as breez;

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

  void _popSafely() {
    if (_isPopping) return;
    _isPopping = true;
    if (context.mounted) {
      context.pop();
    }
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

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isPopping) return;

    final barcode = capture.barcodes.firstOrNull;
    final code = barcode?.rawValue;
    if (code == null) return;

    await _controller?.stop();

    try {
      if (widget.paymentType == PaymentType.NonNative) {
        ref.read(nonNativeAddressProvider.notifier).state = code;
        _popSafely();
        return;
      }

      // Try to parse as Lightning invoice
      try {
        final parsedInput = await ref.read(parseInputProvider(code).future);
        if (parsedInput is breez.InputType_Bolt11) {
          final amountSat = parsedInput.invoice.amountMsat != null
              ? (parsedInput.invoice.amountMsat! ~/ BigInt.from(1000)).toInt()
              : 0;

          final notifier = ref.read(sendTxProvider.notifier);
          notifier.updateAddress(parsedInput.invoice.bolt11);
          notifier.updateAmount(amountSat);
          notifier.updatePaymentType(PaymentType.Lightning);

          _popSafely();
          return;
        }
      } catch (e) {
        // Not a lightning invoice, proceed.
      }

      // Handle On-chain (Bitcoin/Liquid) URIs
      String data = code;
      if (data.toLowerCase().startsWith('bitcoin:')) {
        data = data.substring(8);
      } else if (data.toLowerCase().startsWith('liquidnetwork:')) {
        data = data.substring(14);
      }

      var parts = data.split('?');
      final addressPart = parts[0];
      int amount = 0;

      if (parts.length > 1) {
        var params = parts[1].split('&');
        for (var param in params) {
          var keyValue = param.split('=');
          if (keyValue[0] == 'amount' && keyValue.length > 1) {
            amount = (double.parse(keyValue[1]) * 1e8).toInt();
          }
        }
      }

      final notifier = ref.read(sendTxProvider.notifier);

      // Try to validate as Bitcoin
      try {
        await bdk.Address.fromString(s: addressPart, network: bdk.Network.bitcoin);
        notifier.updateAddress(addressPart);
        notifier.updateAmount(amount);
        notifier.updatePaymentType(PaymentType.Bitcoin);
        _popSafely();
        return;
      } catch (_) {
        // Not a Bitcoin address.
      }

      // Try to validate as Liquid
      try {
        await lwk.Address.validate(addressString: addressPart);
        notifier.updateAddress(addressPart);
        notifier.updateAmount(amount);
        notifier.updatePaymentType(PaymentType.Liquid);
        _popSafely();
        return;
      } catch (_) {
        // Not a Liquid address.
      }

      // If no format matches, pass the raw code as 'Unknown'
      notifier.updateAddress(code);
      notifier.updateAmount(0); // No amount can be assumed
      notifier.updatePaymentType(PaymentType.Unknown);
      _popSafely();

    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final squareSize = screenSize.width * 0.6;

    return PopScope(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: MobileScanner(
                controller: _controller!,
                onDetect: _onDetect,
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
                onPressed: _popSafely,
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
                    onPressed: _toggleFlash,
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