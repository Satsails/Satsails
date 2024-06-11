import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/screens/receive/components/amount_input.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LightningWidget extends ConsumerStatefulWidget {
  const LightningWidget({super.key});

  @override
  _LightningWidgetState createState() => _LightningWidgetState();
}

class _LightningWidgetState extends ConsumerState<LightningWidget> {
  String selectedCurrency = 'Liquid';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Receive in'.i18n(ref),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        DropdownButton<String>(
          dropdownColor: Colors.white,
          value: selectedCurrency,
          items: <String>['Liquid', 'Bitcoin'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              ref.read(inputAmountProvider.notifier).state = '0.0';
              selectedCurrency = newValue!;
            });
          },
        ),
        if (selectedCurrency == 'Liquid') const LiquidReceiveWidget() else const BitcoinReceiveWidget(),
      ],
    );
  }
}

class LiquidReceiveWidget extends ConsumerStatefulWidget {
  const LiquidReceiveWidget({super.key});

  @override
  _LiquidReceiveWidgetState createState() => _LiquidReceiveWidgetState();
}

class _LiquidReceiveWidgetState extends ConsumerState<LiquidReceiveWidget> {
  String transactionId = '';

  Future<void> checkTransactionStatus() async {
    try {
      final data = await ref.read(claimSingleBoltzTransactionProvider(transactionId).future);
      if (data) {
        await Fluttertoast.showToast(
          msg: "Transaction Received".i18n(ref),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        ref.read(inputAmountProvider.notifier).state = '0.0';
        ref.read(inputCurrencyProvider.notifier).state = 'BTC';
      }
    } catch (error) {
      await Fluttertoast.showToast(
        msg: "Waiting for transaction...".i18n(ref),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final boltzReceiveAsyncValue = ref.watch(boltzReceiveProvider);
    return Column(
      children: [
        boltzReceiveAsyncValue.when(
          data: (data) {
            transactionId = data.swap.id; // Set the transaction ID
            return Column(
              children: [
                buildQrCode(data.swap.invoice, context),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: buildAddressText(data.swap.invoice, context, ref),
                ),
              ],
            );
          },
          loading: () => Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              size: MediaQuery.of(context).size.width * 0.6,
              color: Colors.orange,
            ),
          ),
          error: (error, stack) => Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
              alignment: Alignment.center,
              child: Text(
                '$error'.i18n(ref),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const AmountInput(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrangeAccent),
              elevation: MaterialStateProperty.all<double>(4),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            onPressed: checkTransactionStatus,
            child: Text('Claim transaction'.i18n(ref), style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class BitcoinReceiveWidget extends ConsumerStatefulWidget {
  const BitcoinReceiveWidget({super.key});

  @override
  _BitcoinReceiveWidgetState createState() => _BitcoinReceiveWidgetState();
}

class _BitcoinReceiveWidgetState extends ConsumerState<BitcoinReceiveWidget> {
  String transactionId = '';

  Future<void> checkTransactionStatus() async {
    try {
      final data = await ref.read(claimSingleBoltzTransactionProvider(transactionId).future);
      if (data) {
        await Fluttertoast.showToast(
          msg: "Transaction Received".i18n(ref),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        ref.read(inputAmountProvider.notifier).state = '0.0';
        ref.read(inputCurrencyProvider.notifier).state = 'BTC';
      }
    } catch (error) {
      await Fluttertoast.showToast(
        msg: "Waiting for transaction...".i18n(ref),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bitcoinBoltzReceiveAsyncValue = ref.watch(bitcoinBoltzReceiveProvider);
    return Column(
      children: [
        bitcoinBoltzReceiveAsyncValue.when(
          data: (data) {
            transactionId = data.swap.id; // Set the transaction ID
            return Column(
              children: [
                buildQrCode(data.swap.invoice, context),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: buildAddressText(data.swap.invoice, context, ref),
                ),
              ],
            );
          },
          loading: () => Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              size: MediaQuery.of(context).size.width * 0.6,
              color: Colors.orange,
            ),
          ),
          error: (error, stack) => Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
              alignment: Alignment.center,
              child: Text(
                '$error'.i18n(ref),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        const AmountInput(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrangeAccent),
              elevation: MaterialStateProperty.all<double>(4),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            onPressed: checkTransactionStatus,
            child: Text('Claim transaction'.i18n(ref), style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}


