import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/screens/analytics/components/button_picker.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_keyboard_done/flutter_keyboard_done.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:Satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
    final dynamicSizedBox = MediaQuery.of(context).size.height * 0.01;

    List<Column> cards = [
      buildCard('Depix', 'BRL', const Color(0xFF009B3A), const Color(0xFF009B3A), ref, context, false, AssetId.BRL, titleFontSize),
      buildCard('USDt', 'USD',const Color(0xFF008000),const Color(0xFF008000), ref, context, false, AssetId.USD, titleFontSize),
      buildCard('EURx', 'EUR', const Color(0xFF003399), const Color(0xFF003399), ref, context, false, AssetId.EUR, titleFontSize),
    ];

    List<Widget> swapCards = [
      Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ref.read(sendBitcoinProvider)
                ? [
              buildCard('Liquid Bitcoin', 'BTC', Colors.blueAccent, Colors.deepPurple, ref, context, true, AssetId.LBTC, titleFontSize),
              SizedBox(height: dynamicSizedBox),
              buildCardSwiper(context, ref, dynamicCardHeight, cards),
            ]
                : [
              buildCardSwiper(context, ref, dynamicCardHeight, cards),
              SizedBox(height: dynamicSizedBox),
              buildCard('Liquid Bitcoin', 'BTC', Colors.blueAccent, Colors.deepPurple, ref, context, true, AssetId.LBTC, titleFontSize),
            ],
          ),
          buildSwapGestureDetector(context, ref, titleFontSize),
        ],
      ),
    ];

    if (!sendBitcoin) {
      swapCards = swapCards.reversed.toList();
    }

    return SafeArea(
      child: FlutterKeyboardDoneWidget(
              doneWidgetBuilder: (context) {
                return const Text(
                  'Done',
                );
              },
          child: Column(
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
                  _buildMaxButton(ref, dynamicPadding, titleFontSize, btcFormat, titleFontSize),
                ],
              ),
              SizedBox(height: dynamicPadding),
              ...swapCards,
              const Spacer(),
              _liquidSlideToSend(ref, dynamicFontSize, titleFontSize, context),
            ],
          ),
        ),
    );
  }

  Widget buildCardSwiper(BuildContext context, WidgetRef ref, double dynamicCardHeight, List<Column> cards) {
    return SizedBox(
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
          ref.read(tickerProvider.notifier).state = ticker;

          if (!ref.read(sendBitcoinProvider)) {
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
          return Align(
            alignment: Alignment.center,
            child: cards[index],
          );
        },
      ),
    );
  }

  Widget buildSwapGestureDetector(BuildContext context, WidgetRef ref, double titleFontSize) {
    return Positioned(
      top: titleFontSize / 1,
      bottom: titleFontSize / 1,
      child: GestureDetector(
        onTap: () {
          ref.read(sendBitcoinProvider.notifier).state = !ref.read(sendBitcoinProvider);
          ref.read(sendTxProvider.notifier).updateAddress('');
          ref.read(sendTxProvider.notifier).updateAmount(0);
          ref.read(sendBlocksProvider.notifier).state = 1;
          ref.refresh(currentBalanceProvider);
          ref.refresh(tickerProvider);
          ref.read(sendTxProvider.notifier).updateDrain(false);
          controller.text = '';
        },
        child: CircleAvatar(
          radius: titleFontSize,
          backgroundColor: Colors.orange,
          child: Icon(EvaIcons.swap, size: titleFontSize, color: Colors.black),
        ),
      ),
    );
  }


  Widget _buildMaxButton(WidgetRef ref, double dynamicPadding, double dynamicFontSize, String btcFormat, titleFontSize) {
    final sendBitcoin = ref.watch(sendBitcoinProvider);
    final ticker = sendBitcoin ? AssetId.LBTC : ref.watch(tickerProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white, // Applied the same background color
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
            padding: EdgeInsets.symmetric(horizontal: dynamicPadding / 1, vertical: dynamicPadding / 2.5), // Adjusted padding to match the other button
            child: Text(
              'Max',
              style: TextStyle(
                fontSize: titleFontSize / 2,
                color: Colors.black, // Applied the same text color
              ),
            ),
          ),
        ),
      ),
    );
  }


  Column buildCard(String title, String unit, Color color1, Color color2, WidgetRef ref, BuildContext context, bool isBitcoin, AssetId assetId, titleFontSize) {
    final btcFormat = ref.read(settingsProvider).btcFormat;
    final sendBitcoin = ref.watch(sendBitcoinProvider);
    final currency = ref.read(settingsProvider).currency;
    final currencyRate = ref.read(selectedCurrencyProvider(currency));
    final valueToSendInCurrency = ref.watch(sendTxProvider).amount / 100000000 * currencyRate;

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.2,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.grey, width: 1),
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isBitcoin)
                const Icon(Icons.swipe_vertical, color: Colors.grey),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center), // Matching text style
              if (sendBitcoin && !isBitcoin || !sendBitcoin && isBitcoin)
                Consumer(
                  builder: (context, watch, child) {
                    final sideswapPriceStreamAsyncValue = ref.watch(sideswapPriceStreamProvider);
                    return sideswapPriceStreamAsyncValue.when(
                      data: (value) {
                        if (value.errorMsg != null) {
                          return Text(value.errorMsg!, style: TextStyle(color: Colors.orange, fontSize: titleFontSize), textAlign: TextAlign.center);
                        } else {
                          final valueToReceive = value.recvAmount!;
                          return Text(btcInDenominationFormatted(valueToReceive.toDouble(), btcFormat, !sendBitcoin), style: TextStyle(color: Colors.white, fontSize: titleFontSize), textAlign: TextAlign.center);
                        }
                      },
                      loading: () => controller.text.isEmpty ?Text("0", style: TextStyle(color: Colors.white, fontSize: titleFontSize), textAlign: TextAlign.center) : Center(child: LoadingAnimationWidget.prograssiveDots(size: titleFontSize, color: Colors.white)),
                      error: (error, stack) => Text('Error: $error', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: titleFontSize)),
                    );
                  },
                )
              else
                Column(
                  children: [
                    TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      controller: controller,
                      inputFormatters: isBitcoin ? [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 8)] : [CommaTextInputFormatter(), DecimalTextInputFormatter(decimalRange: 2)],
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: isBitcoin ? '0' : '0.00',
                        hintStyle: TextStyle(color: Colors.white, fontSize: titleFontSize, fontWeight: FontWeight.bold),
                      ),
                      style: TextStyle(color: Colors.white, fontSize: titleFontSize, fontWeight: FontWeight.bold),
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
                    Text(
                      controller.text.isEmpty || !isBitcoin ? '' : '${valueToSendInCurrency.toStringAsFixed(2)} $currency',
                      style: TextStyle(fontSize: titleFontSize / 2, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _liquidSlideToSend(WidgetRef ref, double dynamicPadding, double titleFontSize, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: dynamicPadding / 2),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ActionSlider.standard(
          sliderBehavior: SliderBehavior.stretch,
          width: double.infinity,
          backgroundColor: Colors.black,
          toggleColor: Colors.orange,
          action: (controller) async {
            controller.loading();
            try {
              await ref.read(sideswapUploadAndSignInputsProvider.future).then((value) => value);
              ref.read(sendTxProvider.notifier).updateAddress('');
              ref.read(sendTxProvider.notifier).updateAmount(0);
              ref.read(sendBlocksProvider.notifier).state = 1;
              controller.success();
              Fluttertoast.showToast(msg: "Swap done!".i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 16.0);
              Future.microtask(() {
              ref.read(topSelectedButtonProvider.notifier).state = "Swap";
              ref.read(groupButtonControllerProvider).selectIndex(2);
              ref.read(navigationProvider.notifier).state = 1;
             });
              Navigator.pushReplacementNamed(context, '/home');
              await ref.read(backgroundSyncNotifierProvider).performSync();
            } catch (e) {
              controller.failure();
              Fluttertoast.showToast(msg: e.toString().i18n(ref), toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
              controller.reset();
            }
          },
          child: Text('Slide to Swap'.i18n(ref), style: TextStyle(fontSize: titleFontSize / 2, color: Colors.white)),
        ),
      ),
    );
  }
}
