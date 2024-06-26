import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/translations/translations.dart';
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
    return fiatInDenominationFormatted(ref.read(balanceNotifierProvider).brlBalance);
  } else {
    return ref.read(liquidBalanceInFormatProvider(btcFormat));
  }
});

final tickerProvider = StateProvider.autoDispose<AssetId>((ref) {
  final sendBitcoin = ref.read(sendBitcoinProvider);
  if (!sendBitcoin) {
    return AssetId.BRL;
  } else {
    return AssetId.LBTC;
  }
});

class LiquidSwapCards extends ConsumerStatefulWidget {
  const LiquidSwapCards({super.key});

  @override
  _LiquidSwapCardsState createState() => _LiquidSwapCardsState();

}

class _LiquidSwapCardsState extends ConsumerState<LiquidSwapCards> {

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dynamicCardHeight = MediaQuery.of(context).size.height * 0.21;
    final currentBalance = ref.watch(currentBalanceProvider);
    final dynamicFontSize = MediaQuery.of(context).size.height * 0.02;
    final sendBitcoin = ref.watch(sendBitcoinProvider);
    final titleFontSize = MediaQuery.of(context).size.height * 0.03;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final btcFormat = ref.read(settingsProvider).btcFormat;

    List<Column> cards = [
      buildCard('Depix', 'BRL', Color(0xFF009B3A), Color(0xFF009B3A), ref, context, false, AssetId.BRL),
      buildCard('USDt', 'USD',Color(0xFF008000),Color(0xFF008000), ref, context, false, AssetId.USD),
      buildCard('EURx', 'EUR', Color(0xFF003399), Color(0xFF003399), ref, context, false, AssetId.EUR),
    ];

