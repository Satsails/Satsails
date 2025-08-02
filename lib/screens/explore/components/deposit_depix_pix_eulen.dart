import 'package:Satsails/providers/eulen_transfer_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
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
      setState(() => amountPurchasedToday = result);
    } catch (e) {
      setState(() => amountPurchasedToday = '0');
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _generateQRCode() async {
    final amount = _amountController.text;

    if (amount.isEmpty) {
      showMessageSnackBar(context: context, message: 'Amount cannot be empty'.i18n, error: true, top: true);
      return;
    }

    final int? amountInInt = int.tryParse(amount);
    if (amountInInt == null || amountInInt <= 0) {
      showMessageSnackBar(context: context, message: 'Please enter a valid amount.'.i18n, error: true, top: true);
      return;
    }

    if (amountInInt > 5000) {
      showMessageSnackBar(context: context, message: 'The maximum allowed transfer amount is 5000 BRL'.i18n, error: true, top: true);
      return;
    }


    setState(() => _isLoading = true);

    try {
      final purchase = await ref.read(
        createEulenTransferRequestProvider(amountInInt).future,
      );

      setState(() {
        _pixQRCode = purchase.pixKey;
        _isLoading = false;
        _amountToReceive = purchase.receivedAmount;
        feePercentage = (1 - (purchase.receivedAmount / purchase.originalAmount)) * 100;
        cashBack = purchase.cashback ?? 0;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      showMessageSnackBar(context: context, message: e.toString().i18n, error: true, top: true);
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

  Widget _buildShimmerEffect() {
    final baseColor = Colors.grey[850]!;
    final highlightColor = Colors.grey[700]!;

    Widget shimmerBox({double? width, required double height, double radius = 8.0}) {
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
          SizedBox(height: 24.h),
          shimmerBox(width: 250.w, height: 250.w, radius: 16),
          SizedBox(height: 16.h),
          shimmerBox(height: 48.h, radius: 12),
          SizedBox(height: 24.h),
          Card(
            color: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            child: Padding(
              padding: EdgeInsets.all(16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerBox(width: 200.w, height: 24.h), // Title
                  SizedBox(height: 12.h),
                  shimmerBox(height: 60.h, radius: 12), // Amount display
                  SizedBox(height: 16.h),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [shimmerBox(width: 80.w, height: 16.h), shimmerBox(width: 60.w, height: 16.h)]),
                  SizedBox(height: 12.h),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [shimmerBox(width: 100.w, height: 16.h), shimmerBox(width: 80.w, height: 16.h)]),
                  SizedBox(height: 12.h),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [shimmerBox(width: 150.w, height: 16.h), shimmerBox(width: 50.w, height: 16.h)]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Pix',
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
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
                if (_isLoading)
                  _buildShimmerEffect()
                else if (_pixQRCode.isEmpty) ...[
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
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _generateQRCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
                    ),
                    child: Text(
                      'Generate Payment'.i18n,
                      style: TextStyle(color: Colors.black, fontSize: 16.sp),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Card(
                    color: const Color(0x00333333).withOpacity(0.4),
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
                                  'Transfer limit: R\$ 5000 per CPF/CNPJ'.i18n,
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
                                  'Amount Purchased Today:'.i18n  + ' R\$ $amountPurchasedToday'.i18n,
                                  style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(height: 24.h),
                  Center(
                    child: buildQrCode(_pixQRCode, context),
                  ),
                  SizedBox(height: 16.h),
                  buildAddressText(_pixQRCode, context, ref),
                  SizedBox(height: 24.h),
                  Card(
                    color: const Color(0x00333333).withOpacity(0.4),
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
                            alignment: Alignment.center,
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
                        ],
                      ),
                    ),
                  ),
                ],
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