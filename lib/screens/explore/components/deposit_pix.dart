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

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _generateQRCode() async {
    final userID = ref.read(userProvider).paymentId;
    final auth = ref.read(userProvider).recoveryCode;
    await PusherBeams.instance.setUserId(userID,UserService.getPusherAuth(auth, userID), (error) {},);

    final amount = _amountController.text;

    if (amount.isEmpty) {
      showBottomOverlayMessage(
        context: context,
        message: 'Amount cannot be empty'.i18n(ref),
        error: true,
      );
      return;
    }

    final int? amountInInt = int.tryParse(amount);

    if (amountInInt == null || amountInInt <= 0) {
      showBottomOverlayMessage(
        context: context,
        message: 'Please enter a valid amount.'.i18n(ref),
        error: true,
      );
      return;
    }

    if (amountInInt > 5000) {
      showBottomOverlayMessage(
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
      showBottomOverlayMessage(
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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.02.sh, horizontal: 0.002.sw),
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
                if (_pixQRCode.isNotEmpty) buildQrCode(_pixQRCode, context),
                SizedBox(height: 0.02.sh),
                if (_pixQRCode.isNotEmpty) buildAddressText(_pixQRCode, context, ref),
                if (_pixQRCode.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 0.01.sh),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amount to Receive'.i18n(ref),
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  '$_amountToReceive Depix',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                feePercentage.toStringAsFixed(2) + ' % fee',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[400],
                                ),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                'R\$ 1 Fixed fee',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                // if (_pixQRCode.isNotEmpty)
                //   Padding(
                //     padding: EdgeInsets.only(top: 10.h),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.stretch,
                //       children: [
                //         Container(
                //           padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                //           decoration: BoxDecoration(
                //             color: Colors.grey.shade900,
                //             borderRadius: BorderRadius.circular(15.r),
                //           ),
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               // Title
                //               Text(
                //                 'Valor a receber'.i18n(ref),
                //                 style: TextStyle(
                //                   fontSize: 18.sp,
                //                   color: Colors.white,
                //                   fontWeight: FontWeight.w600,
                //                 ),
                //               ),
                //               SizedBox(height: 8.h),
                //               // Amount in BRL
                //               Container(
                //                 width: double.infinity,
                //                 padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                //                 decoration: BoxDecoration(
                //                   color: Colors.grey.shade800,
                //                   borderRadius: BorderRadius.circular(12.r),
                //                 ),
                //                 child: Text(
                //                   'R\$${_amountToReceive.toStringAsFixed(2)}',
                //                   style: TextStyle(
                //                     fontSize: 22.sp,
                //                     color: Colors.white,
                //                     fontWeight: FontWeight.bold,
                //                   ),
                //                   textAlign: TextAlign.center,
                //                 ),
                //               ),
                //               SizedBox(height: 16.h),
                //               // "Você receberá" and fee details
                //               Text(
                //                 'Você receberá: ${(0.98 * _amountToReceive - 2).toStringAsFixed(2)} BRL',
                //                 style: TextStyle(
                //                   fontSize: 16.sp,
                //                   color: Colors.white,
                //                   fontWeight: FontWeight.bold,
                //                 ),
                //               ),
                //               SizedBox(height: 8.h),
                //               Text(
                //                 'Fee: 2% + 2 BRL',
                //                 style: TextStyle(
                //                   fontSize: 14.sp,
                //                   color: Colors.grey,
                //                   fontStyle: FontStyle.italic,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),

                if (_isLoading)
                  Center(
                    child: LoadingAnimationWidget.threeArchedCircle(
                      size: 0.1.sh,
                      color: Colors.orange,
                    ),
                  )
                else if (_pixQRCode.isEmpty)
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
