import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:Satsails/screens/exchange/exchange.dart'; // For SwapSection enum
import 'package:Satsails/providers/navigation_provider.dart';


class LiquidWidget extends ConsumerStatefulWidget {
  const LiquidWidget({super.key});

  @override
  _LiquidWidgetState createState() => _LiquidWidgetState();
}

class _LiquidWidgetState extends ConsumerState<LiquidWidget> {
  late TextEditingController _controller;
  bool _includeAmountInAddress = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCreateAddress() {
    final inputValue = _controller.text;
    ref.read(inputAmountProvider.notifier).state = inputValue.isEmpty ? '0.0' : inputValue;

    setState(() {
      _includeAmountInAddress = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final liquidAddress = ref.watch(addressProvider).liquidAddress;
    final liquidAddressWithAmount = ref.watch(liquidReceiveAddressAmountProvider);

    final addressToShow = _includeAmountInAddress ? liquidAddressWithAmount : liquidAddress;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 24.h),
        Center(
          child: Column(
            children: [
              buildQrCode(addressToShow, context),
              _buildReceiveFromDifferentNetworkButton(context, ref),
              SizedBox(height: 5.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: buildAddressText(addressToShow, context, ref),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.all(16.h),
          child: AmountInput(controller: _controller),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: CustomButton(
            onPressed: _onCreateAddress,
            text: 'Create Address'.i18n,
            primaryColor: Colors.green.withOpacity(0.8),
            secondaryColor: Colors.green.withOpacity(0.6),
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Builds a subtle button to navigate to the Exchange screen for receiving from another network.
  Widget _buildReceiveFromDifferentNetworkButton(BuildContext context, WidgetRef ref) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: TextButton(
        onPressed: () {
          context.pop();
          ref.read(navigationProvider.notifier).state = 2;
          ref.read(swapSectionProvider.notifier).state = SwapSection.external;
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey.shade400,
        ),
        child: Text(
          'Receive from a different network'.i18n,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14.sp,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white70,
          ),
        ),
      ),
    );
  }
}