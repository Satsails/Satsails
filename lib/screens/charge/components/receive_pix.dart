import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/providers/affiliate_provider.dart';
import 'package:Satsails/providers/pix_transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pix_flutter/pix_flutter.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/translations/translations.dart';

class ReceivePix extends ConsumerStatefulWidget {
  @override
  _ReceivePixState createState() => _ReceivePixState();
}

class _ReceivePixState extends ConsumerState<ReceivePix> {
  final TextEditingController _amountController = TextEditingController();
  String _pixQRCode = '';
  String _address = "satsails@depix.info";
  double _amountToReceive = 0.0;
  double _dailyLimit = 5000.0;
  double _remainingLimit = 5000.0;
  bool _isLoading = false;
  String _feeDescription = 'Fee: 2% + 2 BRL';

  double calculateFee(double amountInDouble, bool hasInsertedAffiliateCode, bool hasCreatedAffiliate, int numberOfAffiliateInstalls) {
    if (hasInsertedAffiliateCode) {
      return amountInDouble * 0.015 + 2;
    } else if (hasCreatedAffiliate) {
      if (numberOfAffiliateInstalls > 1) {
        return amountInDouble * 0.015 + 2;
      } else {
        return amountInDouble * 0.02 + 2;
      }
    } else {
      return amountInDouble * 0.02 + 2;
    }
  }

  String getFeeDescription(bool hasInsertedAffiliateCode, bool hasCreatedAffiliate, int numberOfAffiliateInstalls) {
    if (hasInsertedAffiliateCode || (hasCreatedAffiliate && numberOfAffiliateInstalls > 1)) {
      return 'Fee: 1.5% + 2 BRL (Affiliate Discount)';
    } else {
      return 'Fee: 2% + 2 BRL';
    }
  }

  Future<void> _generateQRCode() async {
    final amount = _amountController.text;
    if (amount.isEmpty) {
      return;
    }

    final double amountInDouble = double.tryParse(amount.replaceAll(',', '.')) ?? 0.0;
    if (amountInDouble < 3.0) {
      Fluttertoast.showToast(
        msg: 'Minimum amount is 3 BRL'.i18n(ref),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: MediaQuery.of(context).size.height * 0.02,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final amountTransferred = await ref.watch(getAmountTransferredProvider.future);
    final double transferredAmount = double.tryParse(amountTransferred) ?? 0.0;
    _remainingLimit = _dailyLimit - transferredAmount;

    // Ensure remaining limit is never negative
    if (_remainingLimit < 0) {
      _remainingLimit = 0;
    }

    if (amountInDouble > _remainingLimit) {
      Fluttertoast.showToast(
        msg: 'You have reached the daily limit'.i18n(ref),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: MediaQuery.of(context).size.height * 0.02,
      );
      setState(() {
        _isLoading = false;
        _pixQRCode = '';
        _amountController.clear();
      });
      return;
    }

    final pixPaymentCode = ref.read(userProvider).paymentId;

    PixFlutter pixFlutter = PixFlutter(
      payload: Payload(
        pixKey: _address,
        description: pixPaymentCode,
        merchantName: 'PLEBANK.COM.BR SOLUCOES',
        merchantCity: 'SP',
        txid: pixPaymentCode,
        amount: amountInDouble.toStringAsFixed(2),
        isUniquePayment: true,
      ),
    );

    setState(() {
      _pixQRCode = pixFlutter.getQRCode();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final txReceived = ref.watch(pixTransactionReceivedProvider);
    final amountTransferredAsyncValue = ref.watch(getAmountTransferredProvider);

    final hasInsertedAffiliateCode = ref.watch(userProvider).hasInsertedAffiliate;
    final hasCreatedAffiliate = ref.watch(userProvider).hasCreatedAffiliate;
    double fee = 0;
    double amountInDouble = 0;

    txReceived.whenData((data) {
      if (data != null && data.isNotEmpty) {
        final messageType = data['type'];
        final messageText = data['message'];
        Color backgroundColor;
        switch (messageType) {
          case 'success':
            backgroundColor = Colors.green;
            break;
          case 'delayed':
            backgroundColor = Colors.orange;
            break;
          case 'failed':
          default:
            backgroundColor = Colors.red;
            break;
        }
        _pixQRCode = '';
        _feeDescription = '';
        _amountToReceive = 0.0;
        _amountController.clear();
        Fluttertoast.showToast(
          msg: messageText.i18n(ref),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
          backgroundColor: backgroundColor,
          textColor: Colors.white,
          fontSize: MediaQuery.of(context).size.height * 0.02,
        );
      }
    });

    return amountTransferredAsyncValue.when(
      loading: () => Center(
        child: LoadingAnimationWidget.threeArchedCircle(
          size: MediaQuery.of(context).size.height * 0.1,
          color: Colors.orange,
        ),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text('An error has occurred. Please check your internet connection or contact support'.i18n(ref), style: TextStyle(color: Colors.red)),
        ),
      ),
      data: (amountTransferred) {
        final double transferredAmount = double.tryParse(amountTransferred) ?? 0.0;
        _remainingLimit = _dailyLimit - transferredAmount;

        // Ensure remaining limit is never negative
        if (_remainingLimit < 0) {
          _remainingLimit = 0;
        }

        final amount = _amountController.text;
        if (amount.isNotEmpty) {
          amountInDouble = double.tryParse(amount.replaceAll(',', '.')) ?? 0.0;

          final int numberOfAffiliateInstalls = ref.watch(numberOfAffiliateInstallsProvider).when(
            data: (data) => data,
            loading: () => 0,
            error: (_, __) => 0,
          );

          fee = calculateFee(amountInDouble, hasInsertedAffiliateCode, hasCreatedAffiliate, numberOfAffiliateInstalls);
          _feeDescription = getFeeDescription(hasInsertedAffiliateCode, hasCreatedAffiliate, numberOfAffiliateInstalls);
        }

        final double amountToReceive = amountInDouble - fee;
        _amountToReceive = amountToReceive;

        return SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber, color: Colors.red),
                      SizedBox(width: 1),
                      Text(
                        'You can transfer up to'.i18n(ref) + ' ${formatLimit(_remainingLimit)} BRL' + ' per day'.i18n(ref),
                        style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.02, color: Colors.red),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
                  child: Text(
                    'Transferred Today:'.i18n(ref) + ' ${transferredAmount.toStringAsFixed(2)} BRL',
                    style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.015, color: Colors.green),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015),
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      DecimalTextInputFormatter(decimalRange: 2),
                      CommaTextInputFormatter(),
                    ],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.02, color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 2.0),
                      ),
                      labelText: 'Insert an amount'.i18n(ref),
                      labelStyle: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.02, color: Colors.grey),
                    ),
                  ),
                ),
                if (_amountToReceive > 0)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'You will receive: '.i18n(ref) + '${_amountToReceive.toStringAsFixed(2)} BRL',
                          style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.015, color: Colors.green),
                        ),
                        Text(
                          _feeDescription,
                          style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.015, color: Colors.grey),
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
                else
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2),
                    child: CustomButton(
                      text: 'Generate Pix code'.i18n(ref),
                      primaryColor: Colors.orange,
                      secondaryColor: Colors.orange,
                      textColor: Colors.black,
                      onPressed: () async {
                        await _generateQRCode();
                      },
                    ),
                  ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                if (_pixQRCode.isNotEmpty) buildQrCode(_pixQRCode, context),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                if (_pixQRCode.isNotEmpty) buildAddressText(_pixQRCode, context, ref),
              ],
            ),
          ),
        );
      },
    );
  }
}
