import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pix_flutter/pix_flutter.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';

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

  Future<void> _generateQRCode() async {
    final amount = _amountController.text;
    if (amount.isEmpty) {
      return;
    }

    final double amountInDouble = double.tryParse(amount.replaceAll(',', '.')) ?? 0.0;
    if (amountInDouble < 3.0) {
      Fluttertoast.showToast(msg: 'Minimum amount is 3 BRL'.i18n(ref));
      return;
    }

    final amountTransferred = await ref.read(getAmountTransferredProvider.future);
    final double transferredAmount = double.tryParse(amountTransferred) ?? 0.0;
    _remainingLimit = _dailyLimit - transferredAmount;

    if (amountInDouble > _remainingLimit) {
      Fluttertoast.showToast(msg: 'You have reached the daily limit'.i18n(ref));
      return;
    }

    final double fee = amountInDouble * 0.02 + 2.0;
    final double amountToReceive = amountInDouble - fee;

    setState(() {
      _amountToReceive = amountToReceive;
    });

    final pixPaymentCode = ref.read(settingsProvider).pixPaymentCode;

    PixFlutter pixFlutter = PixFlutter(
      payload: Payload(
        pixKey: _address,
        description: pixPaymentCode,
        merchantName: 'PLEBANK.COM.BR SOLUCOES ',
        merchantCity: 'SP',
        txid: pixPaymentCode,
        amount: amountInDouble.toStringAsFixed(2),
        isUniquePayment: true,
      ),
    );

    setState(() {
      _pixQRCode = pixFlutter.getQRCode();
    });
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
        child: Center(child: Text('An error as ocurred. Please check you internet connection or contact support')),
      ),
      data: (amountTransferred) {
        final double transferredAmount = double.tryParse(amountTransferred) ?? 0.0;
        _remainingLimit = _dailyLimit - transferredAmount;

        return SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'You can transfer up to ${_remainingLimit.toString()} BRL today'.i18n(ref),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      DecimalTextInputFormatter(decimalRange: 2),
                      CommaTextInputFormatter(),
                    ],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.03),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange, width: 2.0),
                      ),
                      hintText: 'Insert an amount'.i18n(ref),
                    ),
                  ),
                ),
                if (_amountToReceive > 0)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'You will receive: ${_amountToReceive.toStringAsFixed(2)} BRL'.i18n(ref),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                CustomButton(
                  text: 'Generate Pix code'.i18n(ref),
                  onPressed: _generateQRCode,
                ),
                const SizedBox(height: 20),
                if (_pixQRCode.isNotEmpty) buildQrCode(_pixQRCode, context),
                const SizedBox(height: 20),
                if (_pixQRCode.isNotEmpty) buildAddressText(_pixQRCode, context, ref),
              ],
            ),
          ),
        );
      },
    );
  }
}
