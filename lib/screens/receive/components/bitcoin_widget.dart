import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/translations/translations.dart';

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
    final bitcoinAddressWithAmountFuture =
    ref.watch(bitcoinReceiveAddressAmountProvider);
    setState(() {
      includeAmountInAddress = true;
      bitcoinAddressWithAmount = bitcoinAddressWithAmountFuture;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bitcoinAddress = ref.watch(addressProvider).bitcoinAddress;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 24.h), // Increased from 16.24.h for more top spacing
        includeAmountInAddress
            ? _buildAddressWithAmount(bitcoinAddressWithAmount)
            : _buildDefaultAddress(bitcoinAddress),
        Padding(
          padding: EdgeInsets.all(16.h), // Increased from 8.0.sp
          child: AmountInput(controller: controller),
        ),
        Padding(
          padding: EdgeInsets.all(16.h), // Increased from 8.12.h
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

  Widget _buildDefaultAddress(String bitcoinAddress) {
    return Center( // Added to center the QR code and address horizontally
      child: Column(
        children: [
          buildQrCode(bitcoinAddress, context),
          SizedBox(height: 16.h), // Added spacing between QR code and address
          Padding(
            padding: EdgeInsets.all(16.h), // Increased from 8.12.h
            child: buildAddressText(bitcoinAddress, context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressWithAmount(String bitcoinAddressWithAmountAsyncValue) {
    return Center( // Added to center the QR code and address horizontally
      child: Column(
        children: [
          buildQrCode(bitcoinAddressWithAmountAsyncValue, context),
          SizedBox(height: 16.h), // Added spacing between QR code and address
          Padding(
            padding: EdgeInsets.all(16.h), // Increased from 8.12.h
            child: buildAddressText(bitcoinAddressWithAmountAsyncValue, context, ref),
          ),
        ],
      ),
    );
  }
}