import 'dart:async';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/user_model.dart';
import 'package:Satsails/providers/purchase_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_done/flutter_keyboard_done.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  int _amountToReceive = 0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _generateQRCode() async {
    final userID = ref.read(userProvider).paymentId;
    final auth = ref.read(userProvider).recoveryCode;
    await PusherBeams.instance.setUserId(
      userID,
      UserService.getPusherAuth(auth, userID),
          (error) {},
    );

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
        message: 'Please enter a valid integer amount.'.i18n(ref),
        error: true,
      );
      return;
    }

    if (amountInInt > 5000) {
      showBottomOverlayMessage(
        context: context,
        message: 'The maximum allowed transfer amount is 5000 BRL.'.i18n(ref),
        error: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _amountToReceive = (amountInInt * 0.98).toInt(); // Fee calculation (2% fee)
    });

    try {
      final transfer = await ref.read(createPurchaseRequestProvider(amountInInt).future);
      setState(() {
        _pixQRCode = transfer.pixKey;
        _isLoading = false;
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
        title: const Text('Pix', style: TextStyle(color: Colors.white)),
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
                    padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2.0),
                        ),
                        labelText: 'Insert an amount'.i18n(ref),
                        labelStyle: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.02,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                // QR code and address text display
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                if (_pixQRCode.isNotEmpty) buildQrCode(_pixQRCode, context),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                if (_pixQRCode.isNotEmpty) buildAddressText(_pixQRCode, context, ref),

                // Copy text and amount to receive
                if (_pixQRCode.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Value to Receive'.i18n(ref),
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height * 0.018,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$_amountToReceive depix',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height * 0.022,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Fee: 2% + 2 depix',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height * 0.016,
                                  color: Colors.grey,
                                ),
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
                      size: MediaQuery.of(context).size.height * 0.1,
                      color: Colors.orange,
                    ),
                  )
                else if (_pixQRCode.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.2,
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
