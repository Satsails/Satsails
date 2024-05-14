import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';

final currentBalanceProvider = StateProvider.autoDispose<String>((ref) {
  final btcFormat = ref.read(settingsProvider).btcFormat;
  final sendBitcoin = ref.read(sendBitcoinProvider);
  if (!sendBitcoin) {
    return ref.read(balanceNotifierProvider).brlBalance.toStringAsFixed(2);
  } else {
    return ref.read(liquidBalanceInFormatProvider(btcFormat));
  }
});

class LiquidSwapCards extends ConsumerWidget {
  LiquidSwapCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicCardHeight = MediaQuery.of(context).size.height * 0.21;
    final currentBalance = ref.watch(currentBalanceProvider);
    final dynamicFontSize = MediaQuery.of(context).size.height * 0.02;
    final sendBitcoin = ref.watch(sendBitcoinProvider);
    final titleFontSize = MediaQuery.of(context).size.height * 0.03;


    List<Column> cards = [
      buildCard('Real', 'BRL', Colors.greenAccent, Colors.green, ref, context, false),
      buildCard('Dollar', 'USD', Colors.greenAccent, const Color.fromARGB(255, 0, 128, 0), ref, context, false),
      buildCard('Euro', 'EUR', Colors.lightBlueAccent, Colors.cyan, ref, context, false),
    ];

