import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lwk/lwk.dart';

class LiquidWidget extends ConsumerStatefulWidget {
  const LiquidWidget({super.key});

  @override
  _LiquidWidgetState createState() => _LiquidWidgetState();
}

class _LiquidWidgetState extends ConsumerState<LiquidWidget> {
  late TextEditingController controller;
  bool includeAmountInAddress = false;
  String liquidAddressWithAmount = '';

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onCreateAddress() async {
    String inputValue = controller.text;
    ref.read(inputAmountProvider.notifier).state =
    inputValue.isEmpty ? '0.0' : inputValue;
    final liquidAddressWithAmountAsyncValue = ref.watch(liquidReceiveAddressAmountProvider);
    setState(() {
      includeAmountInAddress = true;
      liquidAddressWithAmount = liquidAddressWithAmountAsyncValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final liquidAddress = ref.watch(addressProvider).liquidAddress;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 24.h),
        includeAmountInAddress
            ? _buildAddressWithAmount(liquidAddressWithAmount)
            : _buildDefaultAddress(liquidAddress),
        Padding(
          padding: EdgeInsets.all(16.h),
          child: AmountInput(controller: controller),
        ),
        Padding(
          padding: EdgeInsets.all(16.h),
          child: CustomButton(
            onPressed: _onCreateAddress,
            text: 'Create Address'.i18n,
            primaryColor: Colors.green,
            secondaryColor: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAddress(String liquidAddress) {
        return Center(
          child: Column(
            children: [
              buildQrCode(liquidAddress, context),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.all(16.h),
                child: buildAddressText(liquidAddress, context, ref),
              ),
            ],
          ),
        );
  }

  Widget _buildAddressWithAmount(String liquidAddressWithAmount) {
    return Center(
      child: Column(
        children: [
          buildQrCode(liquidAddressWithAmount, context),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.all(16.h),
            child: buildAddressText(liquidAddressWithAmount, context, ref),
          ),
        ],
      ),
    );
  }
}