    List<Widget> swapCards = [
      buildCard('Liquid Bitcoin', 'BTC', Colors.blueAccent, Colors.deepPurple, ref, context, true, AssetId.LBTC),
      GestureDetector(
        onTap: () {
          ref.read(sendBitcoinProvider.notifier).state = !sendBitcoin;
          ref.read(sendTxProvider.notifier).updateAddress('');
          ref.read(sendTxProvider.notifier).updateAmount(0);
          ref.read(sendBlocksProvider.notifier).state = 1;
          ref.refresh(currentBalanceProvider);
          ref.refresh(tickerProvider);
          ref.read(sendTxProvider.notifier).updateDrain(false);
          controller.text = '';
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Switch".i18n(ref), style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey)),
            Icon(EvaIcons.swap, size: titleFontSize, color: Colors.grey),
          ],
        ),
      ),
      SizedBox(
        height: dynamicCardHeight,
        child: CardSwiper(
          scale: 0,
          padding: const EdgeInsets.all(0),
          allowedSwipeDirection: const AllowedSwipeDirection.symmetric(vertical: true),
          cardsCount: cards.length,
          onSwipe: (int previousIndex, int? currentIndex, CardSwiperDirection direction) {
            AssetId ticker;
            switch (currentIndex) {
              case 0:
                ticker = AssetId.BRL;
                break;
              case 1:
                ticker = AssetId.USD;
                break;
              case 2:
                ticker = AssetId.EUR;
                break;
              default:
                ticker = AssetId.BRL;
                break;
            }
            setState(() {
              ref.read(tickerProvider.notifier).state = ticker;
            });

            if (!sendBitcoin) {
              switch (ticker) {
                case AssetId.BRL:
                  ref.read(currentBalanceProvider.notifier).state = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).brlBalance);
                  break;
                case AssetId.USD:
                  ref.read(currentBalanceProvider.notifier).state = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).usdBalance);
                  break;
                case AssetId.EUR:
                  ref.read(currentBalanceProvider.notifier).state = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).eurBalance);
                  break;
                default:
                  ref.read(currentBalanceProvider.notifier).state = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).brlBalance);
                  break;
              }
            } else {
              ref.read(currentBalanceProvider.notifier).state = ref.watch(liquidBalanceInFormatProvider(ref.read(settingsProvider).btcFormat));
            }

            ref.read(assetExchangeProvider.notifier).state = AssetMapper.reverseMapTicker(ticker);
            controller.text = '';
            ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(ticker));
            ref.read(sendTxProvider.notifier).updateAmount(0);
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
            Text(
              "Balance to Spend: ".i18n(ref),
              style: TextStyle(fontSize: dynamicFontSize, color: Colors.grey),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  currentBalance,
                  style: TextStyle(fontSize: titleFontSize, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                _buildMaxButton(ref, dynamicPadding, titleFontSize, btcFormat),
              ],
            ),
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

  Widget _buildMaxButton(WidgetRef ref, double dynamicPadding, double dynamicFontSize, String btcFormat) {
    final sendBitcoin = ref.watch(sendBitcoinProvider);
    final ticker = sendBitcoin ? AssetId.LBTC : ref.watch(tickerProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() {
              int balance;
              switch (ticker) {
                case AssetId.BRL:
                  balance = ref.read(balanceNotifierProvider).brlBalance;
                  controller.text = fiatInDenominationFormatted(balance);
                  ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(ticker));
                  ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
                  break;
                case AssetId.USD:
                  balance = ref.read(balanceNotifierProvider).usdBalance;
                  controller.text = fiatInDenominationFormatted(balance);
                  ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(ticker));
                  ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
                  break;
                case AssetId.EUR:
                  balance = ref.read(balanceNotifierProvider).eurBalance;
                  controller.text = fiatInDenominationFormatted(balance);
                  ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(ticker));
                  ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
                  break;
                case AssetId.LBTC:
                  balance = ref.read(balanceNotifierProvider).liquidBalance;
                  controller.text = btcInDenominationFormatted(balance.toDouble(), btcFormat);
                  ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(ticker));
                  ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
                  break;
                default:
                  balance = ref.read(balanceNotifierProvider).brlBalance;
                  controller.text = fiatInDenominationFormatted(balance);
                  ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(ticker));
                  ref.read(sendTxProvider.notifier).updateAmountFromInput(controller.text, btcFormat);
                  break;
              }
              ref.read(sendTxProvider.notifier).updateDrain(true);
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: dynamicPadding / 2, vertical: dynamicPadding / 2),
            child: Text(
              'Max',
              style: TextStyle(
                fontSize: dynamicFontSize / 2,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column buildCard(String title, String unit, Color color1, Color color2, WidgetRef ref, BuildContext context, bool isBitcoin, AssetId assetId) {
    final dynamicMargin = MediaQuery.of(context).size.width * 0.04;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final btcFormat = ref.read(settingsProvider).btcFormat;
    final sendBitcoin = ref.watch(sendBitcoinProvider);

    return Column(
      children: [
        if (!isBitcoin)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Icon(Icons.swipe_vertical, color: Colors.grey),
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
                padding: EdgeInsets.symmetric(vertical: dynamicPadding / 2),
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
                                return Text('Value to receive: ${btcInDenominationFormatted(valueToReceive.toDouble(), btcFormat, !sendBitcoin)}', style: const TextStyle(color: Colors.white), textAlign: TextAlign.center);
                              }
                            },
                            loading: () => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: LoadingAnimationWidget.prograssiveDots(size: 15, color: Colors.white)),
                            ),
                            error: (error, stack) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Error: $error', style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                            ),
                          );
                        },
                      )
                    else
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: controller,
                        inputFormatters: isBitcoin ? [DecimalTextInputFormatter(decimalRange: 8), CommaTextInputFormatter()] : [DecimalTextInputFormatter(decimalRange: 2), CommaTextInputFormatter()],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: isBitcoin ? '0' : '0.00',
                          hintStyle: const TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) async {
                          if (value.isEmpty) {
                            ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(assetId));
                            ref.read(sendTxProvider.notifier).updateAmountFromInput('0', btcFormat);
                            ref.read(sendTxProvider.notifier).updateDrain(false);
                          }
                          ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(assetId));
                          ref.read(sendTxProvider.notifier).updateAmountFromInput(value, btcFormat);
                          ref.read(sendTxProvider.notifier).updateDrain(false);
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
              Fluttertoast.showToast(msg: "Swap done! Check Analytics for more info".i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
              ref.read(sendTxProvider.notifier).updateAddress('');
              ref.read(sendTxProvider.notifier).updateAmount(0);
              ref.read(sendBlocksProvider.notifier).state = 1;
              ref.read(backgroundSyncNotifierProvider).performSync();
              await Future.delayed(const Duration(seconds: 3));
              Navigator.pushReplacementNamed(context, '/home');
            } catch (e) {
              controller.failure();
              Fluttertoast.showToast(msg: e.toString().i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
              controller.reset();
            }
          },
          child: Text('Exchange'.i18n(ref)),
        ),
      ),
    );
  }
}
