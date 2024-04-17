import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:satsails/providers/bitcoin_provider.dart';
import 'package:satsails/providers/send_tx_provider.dart';
import 'package:satsails/providers/settings_provider.dart';
import '../../../providers/balance_provider.dart';
import 'package:action_slider/action_slider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class TextEditingControllerNotifier extends StateNotifier<TextEditingController> {
  TextEditingControllerNotifier() : super(TextEditingController());
}

final textEditingControllerProvider = StateNotifierProvider<TextEditingControllerNotifier, TextEditingController>((ref) {
  return TextEditingControllerNotifier();
});

class ConfirmBitcoinPayment extends ConsumerWidget {
  ConfirmBitcoinPayment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(textEditingControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardMargin = screenWidth * 0.05;
    final cardPadding = screenWidth * 0.04;
    final titleFontSize = screenHeight * 0.03;
    final sendTxState = ref.watch(sendTxProvider);
    final initializeBalance = ref.watch(initializeBalanceProvider);
    final settingsValue = ref.watch(settingsProvider).btcFormat;
    final btcBalanceInFormat = ref.watch(btcBalanceInFormatProvider(settingsValue));
    controller.text = sendTxState.amount.toString();


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
                  margin: EdgeInsets.all(cardMargin),
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
                      padding: EdgeInsets.symmetric(vertical: cardPadding, horizontal: cardPadding / 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Bitcoin Balance', style: TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
                          initializeBalance.when(
                              data: (_) => SizedBox(height: titleFontSize * 1.5, child: Text('$btcBalanceInFormat $settingsValue', style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center)),
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
                    style: const TextStyle(fontSize: 60),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
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
                      controller.text = ref.watch(balanceNotifierProvider).btcBalance.toString();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Text(
                        'Max',
                        style: TextStyle(
                          fontSize: 20, // font size
                          fontWeight: FontWeight.bold, // font weight
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 60),
              SfSlider(
                min: 1,
                max: 10,
                interval: 1,
                value: ref.watch(sendBlocksProvider),
                stepSize: 1,
                showTicks: true,
                showLabels: true,
                activeColor: Colors.deepOrange,
                inactiveColor: Colors.orange[200],
                labelPlacement: LabelPlacement.onTicks,
                onChanged: (dynamic value){
                  ref.read(sendBlocksProvider.notifier).state = value;
                  ref.refresh(getCustomFeeRateProvider);
                },
              ),
              SizedBox(height: 60),
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
                              gradient: LinearGradient(
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
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
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
                  child: LoadingAnimationWidget.prograssiveDots(size: 20, color: Colors.black),
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
              child: ActionSlider.standard(
                sliderBehavior: SliderBehavior.stretch,
                width: double.infinity,
                backgroundColor: Colors.white,
                toggleColor: Colors.deepOrangeAccent,
                action: (controller) async {
                  controller.loading();
                  await Future.delayed(const Duration(seconds: 3));
                  controller.success();
                  await Future.delayed(const Duration(seconds: 1));
                  controller.reset();
                },
                child: const Text('Slide to confirm'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}