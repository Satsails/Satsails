import 'dart:async';
import 'package:Satsails/providers/eulen_transfer_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:msh_checkbox/msh_checkbox.dart';

class DepositDepixPixEulen extends ConsumerStatefulWidget {
  const DepositDepixPixEulen({Key? key}) : super(key: key);

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
  String registeredTaxId = 'Loading...';
  bool pixPayed = false;
  Timer? _paymentCheckTimer;

  @override
  void initState() {
    super.initState();
    _fetchAmountPurchasedToday();
    _fetchTaxId();
  }

  Future<void> _fetchAmountPurchasedToday() async {
    try {
      final result = await ref.read(getAmountPurchasedProvider.future);
      setState(() => amountPurchasedToday = result);
    } catch (e) {
      setState(() => amountPurchasedToday = '0');
    }
  }

  Future<void> _fetchTaxId() async {
    try {
      final result = await ref.read(getRegisteredTaxIdProvider.future);
      setState(() => registeredTaxId = result);
    } catch (e) {
      setState(() => registeredTaxId = 'Loading...');
    }
  }

  Future<void> _checkPixPayment(String transactionId) async {
    _paymentCheckTimer = Timer.periodic(const Duration(seconds: 6), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      try {
        final result = await ref.read(getEulenPixPaymentStateProvider(transactionId).future);
        if (mounted) {
          setState(() => pixPayed = result);
        }
        if (pixPayed) timer.cancel();
      } catch (e) {
        if (mounted) {
          setState(() => pixPayed = false);
        }
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _paymentCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateQRCode() async {
    final amount = _amountController.text;

    if (amount.isEmpty) {
      showMessageSnackBar(context: context, message: 'Amount cannot be empty'.i18n, error: true);
      return;
    }

    final int? amountInInt = int.tryParse(amount);
    if (amountInInt == null || amountInInt <= 0) {
      showMessageSnackBar(context: context, message: 'Please enter a valid amount.'.i18n, error: true);
      return;
    }

    if (amountInInt > 5000) {
      showMessageSnackBar(context: context, message: 'The maximum allowed transfer amount is 5000 BRL'.i18n, error: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final purchase = await ref.read(createEulenTransferRequestProvider(amountInInt).future);
      _checkPixPayment(purchase.transactionId);

      setState(() {
        _pixQRCode = purchase.pixKey;
        _isLoading = false;
        _amountToReceive = purchase.receivedAmount;
        feePercentage = (1 - (purchase.receivedAmount / purchase.originalAmount)) * 100;
        cashBack = purchase.cashback;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      showMessageSnackBar(context: context, message: e.toString().i18n, error: true);
    }
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16.sp, color: Colors.grey[400], fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 16.sp, color: valueColor ?? Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Pix',
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: KeyboardDismissOnTap(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Amount input section
                if (_pixQRCode.isEmpty) ...[
                  Text(
                    'Amount'.i18n,
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20.sp, color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF212121),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  ElevatedButton(
                    onPressed: _generateQRCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
                    ),
                    child: Text(
                      'Generate QR Code'.i18n,
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Card(
                    color: const Color(0xFF212121),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    child: Padding(
                      padding: EdgeInsets.all(16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.white, size: 20.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'Transfer limit: R\$ 6000'.i18n,
                                  style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Icon(Icons.attach_money, color: Colors.white, size: 20.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'Amount Purchased Today: R\$ $amountPurchasedToday'.i18n,
                                  style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Icon(Icons.verified_user, color: Colors.white, size: 20.sp),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'Registered Tax id: $registeredTaxId'.i18n,
                                  style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // QR Code section (centered with black background)
                if (_pixQRCode.isNotEmpty && !pixPayed) ...[
                  SizedBox(height: 24.h),
                  Center(
                    child: buildQrCode(_pixQRCode, context),
                  ),
                  SizedBox(height: 16.h),
                  buildAddressText(_pixQRCode, context, ref),
                  SizedBox(height: 24.h),
                ],

                // Success indicator
                if (pixPayed) ...[
                  SizedBox(height: 24.h),
                  Center(
                    child: MSHCheckbox(
                      size: 100,
                      value: pixPayed,
                      colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                        checkedColor: Colors.green,
                        uncheckedColor: Colors.white,
                        disabledColor: Colors.grey,
                      ),
                      style: MSHCheckboxStyle.stroke,
                      duration: const Duration(milliseconds: 500),
                      onChanged: (_) {},
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],

                // Payment details
                if (_pixQRCode.isNotEmpty)
                  Card(
                    color: const Color(0xFF212121),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    child: Padding(
                      padding: EdgeInsets.all(16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount to Receive'.i18n,
                            style: TextStyle(fontSize: 20.sp, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF212121),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              '$_amountToReceive Depix',
                              style: TextStyle(fontSize: 22.sp, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _buildDetailRow('Fixed fee'.i18n, '1 BRL'),
                          SizedBox(height: 12.h),
                          _buildDetailRow('Total fee'.i18n, '${feePercentage.toStringAsFixed(2)} %'),
                          SizedBox(height: 12.h),
                          _buildDetailRow('Cashback in bitcoin'.i18n, cashBack.toString()),
                          if (!pixPayed) ...[
                            SizedBox(height: 16.h),
                            _buildDetailRow('Payment Status'.i18n, 'Pending'.i18n, valueColor: Colors.orange),
                          ],
                        ],
                      ),
                    ),
                  ),

                // Loading indicator
                if (_isLoading)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Center(
                      child: LoadingAnimationWidget.threeArchedCircle(
                        size: 0.1.sh,
                        color: Colors.orange,
                      ),
                    ),
                  ),

                SizedBox(height: 24.h),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/home'),
                    child: Text(
                      'Back to Home'.i18n,
                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}