    List<Widget> swapCards = [
      buildCard('Liquid Bitcoin', 'BTC', Colors.blueAccent, Colors.deepPurple, ref, context, true),
      GestureDetector(
        onTap: () {
          ref.read(sendBitcoinProvider.notifier).state = !sendBitcoin;
          ref.read(sendTxProvider.notifier).updateAddress('');
          ref.read(sendTxProvider.notifier).updateAmount(0);
          ref.read(sendBlocksProvider.notifier).state = 1;
          ref.refresh(currentBalanceProvider);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Switch", style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey)),
            Icon(EvaIcons.swap, size: titleFontSize, color: Colors.grey),
          ],
        ),
      ),
      SizedBox(
        height: dynamicCardHeight,
        child: CardSwiper(
          scale: 0,
          padding: const EdgeInsets.all(0),
          allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true),
          cardsCount: cards.length,
          onSwipe: (int previousIndex, int? currentIndex, CardSwiperDirection direction) {
            AssetId ticker;
            switch (currentIndex) {
              case 0:
                ticker = AssetId.BRL;
                if (!sendBitcoin) {
                  ref.read(currentBalanceProvider.notifier).state = ref.watch(balanceNotifierProvider).brlBalance.toStringAsFixed(2);
                } else {
                  ref.read(currentBalanceProvider.notifier).state = ref.watch(liquidBalanceInFormatProvider(ref.read(settingsProvider).btcFormat));
                }
                ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(ticker);
                break;
              case 1:
                ticker = AssetId.USD;
                if (!sendBitcoin) {
                  ref.read(currentBalanceProvider.notifier).state = ref.watch(balanceNotifierProvider).usdBalance.toStringAsFixed(2);
                } else {
                  ref.read(currentBalanceProvider.notifier).state = ref.watch(liquidBalanceInFormatProvider(ref.read(settingsProvider).btcFormat));
                }
                ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(ticker);
              case 2:
                ticker = AssetId.EUR;
                if (!sendBitcoin) {
                  ref.read(currentBalanceProvider.notifier).state = ref.watch(balanceNotifierProvider).eurBalance.toStringAsFixed(2);
                } else {
                  ref.read(currentBalanceProvider.notifier).state = ref.watch(liquidBalanceInFormatProvider(ref.read(settingsProvider).btcFormat));
                }
                ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(ticker);
              default:
                ticker = AssetId.BRL;
                if (!sendBitcoin) {
                  ref.read(currentBalanceProvider.notifier).state = ref.watch(balanceNotifierProvider).brlBalance.toStringAsFixed(2);
                } else {
                  ref.read(currentBalanceProvider.notifier).state = ref.watch(liquidBalanceInFormatProvider(ref.read(settingsProvider).btcFormat));
                }
                ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(ticker);
                break;
            }

            String assetId = AssetMapper.reverseMapTicker(ticker);
            ref.read(sendTxProvider.notifier).updateAssetId(assetId);
            return true;
          },
          cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
            return cards[index];
          },
        ),
      ),
    ];

    if (!sendBitcoin) {
      swapCards = swapCards.reversed.toList();
    }

    return Stack(
      children: [
        Column(
          children: [
            Text("Balance to spend: ${currentBalance}", style: TextStyle(fontSize: dynamicFontSize, color: Colors.grey),),
            ...swapCards,
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _liquidSlideToSend(ref, dynamicFontSize, titleFontSize, context),
        ),
      ],
    );
  }

  Column buildCard(String title, String unit, Color color1, Color color2, WidgetRef ref, BuildContext context, bool isBitcoin) {
    final dynamicMargin = MediaQuery.of(context).size.width * 0.04;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final btcFormart = ref.read(settingsProvider).btcFormat;
    final sendBitcoin = ref.watch(sendBitcoinProvider);

    return Column(
      children: [
        if (!isBitcoin) const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Icon(Icons.swipe, color: Colors.grey),
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
                gradient: LinearGradient(
                  colors: [color1, color2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: dynamicPadding /2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
                    if (sendBitcoin && !isBitcoin || !sendBitcoin && isBitcoin)
                      Consumer(
                          builder: (context, watch, child) {
                            final sideswapPriceStreamAsyncValue = ref.watch(sideswapPriceStreamProvider);
                            return sideswapPriceStreamAsyncValue.when(
                              data: (value) {
                                if (value.errorMsg != null) {
                                  return Text(value.errorMsg!, style: const TextStyle(color: Colors.orange), textAlign: TextAlign.center);
                                } else {
                                  final valueToReceive = value.recvAmount!;
                                  return Text('Value to receive: ${btcInDenominationFormatted(valueToReceive.toDouble(), btcFormart, !sendBitcoin)}', style: const TextStyle( color: Colors.white), textAlign: TextAlign.center);
                                }
                              },
                              loading: () => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(child: LoadingAnimationWidget.prograssiveDots(size: 15, color: Colors.white)),
                              ),
                              error: (error, stack) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Error: $error', style: const TextStyle( color: Colors.white), textAlign: TextAlign.center),
                              ),
                            );
                          }
                      )
                    else
                      TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: isBitcoin? [DecimalTextInputFormatter(decimalRange: 8), CommaTextInputFormatter()] : [DecimalTextInputFormatter(decimalRange: 2), CommaTextInputFormatter()],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: isBitcoin ? '0' : '0.00',
                          hintStyle: const TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) async {
                          if (value.isEmpty) {
                            ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormart);
                          }
                          ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormart);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _liquidSlideToSend(WidgetRef ref, double dynamicPadding, double titleFontSize, BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ActionSlider.standard(
          sliderBehavior: SliderBehavior.stretch,
          width: double.infinity,
          backgroundColor: Colors.white,
          toggleColor: Colors.blueAccent,
          action: (controller) async {
            controller.loading();
            await Future.delayed(const Duration(seconds: 3));
            try {
              await ref.read(sideswapUploadAndSignInputsProvider.future).then((value) => value);
              controller.success();
              Fluttertoast.showToast(msg: "Swap done! Check Analytics for more info", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
              ref.read(sendTxProvider.notifier).updateAddress('');
              ref.read(sendTxProvider.notifier).updateAmount(0);
              ref.read(sendBlocksProvider.notifier).state = 1;
              await Future.delayed(const Duration(seconds: 3));
              Navigator.pushReplacementNamed(context, '/home');
            } catch (e) {
              controller.failure();
              Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
              controller.reset();
            }
          },
          child: const Text('Exchange'),
        ),
      ),
    );
  }
}
