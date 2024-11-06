import 'dart:async';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/transfer_model.dart';
import 'package:Satsails/models/user_model.dart';
import 'package:Satsails/providers/affiliate_provider.dart';
import 'package:Satsails/providers/pix_transaction_provider.dart';
import 'package:Satsails/screens/shared/error_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_done/flutter_keyboard_done.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:pusher_beams/pusher_beams.dart';
import './pix_buttons.dart';

class ReceivePix extends ConsumerStatefulWidget {
  const ReceivePix({Key? key}) : super(key: key);

  @override
  _ReceivePixState createState() => _ReceivePixState();
}

class _ReceivePixState extends ConsumerState<ReceivePix> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  String _pixQRCode = '';
  double _amountToReceive = 0.0;
  final double _dailyLimit = 5000.0;
  double _remainingLimit = 5000.0;
  bool _isLoading = false;
  String _feeDescription = 'Fee: 2% + 2.97 BRL';
  Timer? _timer;
  Duration _timeLeft = const Duration(minutes: 4);
  double _minimumPayment = 250.0;

  @override
  void initState() {
    super.initState();
    _fetchMinimumPayment();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer on dispose
    _amountController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft.inSeconds > 0) {
          _timeLeft -= const Duration(seconds: 1);
        } else {
          timer.cancel();
          _pixQRCode = '';
          _amountToReceive = 0.0;
          Fluttertoast.showToast(
            msg: 'Transaction failed'.i18n(ref),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      });
    });
  }

  Future<void> _fetchMinimumPayment() async {
    final auth = ref.read(userProvider).recoveryCode;
    try {
      final result = await TransferService.getMinimumPurchase(auth);
      if (result.error == null && result.data != null) {
        setState(() {
          _minimumPayment = double.tryParse(result.data!) ?? 10.0;
        });
      } else {
        Fluttertoast.showToast(
          msg: result.error!.i18n(ref),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().i18n(ref),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  double calculateFee(
      double amountInDouble,
      bool hasInsertedAffiliateCode,
      bool hasCreatedAffiliate,
      int numberOfAffiliateInstalls,
      ) {
    if (hasInsertedAffiliateCode) {
      return amountInDouble * 0.015 + 2.97;
    } else if (hasCreatedAffiliate) {
      if (numberOfAffiliateInstalls > 1) {
        return amountInDouble * 0.015 + 2.97;
      } else {
        return amountInDouble * 0.02 + 2.97;
      }
    } else {
      return amountInDouble * 0.02 + 2.97;
    }
  }

  String getFeeDescription(
      bool hasInsertedAffiliateCode,
      bool hasCreatedAffiliate,
      int numberOfAffiliateInstalls,
      ) {
    if (hasInsertedAffiliateCode || (hasCreatedAffiliate && numberOfAffiliateInstalls > 1)) {
      return 'Fee: 1.5% + 2,98 BRL (Affiliate Discount)';
    } else {
      return 'Fee: 2% + 2,98 BRL (No Affiliate Discount)';
    }
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
    final cpf = _cpfController.text;

    // Validate amount input
    if (amount.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter an amount'.i18n(ref),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: MediaQuery.of(context).size.height * 0.02,
      );
      return;
    }

    if (!CPFValidator.isValid(cpf) && !CNPJValidator.isValid(cpf)) {
      Fluttertoast.showToast(
        msg: 'Invalid CPF/CNPJ'.i18n(ref),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: MediaQuery.of(context).size.height * 0.02,
      );
      return;
    }

    final double amountInDouble = double.tryParse(amount.replaceAll(',', '.')) ?? 0.0;

    if (amountInDouble < _minimumPayment) {
      Fluttertoast.showToast(
        msg: 'Minimum amount is '.i18n(ref) + '${_minimumPayment.toStringAsFixed(2)} ' + 'BRL',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: MediaQuery.of(context).size.height * 0.02,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _timeLeft = const Duration(minutes: 4);
      startTimer();
    });

    final amountTransferred = await ref.watch(getAmountTransferredProvider.future);
    final double transferredAmount = double.tryParse(amountTransferred) ?? 0.0;
    _remainingLimit = _dailyLimit - transferredAmount;

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
        _amountController.clear();
      });
      return;
    }

    try {
      final transfer = await TransferService.createTransactionRequest(cpf, auth, amountInDouble);

      setState(() {
        if (transfer.error != null) {
          throw transfer.error!;
        }
        _pixQRCode = transfer.data!.pixKey;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: '${e.toString().i18n(ref)}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: MediaQuery.of(context).size.height * 0.02,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final txReceived = ref.watch(pixTransactionReceivedProvider);
    final amountTransferredAsyncValue = ref.watch(getAmountTransferredProvider);

    final hasInsertedAffiliateCode = ref.watch(userProvider).hasInsertedAffiliate;
    final hasCreatedAffiliate = ref.watch(userProvider).hasCreatedAffiliate;
    double fee = 0;
    double amountInDouble = 0;

    // txReceived.whenData((data) {
    //   if (data.isNotEmpty) {
    //     final messageType = data['type'];
    //     final messageText = data['message'];
    //     Color backgroundColor;
    //
    //     switch (messageType) {
    //       case 'success':
    //         backgroundColor = Colors.green;
    //         break;
    //       case 'delayed':
    //         backgroundColor = Colors.orange;
    //         break;
    //       case 'failed':
    //       default:
    //         backgroundColor = Colors.red;
    //         break;
    //     }
    //
    //     _pixQRCode = '';
    //     _feeDescription = '';
    //     _amountToReceive = 0.0;
    //     _amountController.clear();
    //
    //     Future.microtask(() {
    //       ref.read(topSelectedButtonProvider.notifier).state = "History";
    //       ref.read(groupButtonControllerProvider).selectIndex(1);
    //       Fluttertoast.showToast(
    //         msg: messageText.i18n(ref),
    //         toastLength: Toast.LENGTH_SHORT,
    //         gravity: ToastGravity.TOP,
    //         timeInSecForIosWeb: 1,
    //         backgroundColor: backgroundColor,
    //         textColor: Colors.white,
    //         fontSize: MediaQuery.of(context).size.height * 0.02,
    //       );
    //     });
    //   }
    // });

    return amountTransferredAsyncValue.when(
      loading: () => Center(
        child: LoadingAnimationWidget.threeArchedCircle(
          size: MediaQuery.of(context).size.height * 0.1,
          color: Colors.orange,
        ),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: ErrorDisplay(message: error.toString(), isCard: true)),
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

          fee = calculateFee(
            amountInDouble,
            hasInsertedAffiliateCode,
            hasCreatedAffiliate,
            numberOfAffiliateInstalls,
          );
          _feeDescription = getFeeDescription(
            hasInsertedAffiliateCode,
            hasCreatedAffiliate,
            numberOfAffiliateInstalls,
          );
        }

        final double amountToReceive = amountInDouble - fee;
        _amountToReceive = amountToReceive;

        return FlutterKeyboardDoneWidget(
          doneWidgetBuilder: (context) {
            return const Text('Done');
          },
          child: SingleChildScrollView(
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
                        const Icon(Icons.warning_amber, color: Colors.red),
                        const SizedBox(width: 1),
                        Text(
                          '${'You can transfer up to'.i18n(ref)} ${formatLimit(_remainingLimit)} BRL${' today'.i18n(ref)}',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
                    child: Text(
                      '${'Transferred Today:'.i18n(ref)} ${transferredAmount.toStringAsFixed(2)} BRL',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.015,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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
                  if (_minimumPayment > 0)
                    Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
                      child: Text(
                        'Minimum amount is '.i18n(ref) + '${_minimumPayment.toStringAsFixed(2)} ' + 'BRL',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.02,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
                    child: Text(
                      'Please ensure the CPF/CNPJ you enter matches the CPF/CNPJ registered to your Pix or the transfer may fail'
                          .i18n(ref),
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.015,
                        color: Colors.red,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015),
                    child: TextField(
                      controller: _cpfController,
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
                        labelText: 'CPF/CNPJ',
                        labelStyle: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.02,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  if (_amountToReceive > 0 && _pixQRCode.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '${'You will receive: '.i18n(ref)}${currencyFormat(_amountToReceive, 'BRL')}',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height * 0.015,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            _feeDescription.i18n(ref),
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height * 0.015,
                              color: Colors.grey,
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
                      padding:
                      EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2),
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
                  if (_timeLeft.inSeconds > 0 && _pixQRCode.isNotEmpty)
                    Text(
                      'Transaction will expire in:'.i18n(ref) +
                          ' ${_timeLeft.inMinutes}:${(_timeLeft.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.orange),
                    ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  if (_pixQRCode.isNotEmpty) buildQrCode(_pixQRCode, context),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  if (_pixQRCode.isNotEmpty) buildAddressText(_pixQRCode, context, ref),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
