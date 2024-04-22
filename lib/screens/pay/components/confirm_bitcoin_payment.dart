import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:satsails/providers/bitcoin_provider.dart';
import 'package:satsails/providers/send_tx_provider.dart';
import 'package:satsails/providers/settings_provider.dart';
import '../../../providers/balance_provider.dart';
import 'package:action_slider/action_slider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:interactive_slider/interactive_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ConfirmBitcoinPayment extends HookConsumerWidget {
  ConfirmBitcoinPayment({super.key});
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final titleFontSize = screenHeight * 0.03;
    final sendTxState = ref.watch(sendTxProvider);
    final initializeBalance = ref.watch(initializeBalanceProvider);
    final btcFormart = ref.watch(settingsProvider).btcFormat;
    final btcBalanceInFormat = ref.watch(btcBalanceInFormatProvider(btcFormart));
    final sendAmount = ref.watch(sendAmountProvider.notifier);


    useEffect(() {
      Future.microtask(() => controller.text = ref.watch(inputValueProvider).toStringAsFixed(8));
    }, []);


    final dynamicFontSize = MediaQuery.of(context).size.height * 0.02;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final dynamicMargin = MediaQuery.of(context).size.width * 0.05;
    final dynamicSizedBox = MediaQuery.of(context).size.height * 0.01;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Confirm Payment'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  margin: EdgeInsets.all(dynamicMargin),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: dynamicPadding, horizontal: dynamicPadding / 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Bitcoin Balance', style: TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
                          initializeBalance.when(
                              data: (_) => SizedBox(height: titleFontSize * 1.5, child: Text('$btcBalanceInFormat $btcFormart', style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center)),
                              loading: () => SizedBox(height: titleFontSize * 1.5, child: LoadingAnimationWidget.prograssiveDots(size: titleFontSize, color: Colors.white)),
                              error: (error, stack) => SizedBox(height: titleFontSize * 1.5, child: TextButton(onPressed: () { ref.refresh(initializeBalanceProvider); }, child: Text('Retry', style: TextStyle(color: Colors.white, fontSize: titleFontSize))))
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        sendTxState.address,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: FocusScope(
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      CurrencyTextInputFormatter.currency(
                        decimalDigits: 8,
                        enableNegative: false,
                        maxValue: 1000,
                        symbol: '',
                      ),
                    ],
                    style: TextStyle(fontSize: dynamicFontSize * 3),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0.00000000',
                    ),
                    onChanged: (value) async {
                      ref.read(sendAmountProvider.notifier).state = ((double.parse(value) * 100000000).toInt());
                    },
                  ),
                ),
              ),
              SizedBox(height: dynamicSizedBox),
              Text(
                '~ ${ref.watch(bitcoinValueInCurrencyProvider).toStringAsFixed(2)} ${ref.watch(settingsProvider).currency}',
                style: TextStyle(
                  fontSize: dynamicFontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: dynamicSizedBox),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      try {
                        final balance = ref.watch(balanceNotifierProvider).btcBalance;
                        final transactionBuilderParams = await ref.watch(bitcoinTransactionBuilderProvider(sendAmount.state).future).then((value) => value);
                        final transaction = await ref.watch(buildDrainWalletBitcoinTransactionProvider(transactionBuilderParams).future);
                        final fee = transaction.txDetails.fee!;
                        final amountToSet = (balance - fee).toDouble() / 100000000;
                        controller.text = amountToSet.toStringAsFixed(8);
                        ref.read(sendAmountProvider.notifier).state = (amountToSet * 100000000).toInt();
                      }
                      catch (e) {
                        Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: dynamicPadding, vertical: dynamicPadding / 2),
                      child: Text(
                        'Max',
                        style: TextStyle(
                          fontSize: dynamicFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: dynamicSizedBox),
              InteractiveSlider(
                centerIcon: Icon(Clarity.block_solid, color: Colors.black),
                foregroundColor: Colors.deepOrange,
                unfocusedHeight: dynamicFontSize * 2,
                focusedHeight: dynamicFontSize * 2,
                initialProgress: 15,
                min: 25.0,
                max: 1.0,
                onChanged: (dynamic value){
                  ref.read(sendBlocksProvider.notifier).state = value;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Transaction in ~ ${ref.watch(sendBlocksProvider).toInt() * 10} minutes',
                  style: TextStyle(
                    fontSize: dynamicFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: dynamicSizedBox),
              ref.watch(feeProvider).when(
                data: (int fee) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.deepOrange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Fee: ' + fee.toString() + ' sats',
                            style: TextStyle(fontSize: dynamicFontSize, fontWeight: FontWeight.bold, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LoadingAnimationWidget.prograssiveDots(size: dynamicFontSize, color: Colors.black),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:  TextButton(onPressed: () { ref.refresh(feeProvider); }, child: Text(ref.watch(sendAmountProvider.notifier).state == 0 ? '' : error.toString(), style: TextStyle(color: Colors.black, fontSize: dynamicFontSize))),
                ),
              ),
              SizedBox(height: dynamicSizedBox),
              ref.watch(feeValueInCurrencyProvider).when(
                  data: (double feeValue) {
                    return Text(
                      '~ ${feeValue.toStringAsFixed(2)} ${ref.watch(settingsProvider).currency}',
                      style: TextStyle(
                        fontSize: dynamicFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                  loading: () => LoadingAnimationWidget.prograssiveDots(size: dynamicFontSize, color: Colors.black),
                  error: (error, stack) => Text('')
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Center(
                child: ActionSlider.standard(
                  sliderBehavior: SliderBehavior.stretch,
                  width: double.infinity,
                  backgroundColor: Colors.white,
                  toggleColor: Colors.deepOrangeAccent,
                  action: (controller) async {
                    controller.loading();
                    await Future.delayed(const Duration(seconds: 3));
                    try {
                      ref.watch(sendTxProvider.notifier).updateAmount(sendAmount.state);
                      await ref.watch(sendBitcoinTransactionProvider.future);
                      controller.success();
                      Fluttertoast.showToast(msg: "Transaction Sent", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
                      await Future.delayed(const Duration(seconds: 3));
                      Navigator.pushNamed(context, '/home');
                    } catch (e) {
                      controller.failure();
                      Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
                      controller.reset();
                    }
                  },
                  child: const Text('Slide to send'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}