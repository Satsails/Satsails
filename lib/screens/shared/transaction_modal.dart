import 'dart:async';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:vibration/vibration.dart';

// void showFullscreenTransactionSendModal(BuildContext context, double amount, String successMessage) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (BuildContext context) {
//       return Container(
//         color: Colors.black,
//         padding: EdgeInsets.only(
//           top: MediaQuery.of(context).padding.top,
//         ),
//         child: SafeArea(
//           child: Center(
//             child: ReceiveTransactionOverlay(
//               amount: amount.toInt(),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

class ReceiveTransactionOverlay extends ConsumerStatefulWidget {
  final String amount;
  final bool fiat;
  final String? fiatAmount;
  final String? asset;

  const ReceiveTransactionOverlay({
    Key? key,
    required this.amount,
    this.fiat = false,
    this.fiatAmount,
    this.asset,
  }) : super(key: key);

  @override
  _ReceiveTransactionOverlayState createState() => _ReceiveTransactionOverlayState();
}

class _ReceiveTransactionOverlayState extends ConsumerState<ReceiveTransactionOverlay> {
  bool checked = false;

  @override
  void initState() {
    super.initState();

    // Delay the checkbox animation and vibration
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        checked = true;

        // Vibrate when the checkbox is checked
        Vibration.hasVibrator().then((bool? hasVibrator) {
          if (hasVibrator == true) {
            Vibration.vibrate(duration: 100);
          }
        });
      });
    });
  }

  Widget _getAssetImage(String? asset) {
    if (asset == null) return Container(); // Return an empty container if asset is null

    // Define asset images based on the asset type
    switch (asset) {
      case 'Bitcoin':
        return Image.asset(
          'lib/assets/bitcoin-logo.png',
          width: 48,
          height: 48,
        );
      case 'Liquid Bitcoin':
        return Image.asset(
          'lib/assets/l-btc.png',
          width: 48,
          height: 48,
        );
      case 'USDT':
        return Image.asset(
          'lib/assets/tether.png',
          width: 48,
          height: 48,
        );
      case 'EUROX':
        return Image.asset(
          'lib/assets/eurox.png',
          width: 48,
          height: 48,
        );
      case 'DEPIX':
        return Image.asset(
          'lib/assets/depix.png',
          width: 48,
          height: 48,
        );
      case 'Lightning':
        return Image.asset(
          'lib/assets/Bitcoin_lightning_logo.png',
          width: 48,
          height: 48,
        );
      default:
        return Image.asset(
          'lib/assets/app_icon.png',
          width: 48,
          height: 48,
        ); // Default image for unknown assets
    }
  }

  @override
  Widget build(BuildContext context) {
    String amountText;

    if (widget.fiat && widget.fiatAmount != null) {
      amountText = '\$${widget.fiatAmount}';
    } else {
      amountText = widget.amount;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MSHCheckbox(
          size: 100,
          value: checked,
          colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
            checkedColor: Colors.green,
            uncheckedColor: Colors.white,
            disabledColor: Colors.grey,
          ),
          style: MSHCheckboxStyle.stroke,
          duration: const Duration(milliseconds: 500),
          onChanged: (_) {
          },
        ),
        const SizedBox(height: 20),
        _getAssetImage(widget.asset), // Asset-specific image
        const SizedBox(height: 20),
        Text(
          amountText,
          style: const TextStyle(
            fontSize: 48,
            color: Colors.green,
          ),
        ),
        if (widget.asset != null) ...[
          const SizedBox(height: 20),
          Text(
            '${widget.asset}',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}