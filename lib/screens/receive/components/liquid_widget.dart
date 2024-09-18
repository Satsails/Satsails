import 'package:Satsails/providers/liquid_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lwk_dart/lwk_dart.dart';

class LiquidWidget extends ConsumerStatefulWidget {

  const LiquidWidget({Key? key}) : super(key: key);

  @override
  _LiquidWidgetState createState() => _LiquidWidgetState();
}

class _LiquidWidgetState extends ConsumerState<LiquidWidget> {
  late TextEditingController controller;
  bool includeAmountInAddress = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();

    // Optionally initialize the controller with existing amount
    final inputAmount = ref.read(inputAmountProvider);
    if (inputAmount != '0.0') {
      controller.text = inputAmount;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onCreateAddress() {
    String inputValue = controller.text;
    ref.read(inputAmountProvider.notifier).state =
    inputValue.isEmpty ? '0.0' : inputValue;
    setState(() {
      includeAmountInAddress = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    final liquidAddressAsyncValue = ref.watch(liquidAddressProvider);
    final liquidAddressWithAmountAsyncValue =
    ref.watch(liquidReceiveAddressAmountProvider);

    return Column(
      children: [
        AmountInput(controller: controller),
        SizedBox(height: height * 0.02),
        includeAmountInAddress
            ? _buildAddressWithAmount(liquidAddressWithAmountAsyncValue)
            : _buildDefaultAddress(liquidAddressAsyncValue),
        Padding(
          padding: EdgeInsets.all(height * 0.01),
          child: CustomElevatedButton(
            onPressed: _onCreateAddress,
            text: 'Create Address'.i18n(ref),
            controller: controller,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAddress(AsyncValue<Address> liquidAddressAsyncValue) {
    final height = MediaQuery.of(context).size.height;

    return liquidAddressAsyncValue.when(
      data: (liquidAddress) {
        return Column(
          children: [
            buildQrCode(liquidAddress.confidential, context),
            Padding(
              padding: EdgeInsets.all(height * 0.01),
              child: buildAddressText(liquidAddress.confidential, context, ref),
            ),
          ],
        );
      },
      loading: () => Center(
        child: LoadingAnimationWidget.threeArchedCircle(
          size: MediaQuery.of(context).size.width * 0.6,
          color: Colors.orange,
        ),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error loading address',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildAddressWithAmount(
      AsyncValue<String> liquidAddressWithAmountAsyncValue) {
    final height = MediaQuery.of(context).size.height;

    return liquidAddressWithAmountAsyncValue.when(
      data: (liquidAddressWithAmount) {
        return Column(
          children: [
            buildQrCode(liquidAddressWithAmount, context),
            Padding(
              padding: EdgeInsets.all(height * 0.01),
              child: buildAddressText(liquidAddressWithAmount, context, ref),
            ),
          ],
        );
      },
      loading: () => Center(
        child: LoadingAnimationWidget.threeArchedCircle(
          size: MediaQuery.of(context).size.width * 0.6,
          color: Colors.orange,
        ),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error loading address with amount',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
