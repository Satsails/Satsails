import 'dart:async';
import 'package:Satsails/helpers/swap_helpers.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transaction_search_provider.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:vibration/vibration.dart';

void showFullscreenTransactionSendModal({
  required BuildContext context,
  required String amount,
  String? asset,
  bool fiat = false,
  String? fiatAmount,
  String? txid,
  bool isLiquid = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        color: Colors.black,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
        ),
        child: SafeArea(
          child: Center(
            child: PaymentTransactionOverlay(
              amount: amount,
              fiat: fiat,
              fiatAmount: fiatAmount,
              asset: asset,
              txid: txid,
              isLiquid: isLiquid,
            ),
          ),
        ),
      );
    },
  );
}

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

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        checked = true;

        Vibration.hasVibrator().then((bool? hasVibrator) {
          if (hasVibrator == true) {
            Vibration.vibrate(duration: 100);
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String amountText = widget.fiat && widget.fiatAmount != null
        ? '\$${widget.fiatAmount}'
        : widget.amount;

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
          onChanged: (_) {},
        ),
        const SizedBox(height: 20),
        getAssetImage(widget.asset, height: 48.sp, width: 48.sp),
        const SizedBox(height: 20),
        Text(
          amountText,
          style: const TextStyle(fontSize: 48, color: Colors.green),
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


class PaymentTransactionOverlay extends ConsumerStatefulWidget {
  final String amount;
  final bool fiat;
  final String? fiatAmount;
  final String? asset;
  final String? txid;
  final bool isLiquid;

  const PaymentTransactionOverlay({
    Key? key,
    required this.amount,
    this.fiat = false,
    this.fiatAmount,
    this.asset,
    this.txid,
    this.isLiquid = false,
  }) : super(key: key);

  @override
  _PaymentTransactionOverlayState createState() =>
      _PaymentTransactionOverlayState();
}

class _PaymentTransactionOverlayState
    extends ConsumerState<PaymentTransactionOverlay> with TickerProviderStateMixin {
  bool checked = false;
  late AnimationController animationController;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    scaleAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutBack,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      animationController.forward();
      setState(() {
        checked = true;

        Vibration.hasVibrator().then((bool? hasVibrator) {
          if (hasVibrator == true) {
            Vibration.vibrate(duration: 100);
          }
        });
      });
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final btcFormat = ref.read(settingsProvider).btcFormat;
    String amountText;

    if (widget.fiat && widget.fiatAmount != null) {
      // Include the asset name when fiat is true
      amountText = '${widget.fiatAmount} ${widget.asset ?? ''}'.trim();
    } else {
      switch (btcFormat) {
        case 'sats':
          amountText = '${widget.amount} sats';
          break;
        case 'BTC':
          amountText = '${widget.amount} BTC';
          break;
        default:
          amountText = widget.amount;
      }
    }

    return Column(
      children: [
        Spacer(),
        ScaleTransition(
          scale: scaleAnimation,
          child: MSHCheckbox(
            size: 100,
            value: checked,
            colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
              checkedColor: Colors.green,
              uncheckedColor: Colors.white,
              disabledColor: Colors.grey,
            ),
            style: MSHCheckboxStyle.stroke,
            duration: const Duration(milliseconds: 500),
            onChanged: (_) {},
          ),
        ),
        const SizedBox(height: 30),
        getAssetImage(widget.asset, height: 48.sp, width: 48.sp),
        const SizedBox(height: 20),
        Text(
          amountText,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        if (widget.asset != null) ...[
          const SizedBox(height: 10),
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
        Spacer(),
        if (widget.txid != null && widget.txid!.isNotEmpty)
          CustomElevatedButton(
            onPressed: () {
              ref.read(transactionSearchProvider).isLiquid = widget.isLiquid;
              ref.read(transactionSearchProvider).txid = widget.txid!;
              context.push('/search_modal');
            },
            text: 'View Details'.i18n(ref),
            backgroundColor: Colors.green,
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Transaction details not available'.i18n(ref),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.redAccent,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
