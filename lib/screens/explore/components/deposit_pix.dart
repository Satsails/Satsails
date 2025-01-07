import 'dart:async';
import 'package:Satsails/models/user_model.dart';
import 'package:Satsails/providers/purchase_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_done/flutter_keyboard_done.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:pusher_beams/pusher_beams.dart';

class DepositPix extends ConsumerStatefulWidget {
  const DepositPix({Key? key}) : super(key: key);

  @override
  _DepositPixState createState() => _DepositPixState();
}

class _DepositPixState extends ConsumerState<DepositPix> {
  final TextEditingController _amountController = TextEditingController();
  String _pixQRCode = '';
  bool _isLoading = false;
  double _amountToReceive = 0;
  double feePercentage = 0;
  String amountPurchasedToday = '0';
  bool pixPayed = false;
  Timer? _paymentCheckTimer;

  @override
  void initState() {
    super.initState();
    _fetchAmountPurchasedToday();
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


  Future<void> _checkPixPayment(String transactionId) async {
    _paymentCheckTimer = Timer.periodic(const Duration(seconds: 6), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      try {
        final result = await ref.read(getPixPaymentStateProvider(transactionId).future);
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
    final userID = ref.read(userProvider).paymentId;
    final auth = ref.read(userProvider).recoveryCode;
    await PusherBeams.instance.setUserId(userID,UserService.getPusherAuth(auth, userID), (error) {},);

    final amount = _amountController.text;

    // if (double.parse(amountPurchasedToday) + double.parse(amount) > 5000) {
    //   showMessageSnackBar(
    //     context: context,
    //     message: 'You have reached the maximum amount you can transfer today.'.i18n(ref),
    //     error: true,
    //   );
    //   return;
    // }

    if (amount.isEmpty) {
      showMessageSnackBar(
        context: context,
        message: 'Amount cannot be empty'.i18n(ref),
        error: true,
      );
      return;
    }

    final int? amountInInt = int.tryParse(amount);

    if (amountInInt == null || amountInInt <= 0) {
      showMessageSnackBar(
        context: context,
        message: 'Please enter a valid amount.'.i18n(ref),
        error: true,
      );
      return;
    }

    if (amountInInt > 5000) {
      showMessageSnackBar(
        context: context,
        message: 'The maximum allowed transfer amount is 5000 BRL'.i18n(ref),
        error: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final purchase = await ref.read(createPurchaseRequestProvider(amountInInt).future);
      _checkPixPayment(purchase.transferId);

      setState(() {
        _pixQRCode = purchase.pixKey;
        _isLoading = false;
        _amountToReceive = purchase.receivedAmount;
        feePercentage = (1 - (purchase.receivedAmount / purchase.originalAmount)) * 100;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showMessageSnackBar(
        context: context,
        message: e.toString().i18n(ref),
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Pix', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: FlutterKeyboardDoneWidget(
        doneWidgetBuilder: (context) {
          return const Text('Done');
        },
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_pixQRCode.isEmpty)
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
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
                              borderSide: BorderSide(color: Colors.grey[600]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.transparent, width: 2.0),
                            ),
                            labelText: 'Insert amount'.i18n(ref),
                            labelStyle: TextStyle(
                              fontSize: 20.sp,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (_pixQRCode.isNotEmpty && !pixPayed) buildQrCode(_pixQRCode, context),
                SizedBox(height: 16.h),
                if (_pixQRCode.isNotEmpty && !pixPayed) buildAddressText(_pixQRCode, context, ref),
                if (pixPayed)
                  Column(
                    children: [
                      MSHCheckbox(
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
                      SizedBox(height: 16.h),
                    ],
                  ),
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
                                      'Amount to Receive'.i18n(ref),
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
                                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(12.r),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Service Fee'.i18n(ref),
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
                              SizedBox(height: 10.h),
                              if (!pixPayed)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Payment Status'.i18n(ref),
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Pending'.i18n(ref),
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
                if (_isLoading)
                  Center(
                    child: LoadingAnimationWidget.threeArchedCircle(
                      size: 0.1.sh,
                      color: Colors.orange,
                    ),
                  )
                else if (_pixQRCode.isEmpty)
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 0.2.sw,
                        ),
                        child: CustomButton(
                          onPressed: _generateQRCode,
                          primaryColor: Colors.orange,
                          secondaryColor: Colors.orange,
                          text: 'Generate QR Code'.i18n(ref),
                          textColor: Colors.white,
                        ),
                      ),
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
                                  SizedBox(height: 12.h),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'You can only transfer R\$ 6000 per CPF per day.'.i18n(ref),
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          'If you send anymore than that, the amount will be refunded to your bank account.'.i18n(ref),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.grey[400],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          'Please note that refunds are not immediate and may take up to 3 business days to be processed.'.i18n(ref),
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.grey[400],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Amount Purchased Today'.i18n(ref),
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'R\$ $amountPurchasedToday',
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
