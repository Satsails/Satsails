import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/breez_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:shimmer/shimmer.dart';

class ReceiveLightningWidget extends ConsumerStatefulWidget {
  const ReceiveLightningWidget({super.key});

  @override
  ConsumerState<ReceiveLightningWidget> createState() =>
      _ReceiveLightningWidgetState();
}

class _ReceiveLightningWidgetState extends ConsumerState<ReceiveLightningWidget> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

  ReceivePaymentResponse? _paymentResponse;

  final String _defaultLnurl = "joao@lnurl.satsails.com";

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _createInvoice() async {
    final test = await ref.read(setupLnAddressProvider((username: 'joao', isRecover: false)).future);
    FocusScope.of(context).unfocus();

    ref.read(inputAmountProvider.notifier).state =
    _amountController.text.isEmpty ? '0.0' : _amountController.text;
    final amountSat = ref.read(lnAmountProvider);

    if (amountSat <= 0) {
      showMessageSnackBar(
        context: context,
        message: 'Please enter a valid amount'.i18n,
        error: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prepareResponse = await ref.read(prepareReceiveProvider(BigInt.from(amountSat)).future);
      ref.read(prepareReceiveResponseProvider.notifier).state = prepareResponse;

      final response = await ref.read(receivePaymentProvider(null).future);
      setState(() {
        _paymentResponse = response;
      });
    } catch (e) {
      showMessageSnackBar(
        context: context,
        message: 'An error occurred: $e'.i18n,
        error: true,
      );
      setState(() {
        _paymentResponse = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayContent = _paymentResponse?.destination ?? _defaultLnurl;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 24.h),
        _isLoading ? _buildShimmerEffect() : _buildQrDisplay(displayContent),
        Padding(
          padding: EdgeInsets.all(16.h),
          child: AmountInput(controller: _amountController),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: CustomButton(
            onPressed: _createInvoice,
            text: 'Generate Invoice'.i18n,
            primaryColor: Colors.green,
            secondaryColor: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerEffect() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;
    final qrSize = 250.w;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Center(
        child: Column(
          children: [
            // QR Code Placeholder
            Container(
              width: qrSize,
              height: qrSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(height: 16.h),
            // Address Text Placeholder
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Container(
                height: 24.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrDisplay(String content) {
    return Center(
      child: Column(
        children: [
          buildQrCode(content, context),
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