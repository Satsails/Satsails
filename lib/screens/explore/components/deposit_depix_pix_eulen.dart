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
import 'package:Satsails/screens/shared/custom_button.dart';
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
      setState(() {
        amountPurchasedToday = result;
      });
    } catch (e) {
      setState(() {
        amountPurchasedToday = '0';
      });
    }
  }

  Future<void> _fetchTaxId() async {
    try {
      final result = await ref.read(getRegisteredTaxIdProvider.future);
      setState(() {
        registeredTaxId = result;
      });
    } catch (e) {
      setState(() {
        registeredTaxId = 'Loading...';
      });
    }
  }

  Future<void> _checkPixPayment(String transactionId) async {
    _paymentCheckTimer =
        Timer.periodic(const Duration(seconds: 6), (timer) async {
          if (!mounted) {
            timer.cancel();
            return;
          }
          try {
            final result =
            await ref.read(getEulenPixPaymentStateProvider(transactionId).future);
            if (mounted) {
              setState(() {
                pixPayed = result;
              });
            }
            if (pixPayed) {
              timer.cancel();
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                pixPayed = false;
              });
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
      showMessageSnackBar(
        context: context,
        message: 'Amount cannot be empty'.i18n,
        error: true,
      );
      return;
    }

    final int? amountInInt = int.tryParse(amount);

    if (amountInInt == null || amountInInt <= 0) {
      showMessageSnackBar(
        context: context,
        message: 'Please enter a valid amount.'.i18n,
        error: true,
      );
      return;
    }

    if (amountInInt > 5000) {
      showMessageSnackBar(
        context: context,
        message: 'The maximum allowed transfer amount is 5000 BRL'.i18n,
        error: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final purchase =
      await ref.read(createEulenTransferRequestProvider(amountInInt).future);
      _checkPixPayment(purchase.transactionId);

      setState(() {
        _pixQRCode = purchase.pixKey;
        _isLoading = false;
        _amountToReceive = purchase.receivedAmount;
        feePercentage = (1 - (purchase.receivedAmount / purchase.originalAmount)) * 100;
        cashBack = purchase.cashback;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showMessageSnackBar(
        context: context,
        message: e.toString().i18n,
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Pix',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: KeyboardDismissOnTap(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Amount input when no QR code is generated.
                if (_pixQRCode.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 16.h, horizontal: 8.w),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade900,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                          BorderSide(color: Colors.grey[600]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: Colors.transparent, width: 2.0),
                        ),
                        labelText: 'Insert amount'.i18n,
                        labelStyle: TextStyle(
                          fontSize: 20.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                // Show QR code (and related text) if generated and payment is pending.
                if (_pixQRCode.isNotEmpty && !pixPayed)
                  buildQrCode(_pixQRCode, context),
                SizedBox(height: 16.h),
                if (_pixQRCode.isNotEmpty && !pixPayed)
                  buildAddressText(_pixQRCode, context, ref),
                // Show a success check when payment is received.
                if (pixPayed)
                  Column(
                    children: [
                      MSHCheckbox(
                        size: 100,
                        value: pixPayed,
                        colorConfig:
                        MSHColorConfig.fromCheckedUncheckedDisabled(
                          checkedColor: Colors.green,
                          uncheckedColor: Colors.white,
                          disabledColor: Colors.grey,
                        ),
                        style: MSHCheckboxStyle.stroke,
                        duration: const Duration(milliseconds: 500),
                        onChanged: (_) {},
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                // Payment details when QR code is generated.
                if (_pixQRCode.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Amount to Receive'.i18n,
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    vertical: 16.h, horizontal: 8.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius:
                                  BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  '$_amountToReceive Depix',
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Fixed fee'.i18n,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '1 BRL',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total fee'.i18n,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${feePercentage.toStringAsFixed(2)} %',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Cash back'.i18n,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    cashBack.toString(),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              if (!pixPayed)
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Payment Status'.i18n,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Pending'.i18n,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                // Loading indicator while generating QR code.
                if (_isLoading)
                  Center(
                    child: LoadingAnimationWidget.threeArchedCircle(
                      size: 0.1.sh,
                      color: Colors.orange,
                    ),
                  )
                // If no QR code is generated, show the bottom unified info card.
                else if (_pixQRCode.isEmpty)
                  Column(
                    children: [
                      // Generate QR code button.
                      Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 0.2.sw),
                        child: CustomButton(
                          onPressed: _generateQRCode,
                          primaryColor: Colors.orange,
                          secondaryColor: Colors.orange,
                          text: 'Generate QR Code'.i18n,
                          textColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Unified information card styled with the provided container decoration.
                      Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 16.w),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 16.h, horizontal: 8.w),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              // Row 1: Transfer limit.
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.info,
                                      color: Colors.grey,
                                      size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Transfer limit: R\$ 6000'
                                          .i18n,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.attach_money,
                                      color: Colors.grey,
                                      size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Amount Purchased Today:'
                                          .i18n +
                                          ' R\$ $amountPurchasedToday',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.verified_user,
                                      color: Colors.grey,
                                      size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'Registered Tax id: '.i18n + registeredTaxId.i18n,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text(
                    'Back to Home'.i18n,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
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
