import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:satsails/helpers/asset_mapper.dart';
import 'package:satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:satsails/providers/liquid_provider.dart';
import 'package:satsails/providers/send_tx_provider.dart';
import 'package:satsails/providers/settings_provider.dart';
import '../../../providers/balance_provider.dart';
import 'package:action_slider/action_slider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:interactive_slider/interactive_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';


class ConfirmLiquidPayment extends HookConsumerWidget {
  ConfirmLiquidPayment({super.key});
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleFontSize = MediaQuery.of(context).size.height * 0.03;
    final sendTxState = ref.watch(sendTxProvider);
    final initializeBalance = ref.watch(initializeBalanceProvider);
    final liquidFormart = ref.watch(settingsProvider).btcFormat;
    final liquidBalanceInFormat = ref.watch(liquidBalanceInFormatProvider(liquidFormart));
    final balance = ref.watch(balanceNotifierProvider);
    final dynamicFontSize = MediaQuery.of(context).size.height * 0.02;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final dynamicMargin = MediaQuery.of(context).size.width * 0.04;
    final dynamicSizedBox = MediaQuery.of(context).size.height * 0.01;
    final dynamicCardHeight = MediaQuery.of(context).size.height * 0.21;
    final showBitcoinRelatedWidgets = ref.watch(showBitcoinRelatedWidgetsProvider.notifier);
    final btcFormart = ref.watch(settingsProvider).btcFormat;
    final sendAmount = ref.watch(sendTxProvider).btcBalanceInDenominationFormatted(btcFormart);

