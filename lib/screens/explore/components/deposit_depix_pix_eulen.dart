import 'dart:async';
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
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibration/vibration.dart';


class DepositDepixPixEulen extends ConsumerStatefulWidget {
  const DepositDepixPixEulen({super.key});

  @override
  _DepositPixState createState() => _DepositPixState();
}

class _DepositPixState extends ConsumerState<DepositDepixPixEulen> with TickerProviderStateMixin {
  // Input and transaction state
  final TextEditingController _amountController = TextEditingController();
  String _pixQRCode = '';
  String? _transactionId;
  Timer? _pollingTimer;

  // UI state
  bool _isLoading = false;
  bool _isPaid = false;

  // Data from transaction
  double _amountToReceive = 0;
  double feePercentage = 0;
  double cashBack = 0;
  String amountPurchasedToday = '0';

  // Animation for success checkmark
  late final AnimationController _successAnimationController;
  late final Animation<double> _successScaleAnimation;
  bool _successCheckmarkValue = false;

  @override
  void initState() {
    super.initState();
    _fetchAmountPurchasedToday();

    // Initialize animation controller for the success checkmark
    _successAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _successScaleAnimation = CurvedAnimation(parent: _successAnimationController, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _pollingTimer?.cancel();
    _successAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAmountPurchasedToday() async {
    try {
      final result = await ref.read(getAmountPurchasedProvider.future);
      if (mounted) setState(() => amountPurchasedToday = result);
    } catch (e) {
      if (mounted) setState(() => amountPurchasedToday = '0');
    }
  }

  void _startPolling(String transactionId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      ref.refresh(getEulenPixPaymentStateProvider(transactionId));
    });
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

    setState(() {
      _isLoading = true;
      _isPaid = false; // Reset paid status for new transaction
      _successCheckmarkValue = false; // Reset checkmark animation value
      _successAnimationController.reset();
    });

    try {
      await FirebaseService.requestNotificationPermissions();
      await ref.read(depositInitializerProvider.future);
      final purchase = await ref.read(createEulenTransferRequestProvider(amountInDouble).future);
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
          _transactionId = purchase.transactionId;
        });
        _startPolling(_transactionId!);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showMessageSnackBar(context: context, message: e.toString().i18n, error: true, top: true);
      }
    }
  }

  void _onPaymentConfirmed() {
    _pollingTimer?.cancel();
    setState(() {
      _isPaid = true;
      _successCheckmarkValue = true;
    });
    _successAnimationController.forward();
    Vibration.hasVibrator().then((bool? hasVibrator) {
      if (hasVibrator == true) Vibration.vibrate(duration: 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_transactionId != null) {
      ref.listen<AsyncValue<bool>>(getEulenPixPaymentStateProvider(_transactionId!), (previous, next) {
        final isPaid = next.valueOrNull ?? false;
        if (isPaid && !_isPaid) {
          _onPaymentConfirmed();
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Deposit via Pix'.i18n, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: KeyboardDismissOnTap(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            // **This switcher now handles the final "Paid" state**
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _isLoading
                  ? _buildShimmerEffect()
                  : _transactionId == null
                  ? _buildAmountInputView()
                  : _isPaid
                  ? _buildPaymentSuccessView() // Show success view when paid
                  : _buildQRCodeView(), // Show QR code while waiting
            ),
          ),
        ),
      ),
    );
  }

  /// View shown while waiting for payment.
  Widget _buildQRCodeView() {
    final paymentStatus = ref.watch(getEulenPixPaymentStateProvider(_transactionId!));
    final originalAmount = _amountController.text;

    return Column(
      key: const ValueKey('qrCodeDisplay'),
      children: [
        SizedBox(height: 16.h),
        Center(child: buildQrCode(_pixQRCode, context)),
        SizedBox(height: 24.h),
        AddressDisplayWidget(address: _pixQRCode, isEditable: false, onEditPressed: null),
        SizedBox(height: 24.h),
        _buildPaymentDetailsCard(originalAmount, paymentStatus),
        SizedBox(height: 24.h),
        _buildBackButton(),
      ],
    );
  }

  /// **NEW**: View shown after payment is confirmed, replacing the QR code.
  Widget _buildPaymentSuccessView() {
    final paymentStatus = ref.watch(getEulenPixPaymentStateProvider(_transactionId!));

    return Column(
      key: const ValueKey('paymentSuccess'),
      children: [
        SizedBox(height: 48.h),
        ScaleTransition(
          scale: _successScaleAnimation,
          child: MSHCheckbox(
            size: 90.sp,
            value: _successCheckmarkValue,
            colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(checkedColor: Colors.green),
            style: MSHCheckboxStyle.stroke,
            onChanged: (_) {},
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Payment Received'.i18n,
          style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 24.h),
        _buildPaymentDetailsCard(_amountController.text, paymentStatus),
        SizedBox(height: 24.h),
        CustomButton(
          text: 'Finish'.i18n,
          onPressed: () => context.go('/home'),
          primaryColor: Colors.green.withOpacity(0.8),
          secondaryColor: Colors.green.withOpacity(0.6),
          textColor: Colors.white,
        ),
      ],
    );
  }

  /// This card is now reused by both the QR and Success views.
  Widget _buildPaymentDetailsCard(String originalAmount, AsyncValue<bool> paymentStatus) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(color: const Color(0xFF333333).withOpacity(0.4), borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You will receive'.i18n, style: TextStyle(fontSize: 16.sp, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500)),
          SizedBox(height: 4.h),
          Text('$_amountToReceive Depix', style: TextStyle(fontSize: 28.sp, color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Text('from your R\$ $originalAmount Pix transfer', style: TextStyle(fontSize: 15.sp, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w500)),
          Padding(padding: EdgeInsets.symmetric(vertical: 16.h), child: Divider(color: Colors.white.withOpacity(0.1))),
          _buildDetailRow('Fixed fee'.i18n, '0.99 BRL'),
          SizedBox(height: 12.h),
          _buildDetailRow('Satsails fee'.i18n, '${feePercentage.toStringAsFixed(2)} %'),
          SizedBox(height: 12.h),
          _buildDetailRow('Cashback'.i18n, 'R\$ ${cashBack.toStringAsFixed(2)}', valueColor: const Color(0xFF27AE60)),
          Padding(padding: EdgeInsets.only(top: 16.h), child: Divider(color: Colors.white.withOpacity(0.1))),
          _buildPaymentStatusRow(paymentStatus),
        ],
      ),
    );
  }

  /// Builds the styled status display inside the details card.
  Widget _buildPaymentStatusRow(AsyncValue<bool> status) {
    Widget buildRow(String text, IconData icon, Color color, {bool showSpinner = false}) {
      return Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Status'.i18n, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15.sp)),
            Row(children: [
              if (showSpinner) SizedBox(width: 16.sp, height: 16.sp, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(color))) else Icon(icon, color: color, size: 18.sp),
              SizedBox(width: 8.w),
              Text(text, style: TextStyle(color: color, fontSize: 15.sp, fontWeight: FontWeight.bold)),
            ]),
          ],
        ),
      );
    }

    return status.when(
      data: (isPaid) => isPaid ? buildRow('Confirmed'.i18n, Icons.check_circle, Colors.green) : buildRow('Awaiting Payment'.i18n, Icons.hourglass_bottom, Colors.orange),
      loading: () => buildRow('Checking...'.i18n, Icons.sync, Colors.blue, showSpinner: true),
      error: (e, st) => buildRow('Unable to Verify'.i18n, Icons.error, Colors.red),
    );
  }

  // --- Other widgets (Unchanged) ---
  Widget _buildAmountInputView() {
    return Column(key: const ValueKey('amountInput'), crossAxisAlignment: CrossAxisAlignment.stretch, children: [SizedBox(height: 24.h), _buildAmountEntryCard(), SizedBox(height: 24.h), CustomButton(onPressed: _generateQRCode, primaryColor: Colors.green.withOpacity(0.8), secondaryColor: Colors.green.withOpacity(0.6), textColor: Colors.white, text: 'Generate Payment'.i18n), SizedBox(height: 24.h), _buildInfoCard(), SizedBox(height: 24.h), _buildBackButton()]);
  }

  Widget _buildAmountEntryCard() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        decoration: BoxDecoration(color: const Color(0xFF333333).withOpacity(0.4), borderRadius: BorderRadius.circular(20.r)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Amount to deposit in BRL'.i18n, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16.sp, fontWeight: FontWeight.w500)), SizedBox(height: 12.h), Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Text('R\$', style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.5))), SizedBox(width: 10.w), Expanded(child: TextField(controller: _amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 2)], style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.bold, color: Colors.white), decoration: InputDecoration(border: InputBorder.none, hintText: '0,00', hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)))))])]));
  }

  Widget _buildInfoCard() {
    return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: const Color(0xFF333333).withOpacity(0.4), borderRadius: BorderRadius.circular(16.r)),
        child: Column(children: [_buildInfoRow(icon: Icons.info_outline, text: 'Transfer limit: R\$ 5000 per CPF/CNPJ'.i18n), SizedBox(height: 12.h), _buildInfoRow(icon: Icons.attach_money, text: 'Amount Purchased Today:'.i18n + ' R\$ $amountPurchasedToday')]));
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(children: [Icon(icon, color: Colors.white.withOpacity(0.7), size: 20.sp), SizedBox(width: 12.w), Expanded(child: Text(text, style: TextStyle(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w500)))]);
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontSize: 15.sp, color: Colors.grey[400], fontWeight: FontWeight.w500)), Text(value, style: TextStyle(fontSize: 15.sp, color: valueColor ?? Colors.white, fontWeight: FontWeight.bold))]);
  }

  Widget _buildBackButton() {
    return Center(child: TextButton(onPressed: () => context.go('/home'), child: Text('Back to Home'.i18n, style: TextStyle(fontSize: 16.sp, color: Colors.white.withOpacity(0.8)))));
  }

  Widget _buildShimmerEffect() {
    final baseColor = Colors.grey[900]!;
    final highlightColor = Colors.grey[800]!;
    Widget shimmerBox({double? width, required double height, double radius = 16.0}) {
      return Container(width: width, height: height, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(radius.r)));
    }

    return Shimmer.fromColors(baseColor: baseColor, highlightColor: highlightColor, child: Column(children: [SizedBox(height: 16.h), shimmerBox(width: 250.w, height: 250.w), SizedBox(height: 24.h), shimmerBox(height: 56.h, radius: 12), SizedBox(height: 24.h), shimmerBox(height: 220.h, radius: 20)]));
  }
}