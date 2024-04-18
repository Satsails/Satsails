import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:satsails/models/bitcoin_model.dart';
import 'package:satsails/providers/bitcoin_provider.dart';
import 'package:satsails/providers/send_tx_provider.dart';
import 'package:satsails/providers/settings_provider.dart';
import '../../../providers/balance_provider.dart';
import 'package:action_slider/action_slider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:interactive_slider/interactive_slider.dart';

final inputValueProvider = StateProvider<String>((ref) {
  final sendTxState = ref.watch(sendTxProvider);
  if (sendTxState.amount != 0) {
    return (sendTxState.amount / 100000000).toStringAsFixed(8);
  }else {
    return '';
  }
});

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
    final selectedCurrency = ref.watch(sendCurrencyProvider);

    useEffect(() {
      Future.microtask(() => controller.text = ref.watch(inputValueProvider));
    }, [selectedCurrency]);

    final dynamicFontSize = MediaQuery.of(context).size.height * 0.02;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final dynamicMargin = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                padding: const EdgeInsets.all(8.0),
                child: FocusScope(
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      CurrencyTextInputFormatter.currency(
                        decimalDigits: 8,
                        symbol: '',
                      ),
                    ],
                    style: TextStyle(fontSize: dynamicFontSize * 3),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0.00000000',
                    ),
                    enabled: sendTxState.amount == 0,
                    onChanged: (value) {
                      ref.read(sendTxProvider.notifier).updateAmount(int.parse(value));
                    },
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // show error if amount is greater than balance or if amount is 0 or if amount to send is < than dust limit
              // max only shows discounted with fee
              // calculate the actual fee on the bottom
              // must show usd value of the amount to send and fee
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
                    onTap: () {
                      controller.text = ref.watch(btcBalanceInFormatProvider('BTC'));
                      ref.read(sendTxProvider.notifier).updateAmount(int.parse(controller.text));
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: dynamicPadding, vertical: dynamicPadding / 2),
                      child: Text(
                        'Max',
                        style: TextStyle(
                          fontSize: dynamicFontSize, // font size
                          fontWeight: FontWeight.bold, // font weight
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: dynamicFontSize * 3),
              InteractiveSlider(
                centerIcon: Icon(Clarity.block_solid, color: Colors.black),
                foregroundColor: Colors.deepOrange,
                unfocusedHeight: dynamicFontSize * 2,
                focusedHeight: dynamicFontSize * 2,
                initialProgress: 15,
                min: 15.0,
                max: 1.0,
                onChanged: (dynamic value){
                  ref.read(sendBlocksProvider.notifier).state = value;
                  ref.refresh(getCustomFeeRateProvider);
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
              SizedBox(height: dynamicFontSize * 2),
              ref.watch(getCustomFeeRateProvider).when(
                data: (FeeRate feeRate) {
                  return Column(
                    children: [
                      Padding(
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
                                '${feeRate.asSatPerVb().toStringAsFixed(0)} sats/vbyte',
                                style: TextStyle(fontSize: dynamicFontSize, fontWeight: FontWeight.bold, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LoadingAnimationWidget.prograssiveDots(size: dynamicFontSize, color: Colors.black),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () { ref.refresh(getCustomFeeRateProvider); },
                    child: const Text('Retry', style: TextStyle(color: Colors.red)),
                  ),
                ),
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
                    final transaction = TransactionBuilder(
                      sendTxState.amount,
                      sendTxState.address,
                      await ref.watch(getCustomFeeRateProvider.future).then((value) => value),
                    );
                    try {
                      final result = await ref.watch(buildBitcoinTransactionProvider(transaction).future);
                      final signedPsbt = await ref.watch(signBitcoinPsbtProvider(transaction).future);
                      // await ref.watch(broadcastBitcoinTransactionProvider(signedPsbt).future);
                    } catch (e) {
                      controller.failure();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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