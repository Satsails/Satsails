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
              _buildReceiveFromDifferentNetworkButton(context, ref),
              SizedBox(height: 16.h),
              buildQrCode(addressToShow, context),
              SizedBox(height: 16.h),
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
            text: 'Create Address with Amount'.i18n,
            primaryColor: Colors.green,
            secondaryColor: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiveFromDifferentNetworkButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () {
        context.pop();
        ref.read(navigationProvider.notifier).state = 2;
        ref.read(swapSectionProvider.notifier).state = SwapSection.external;
      },
      icon: Icon(Icons.swap_horiz, size: 20.sp),
      label: Text('Receive from a different network'.i18n),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        foregroundColor: Colors.white70, // Text and icon color
        side: BorderSide(color: Colors.white.withOpacity(0.3)), // Border color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        textStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}