    List<SizedBox> cards = [
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
                colors: [Colors.blueAccent, Colors.deepPurple],
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
                  const Text('Liquid Balance', style: TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
                  initializeBalance.when(
                      data: (_) => SizedBox(height: titleFontSize * 1.5, child: Text('$liquidBalanceInFormat $liquidFormart', style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center)),
                      loading: () => SizedBox(height: titleFontSize * 1.5, child: LoadingAnimationWidget.prograssiveDots(size: titleFontSize, color: Colors.white)),
                      error: (error, stack) => SizedBox(height: titleFontSize * 1.5, child: TextButton(onPressed: () { ref.refresh(initializeBalanceProvider); }, child: Text('Retry', style: TextStyle(color: Colors.white, fontSize: titleFontSize))))
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
                colors: [Colors.greenAccent, Colors.green],
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
                  const Text('Reais Balance', style: TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
                  initializeBalance.when(
                      data: (_) => SizedBox(height: titleFontSize * 1.5, child: Text(balance.brlBalance.toStringAsFixed(2) + ' BRL', style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center)),
                      loading: () => SizedBox(height: titleFontSize * 1.5, child: LoadingAnimationWidget.prograssiveDots(size: titleFontSize, color: Colors.white)),
                      error: (error, stack) => SizedBox(height: titleFontSize * 1.5, child: TextButton(onPressed: () { ref.refresh(initializeBalanceProvider); }, child: Text('Retry', style: TextStyle(color: Colors.white, fontSize: titleFontSize))))
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
                colors: [Colors.greenAccent,Color.fromARGB(255, 0, 128, 0)],
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
                  const Text('Dollar Balance', style: TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
                  initializeBalance.when(
                      data: (_) => SizedBox(height: titleFontSize * 1.5, child: Text(balance.usdBalance.toStringAsFixed(2) + ' USD', style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center)),
                      loading: () => SizedBox(height: titleFontSize * 1.5, child: LoadingAnimationWidget.prograssiveDots(size: titleFontSize, color: Colors.white)),
                      error: (error, stack) => SizedBox(height: titleFontSize * 1.5, child: TextButton(onPressed: () { ref.refresh(initializeBalanceProvider); }, child: Text('Retry', style: TextStyle(color: Colors.white, fontSize: titleFontSize))))
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
                colors: [Colors.lightBlueAccent, Colors.cyan],
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
                  const Text('Euro Balance', style: TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
                  initializeBalance.when(
                      data: (_) => SizedBox(height: titleFontSize * 1.5, child: Text(balance.eurBalance.toStringAsFixed(2) + ' EUR', style: TextStyle(fontSize: titleFontSize, color: Colors.white), textAlign: TextAlign.center)),
                      loading: () => SizedBox(height: titleFontSize * 1.5, child: LoadingAnimationWidget.prograssiveDots(size: titleFontSize, color: Colors.white)),
                      error: (error, stack) => SizedBox(height: titleFontSize * 1.5, child: TextButton(onPressed: () { ref.refresh(initializeBalanceProvider); }, child: Text('Retry', style: TextStyle(color: Colors.white, fontSize: titleFontSize))))
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ];

    bool _onSwipe(
        int previousIndex,
        int? currentIndex,
        CardSwiperDirection direction,
        ) {
      AssetId ticker;
      switch (currentIndex) {
        case 0:
          ticker = AssetId.LBTC;
          break;
        case 1:
          ticker = AssetId.BRL;
          break;
        case 2:
          ticker = AssetId.USD;
          break;
        case 3:
          ticker = AssetId.EUR;
          break;
        default:
          ticker = AssetId.LBTC;
      }
      String assetId = AssetMapper.reverseMapTicker(ticker);
      ref.read(sendTxProvider.notifier).updateAssetId(assetId);
      ref.read(sendTxProvider.notifier).updateAmount(0);
      controller.text = '';
      return true;
    }

    useEffect(() {
      controller.text = sendAmount == 0 ? '' : sendAmount.toString();
    }, [showBitcoinRelatedWidgets.state]);

    return PopScope(
      onPopInvoked:(pop) async {
        ref.read(sendTxProvider.notifier).resetToDefault();
        ref.read(sendBlocksProvider.notifier).state = 1;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Confirm Payment'),
        ),
        body:Stack(
          children: [
            Column(
              children: [
                const Icon(Icons.swipe, color: Colors.grey),
                SizedBox(
                  height: dynamicCardHeight,
                  child: CardSwiper(
                    scale: 0.1,
                    padding: const EdgeInsets.all(0),
                    allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true),
                    cardsCount: cards.length,
                    initialIndex: ref.watch(currentCardIndexProvider),
                    onSwipe: _onSwipe,
                    cardBuilder: (context, index, percentThresholdX, percentThresholdY) { return cards[index]; },
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
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
                      inputFormatters: showBitcoinRelatedWidgets.state ? [DecimalTextInputFormatter(decimalRange: 8), CommaTextInputFormatter()] : [DecimalTextInputFormatter(decimalRange: 2), CommaTextInputFormatter()],
                      style: TextStyle(fontSize: dynamicFontSize * 3),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: showBitcoinRelatedWidgets.state ? '0' : '0.00',
                      ),
                      onChanged: (value) async {
                        if (value.isEmpty) {
                          ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormart);
                        }
                        ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormart);
                      },
                    ),
                  ),
                ),
                SizedBox(height: dynamicSizedBox),
                if(showBitcoinRelatedWidgets.state)
                  Text(
                    '~ ${ref.watch(bitcoinValueInCurrencyProvider).toStringAsFixed(2)} ${ref.watch(settingsProvider).currency}',
                    style: TextStyle(
                      fontSize: dynamicFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: dynamicSizedBox),
                // commented until there is a drain wallet method
                // Container(
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(10),
                //     gradient: const LinearGradient(
                //       colors: [Colors.blueAccent, Colors.deepPurple],
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //     ),
                //   ),
                //   child: Material(
                //     color: Colors.transparent,
                //     child: InkWell(
                //       borderRadius: BorderRadius.circular(10),
                //       onTap: () async {
                //         final assetId = ref.watch(sendTxProvider).assetId;
                //         try{
                //         if (assetId == '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d') {
                //           final pset = await ref.watch(liquidDrainWalletProvider.future);
                //           final sendingBalance = pset.balances[0];
                //           final controllerValue = (sendingBalance.value / 100000000).abs();
                //           controller.text = controllerValue.toStringAsFixed(8);
                //           ref.read(sendAmountProvider.notifier).state = (sendingBalance.value.abs());
                //         } else {
                //           await ref.watch(liquidDrainWalletProvider.future);
                //           final sendingBalance = ref.watch(assetBalanceProvider);
                //           controller.text = sendingBalance.toStringAsFixed(2);
                //           ref.read(sendAmountProvider.notifier).state = (sendingBalance);
                //         }}catch(e) {
                //           Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
                //         }
                //       },
                //       child: Padding(
                //         padding: EdgeInsets.symmetric(horizontal: dynamicPadding, vertical: dynamicPadding / 2),
                //         child: Text(
                //           'Max',
                //           style: TextStyle(
                //             fontSize: dynamicFontSize,
                //             fontWeight: FontWeight.bold,
                //             color: Colors.white,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(height: dynamicSizedBox),
                InteractiveSlider(
                  centerIcon: const Icon(Clarity.block_solid, color: Colors.black),
                  foregroundColor: Colors.blueAccent,
                  unfocusedHeight: dynamicFontSize * 2,
                  focusedHeight: dynamicFontSize * 2,
                  initialProgress: 15,
                  min: 25.0,
                  max: 1.0,
                  onChanged: (dynamic value){
                    ref.read(sendBlocksProvider.notifier).state = value;
                  },
                ),
                ref.watch(liquidFeeProvider).when(
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
                              colors: [Colors.blueAccent, Colors.deepPurple],
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
                    child:  TextButton(onPressed: () { ref.refresh(feeProvider); }, child: Text(sendTxState.amount == 0 ? '' : error.toString(), style: TextStyle(color: Colors.black, fontSize: dynamicFontSize))),
                  ),
                ),
                SizedBox(height: dynamicSizedBox),
                ref.watch(liquidFeeValueInCurrencyProvider).when(
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
                    error: (error, stack) => const Text('')
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
                    toggleColor: Colors.blueAccent,
                    action: (controller) async {
                      controller.loading();
                      await Future.delayed(const Duration(seconds: 3));
                      try {
                        await ref.watch(sendLiquidTransactionProvider.future);
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
      ),
    );
  }
}

