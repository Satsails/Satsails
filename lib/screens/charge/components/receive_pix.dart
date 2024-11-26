// this screen needs some heavy refactoring. On version "Unyielding conviction" we shall totally redo this spaghetti code.
import 'dart:async';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/models/transfer_model.dart';
import 'package:Satsails/models/user_model.dart';
import 'package:Satsails/screens/shared/error_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_done/flutter_keyboard_done.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:pusher_beams/pusher_beams.dart';

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
          _showStyledDialog(
            context,
            ref,
            title: 'Transaction failed'.i18n(ref),
            message: '',
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
        _showStyledDialog(
          context,
          ref,
          title: 'Error'.i18n(ref),
          message: result.error!.i18n(ref),
        );
      }
    } catch (e) {
      _showStyledDialog(
        context,
        ref,
        title: 'Error'.i18n(ref),
        message: e.toString().i18n(ref),
      );
    }
  }

  void calculateFee(
      double amountInDouble,
      bool hasInsertedAffiliateCode,
      bool hasCreatedAffiliate,
      ) {
    if (hasInsertedAffiliateCode) {
      setState(() {
        _amountToReceive = amountInDouble * 0.015 + 2.97;
      });
    } else if (hasCreatedAffiliate) {
      setState(() {
        _amountToReceive = amountInDouble * 0.02 + 2.97;
      });
    } else {
      setState(() {
        _amountToReceive = amountInDouble * 0.02 + 2.97;
      });
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
      _showStyledDialog(
        context,
        ref,
        title: 'Warning'.i18n(ref),
        message: 'Please enter an amount'.i18n(ref),
      );
      return;
    }

    if (!CPFValidator.isValid(cpf) && !CNPJValidator.isValid(cpf)) {
      _showStyledDialog(
        context,
        ref,
        title: 'Invalid Input'.i18n(ref),
        message: 'Invalid CPF/CNPJ'.i18n(ref),
      );
      return;
    }

    final double amountInDouble =
        double.tryParse(amount.replaceAll(',', '.')) ?? 0.0;

    if (amountInDouble < _minimumPayment) {
      _showStyledDialog(
        context,
        ref,
        title: 'Minimum Amount'.i18n(ref),
        message:
        'Minimum amount is '.i18n(ref) + '${_minimumPayment.toStringAsFixed(2)} BRL',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _timeLeft = const Duration(minutes: 4);
      startTimer();
    });

    final amountTransferred =
    await ref.watch(getAmountTransferredProvider.future);
    final double transferredAmount = double.tryParse(amountTransferred) ?? 0.0;
    _remainingLimit = _dailyLimit - transferredAmount;

    if (_remainingLimit < 0) {
      _remainingLimit = 0;
    }

    if (amountInDouble > _remainingLimit) {
      _showStyledDialog(
        context,
        ref,
        title: 'Daily Limit Reached'.i18n(ref),
        message: 'You have reached the daily limit'.i18n(ref),
      );
      setState(() {
        _isLoading = false;
        _amountController.clear();
      });
      return;
    }

    try {
      final transfer = await TransferService.createTransactionRequest(
          cpf, auth, amountInDouble);

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
      _showStyledDialog(
        context,
        ref,
        title: 'Error'.i18n(ref),
        message: '${e.toString().i18n(ref)}',
      );
    }
  }

  void _showStyledDialog(BuildContext context, WidgetRef ref,
      {required String title, required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                if (message.isNotEmpty)
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24.0),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                  ),
                  child: Text(
                    'OK'.i18n(ref),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInformationDialog(BuildContext context, WidgetRef ref) {
    final messages = <String>[];

    // Add messages based on conditions
    if (_minimumPayment == 10) {
      messages.add('The first 3 purchases have a minimum of 10 BRL, after that the minimum is 250 BRL'.i18n(ref));
    }

    // Remaining daily limit message
    messages.add('${'You can transfer up to'.i18n(ref)} ${formatLimit(_remainingLimit)} BRL${' today'.i18n(ref)}');

    // Minimum payment amount message
    if (_minimumPayment > 0) {
      messages.add('Minimum amount is '.i18n(ref) +
          '${_minimumPayment.toStringAsFixed(2)} BRL');
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Information'.i18n(ref),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                for (var message in messages)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24.0),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                  ),
                  child: Text(
                    'OK'.i18n(ref),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final amountTransferredAsyncValue = ref.watch(getAmountTransferredProvider);

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
            child: ErrorDisplay(message: error.toString(), isCard: true)),
      ),
      data: (amountTransferred) {
        // Calculate remaining limit and other necessary variables
        final double transferredAmount =
            double.tryParse(amountTransferred) ?? 0.0;
        _remainingLimit = _dailyLimit - transferredAmount;

        // Ensure remaining limit is never negative
        if (_remainingLimit < 0) {
          _remainingLimit = 0;
        }

        return FlutterKeyboardDoneWidget(
          doneWidgetBuilder: (context) {
            return const Text('Done');
          },
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Exclamation icon for information
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.02),
                    child: IconButton(
                      icon: Icon(Icons.info_outline, color: Colors.orange),
                      iconSize: MediaQuery.of(context).size.height * 0.05,
                      onPressed: () => _showInformationDialog(context, ref),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.height * 0.015),
                    child: TextField(
                      controller: _amountController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.grey, width: 2.0),
                        ),
                        labelText: 'Insert an amount'.i18n(ref),
                        labelStyle: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.02,
                          color: Colors.grey,
                        ),
                      ),
                      onChanged: (value) {
                        calculateFee(
                          double.tryParse(value.replaceAll(',', '.')) ?? 0.0,
                          ref.read(userProvider).hasInsertedAffiliate,
                          ref.read(userProvider).hasCreatedAffiliate,
                        );
                      },
                    ),
                  ),

                  // CPF/CNPJ input instructions (kept in UI)
                  Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.height * 0.01),
                    child: Text(
                      'Please ensure the CPF/CNPJ you enter matches the CPF/CNPJ registered to your Pix or the transfer may fail'
                          .i18n(ref),
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.015,
                        color: Colors.red,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // CPF/CNPJ input field
                  Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.height * 0.015),
                    child: TextField(
                      controller: _cpfController,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.grey, width: 2.0),
                        ),
                        labelText: 'CPF/CNPJ',
                        labelStyle: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.02,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // Fees information (kept in UI)
                  if (_amountToReceive > 0 && _pixQRCode.isNotEmpty)
                    Text(
                      '${'You will pay in fees'.i18n(ref)} ${currencyFormat(_amountToReceive, 'BRL')}',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.015,
                        color: Colors.green,
                      ),
                    ),

                  // Loading animation or button to generate Pix code
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
                          horizontal:
                          MediaQuery.of(context).size.width * 0.2),
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

                  // Countdown timer for transaction expiration
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  if (_timeLeft.inSeconds > 0 && _pixQRCode.isNotEmpty)
                    Text(
                      'Transaction will expire in:'.i18n(ref) +
                          ' ${_timeLeft.inMinutes}:${(_timeLeft.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.orange),
                    ),

                  // QR code display
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  if (_pixQRCode.isNotEmpty)
                    buildQrCode(_pixQRCode, context),

                  // QR code address text display
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  if (_pixQRCode.isNotEmpty)
                    buildAddressText(_pixQRCode, context, ref),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
