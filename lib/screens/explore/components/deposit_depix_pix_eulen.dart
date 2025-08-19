import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/notifications/firebase.dart';
import 'package:Satsails/providers/eulen_transfer_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/screens/shared/address_display_widget.dart';
import 'package:shimmer/shimmer.dart';

class DepositDepixPixEulen extends ConsumerStatefulWidget {
  const DepositDepixPixEulen({super.key});

  @override
  _DepositPixState createState() => _DepositPixState();
}

class _DepositPixState extends ConsumerState<DepositDepixPixEulen> {
  final TextEditingController _amountController = TextEditingController();
  String _pixQRCode = '';
  bool _isLoading = false;
  double _amountToReceive = 0;
  double feePercentage = 0;
  double cashBack = 0;
  String amountPurchasedToday = '0';

  @override
  void initState() {
    super.initState();
    _fetchAmountPurchasedToday();
  }

  Future<void> _fetchAmountPurchasedToday() async {
    try {
      final result = await ref.read(getAmountPurchasedProvider.future);
      if (mounted) {
        setState(() => amountPurchasedToday = result);
      }
    } catch (e) {
      if (mounted) {
        setState(() => amountPurchasedToday = '0');
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _generateQRCode() async {
    final amount = _amountController.text.replaceAll(',', '.');

    if (amount.isEmpty) {
      showMessageSnackBar(context: context, message: 'Amount cannot be empty'.i18n, error: true, top: true);
      return;
    }

    final double? amountInDouble = double.tryParse(amount);
    if (amountInDouble == null || amountInDouble <= 0) {
      showMessageSnackBar(context: context, message: 'Please enter a valid amount.'.i18n, error: true, top: true);
      return;
    }

    if (amountInDouble > 5000) {
      showMessageSnackBar(context: context, message: 'The maximum allowed transfer amount is 5000 BRL'.i18n, error: true, top: true);
      return;
    }


    setState(() => _isLoading = true);

    try {
      await FirebaseService.requestNotificationPermissions();
      await ref.read(depositInitializerProvider.future);
      final purchase = await ref.read(
        createEulenTransferRequestProvider(amountInDouble).future,
      );

      final cashbackAmount = purchase.cashback ?? 0;
      final totalFeeInBrl = purchase.originalAmount - purchase.receivedAmount;
      final variableFeeInBrl = totalFeeInBrl - 0.99;
      final satsailsFeeAfterCashback = variableFeeInBrl - cashbackAmount;
      final newFeePercentage = (satsailsFeeAfterCashback / purchase.originalAmount) * 100;

      if (mounted) {
        setState(() {
          _pixQRCode = purchase.pixKey;
          _isLoading = false;
          _amountToReceive = purchase.receivedAmount;
          feePercentage = newFeePercentage > 0 ? newFeePercentage : 0;
          cashBack = cashbackAmount;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showMessageSnackBar(context: context, message: e.toString().i18n, error: true, top: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Deposit via Pix'.i18n,
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: KeyboardDismissOnTap(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isLoading
                  ? _buildShimmerEffect()
                  : _pixQRCode.isEmpty
                  ? _buildAmountInputView()
                  : _buildQRCodeView(),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the initial view for the user to input the deposit amount.
  Widget _buildAmountInputView() {
    return Column(
      key: const ValueKey('amountInput'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 24.h),
        _buildAmountEntryCard(),
        SizedBox(height: 24.h),
        CustomButton(
          onPressed: _generateQRCode,
          primaryColor: Colors.green.withOpacity(0.8),
          secondaryColor: Colors.green.withOpacity(0.6),
          textColor: Colors.white,
          text: 'Generate Payment'.i18n,
        ),
        SizedBox(height: 24.h),
        _buildInfoCard(),
        SizedBox(height: 24.h),
        _buildBackButton(),
      ],
    );
  }

  /// Builds the view displaying the generated QR code and payment details.
  Widget _buildQRCodeView() {
    final originalAmount = _amountController.text;

    return Column(
      key: const ValueKey('qrCodeDisplay'),
      children: [
        SizedBox(height: 16.h),
        Center(child: buildQrCode(_pixQRCode, context)),
        SizedBox(height: 24.h),
        AddressDisplayWidget(address: _pixQRCode, isEditable: false, onEditPressed: null),
        SizedBox(height: 24.h),
        _buildPaymentDetailsCard(originalAmount),
        SizedBox(height: 24.h),
        _buildBackButton(),
      ],
    );
  }

  /// The main card for entering the BRL amount, inspired by BalanceCard.
  Widget _buildAmountEntryCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFF333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount to deposit in BRL'.i18n,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'R\$',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 2)],
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0,00',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// The card displaying transfer limits and daily purchase info.
  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.info_outline,
            text: 'Transfer limit: R\$ 5000 per CPF/CNPJ'.i18n,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            icon: Icons.attach_money,
            text: 'Amount Purchased Today:'.i18n + ' R\$ $amountPurchasedToday',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.7), size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  /// The card displaying the final amount and fee breakdown after QR generation.
  Widget _buildPaymentDetailsCard(String originalAmount) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You will receive'.i18n,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '$_amountToReceive Depix',
            style: TextStyle(fontSize: 28.sp, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Text(
            'from your R\$ $originalAmount Pix transfer',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Divider(color: Colors.white.withOpacity(0.1)),
          ),
          _buildDetailRow('Fixed fee'.i18n, '0.99 BRL'),
          SizedBox(height: 12.h),
          _buildDetailRow('Satsails fee'.i18n, '${feePercentage.toStringAsFixed(2)} %'),
          SizedBox(height: 12.h),
          _buildDetailRow('Cashback'.i18n, 'R\$ ${cashBack.toStringAsFixed(2)}', valueColor: const Color(0xFF27AE60)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 15.sp, color: Colors.grey[400], fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 15.sp, color: valueColor ?? Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// A simple text button to navigate back to the home screen.
  Widget _buildBackButton() {
    return Center(
      child: TextButton(
        onPressed: () => context.go('/home'),
        child: Text(
          'Back to Home'.i18n,
          style: TextStyle(fontSize: 16.sp, color: Colors.white.withOpacity(0.8)),
        ),
      ),
    );
  }

  /// The shimmer effect shown while the QR code is being generated.
  Widget _buildShimmerEffect() {
    final baseColor = Colors.grey[900]!;
    final highlightColor = Colors.grey[800]!;

    Widget shimmerBox({double? width, required double height, double radius = 16.0}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(radius.r),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: [
          SizedBox(height: 16.h),
          shimmerBox(width: 250.w, height: 250.w),
          SizedBox(height: 24.h),
          shimmerBox(height: 56.h, radius: 12),
          SizedBox(height: 24.h),
          shimmerBox(height: 220.h, radius: 20),
        ],
      ),
    );
  }
}