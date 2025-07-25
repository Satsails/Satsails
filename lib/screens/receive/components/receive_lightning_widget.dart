import 'package:Satsails/providers/breez_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';

class ReceiveLightningWidget extends ConsumerStatefulWidget {
  const ReceiveLightningWidget({super.key});

  @override
  ConsumerState<ReceiveLightningWidget> createState() =>
      _ReceiveLightningWidgetState();
}

class _ReceiveLightningWidgetState extends ConsumerState<ReceiveLightningWidget> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

  // State to hold the generated Bolt11 invoice
  ReceivePaymentResponse? _paymentResponse;

  // The default LNURL to display initially
  final String _defaultLnurl = "joao@satsails.com";

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Function to generate a Bolt11 invoice for a specific amount
  Future<void> _createInvoice() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      // If no amount is entered, reset to show the default LNURL
      setState(() {
        _paymentResponse = null;
      });
      return;
    }

    final amountSat = BigInt.tryParse(amountText);
    if (amountSat == null || amountSat.isNegative) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Prepare and then create the invoice in one go
      final prepareResponse = await ref.read(prepareReceiveProvider(amountSat).future);
      ref.read(prepareReceiveResponseProvider.notifier).state = prepareResponse;

      final response = await ref.read(receivePaymentProvider(null).future);
      setState(() {
        _paymentResponse = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating invoice: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine which content to display: the default LNURL or the generated invoice
    final displayContent = _paymentResponse?.destination ?? _defaultLnurl;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 24.h),
        _buildQrDisplay(displayContent),
        Padding(
          padding: EdgeInsets.all(16.h),
          child: AmountInput(controller: _amountController),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.orange))
              : CustomButton(
            onPressed: _createInvoice,
            text: 'Create Invoice'.i18n,
            primaryColor: Colors.green,
            secondaryColor: Colors.green,
          ),
        ),
      ],
    );
  }

  // A single method to build the QR code and address display
  Widget _buildQrDisplay(String content) {
    return Center(
      child: Column(
        children: [
          buildQrCode(content.toUpperCase(), context), // Use uppercase for better QR scanning
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: buildAddressText(content, context, ref),
          ),
        ],
      ),
    );
  }
}
