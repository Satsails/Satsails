import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class BitcoinWidget extends ConsumerStatefulWidget {

  const BitcoinWidget({super.key});

  @override
  _BitcoinWidgetState createState() => _BitcoinWidgetState();
}

class _BitcoinWidgetState extends ConsumerState<BitcoinWidget> {
  late TextEditingController controller;
  bool includeAmountInAddress = false;
  String bitcoinAddressWithAmount = '';

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
    final bitcoinAddressWithAmountFuture = await ref.watch(bitcoinReceiveAddressAmountProvider.future);
    setState(() {
      includeAmountInAddress = true;
      bitcoinAddressWithAmount = bitcoinAddressWithAmountFuture;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    final bitcoinAddressAsyncValue = ref.watch(bitcoinAddressProvider);

    return Column(
      children: [
        AmountInput(controller: controller),
        SizedBox(height: height * 0.02),
        includeAmountInAddress
            ? _buildAddressWithAmount(bitcoinAddressWithAmount)
            : _buildDefaultAddress(bitcoinAddressAsyncValue),
        Padding(
          padding: EdgeInsets.all(height * 0.01),
          child: CustomElevatedButton(
            onPressed: _onCreateAddress,
            text: 'Create Address'.i18n,
            controller: controller,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAddress(AsyncValue<String> bitcoinAddressAsyncValue) {
    final height = MediaQuery.of(context).size.height;

    return bitcoinAddressAsyncValue.when(
      data: (bitcoinAddress) {
        return Column(
          children: [
            buildQrCode(bitcoinAddress, context),
            Padding(
              padding: EdgeInsets.all(height * 0.01),
              child: buildAddressText(bitcoinAddress, context, ref),
            ),
          ],
        );
      },
      loading: () => Center(
        child: LoadingAnimationWidget.fourRotatingDots(
          size: MediaQuery.of(context).size.width * 0.6,
          color: Colors.orange,
        ),
      ),
      error: (error, stack) => const Center(
        child: Text(
          'Error loading address',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildAddressWithAmount(String bitcoinAddressWithAmountAsyncValue) {
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        buildQrCode(bitcoinAddressWithAmount, context),
        Padding(
          padding: EdgeInsets.all(height * 0.01),
          child: buildAddressText(bitcoinAddressWithAmount, context, ref),
        ),
      ],
    );
  }
}
