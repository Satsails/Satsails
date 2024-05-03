import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:satsails/helpers/asset_mapper.dart';
import 'package:satsails/helpers/input_formatters/comma_text_input_formatter.dart';
import 'package:satsails/helpers/input_formatters/decimal_text_input_formatter.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/send_tx_provider.dart';
import 'package:satsails/providers/settings_provider.dart';
import 'package:satsails/providers/sideswap_provider.dart';

final currentBalanceProvider = StateProvider.autoDispose<String>((ref){
  final btcFormart = ref.read(settingsProvider).btcFormat;
  return ref.read(liquidBalanceInFormatProvider(btcFormart));
});

class LiquidSwapCards extends ConsumerWidget {
  final controller = TextEditingController();
  LiquidSwapCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicCardHeight = MediaQuery.of(context).size.height * 0.21;
    final currentBalance = ref.watch(currentBalanceProvider);
    final dynamicFontSize = MediaQuery.of(context).size.height * 0.02;
    final sendBitcoin = ref.watch(sendBitcoinProvider);
    final titleFontSize = MediaQuery.of(context).size.height * 0.03;

    List<Column> cards = [
      buildCard('Real', 'BRL', Colors.greenAccent, Colors.green, ref, context),
      buildCard('Dollar', 'USD', Colors.greenAccent, Color.fromARGB(255, 0, 128, 0), ref, context),
      buildCard('Euro', 'EUR', Colors.lightBlueAccent, Colors.cyan, ref, context),
    ];


    bool onSwipe(
        int previousIndex,
        int? currentIndex,
        CardSwiperDirection direction,
        ) {
      AssetId ticker;
      final btcFormart = ref.read(settingsProvider).btcFormat;
      switch (currentIndex) {
        case 0:
          ticker = AssetId.LBTC;
          ref.read(currentBalanceProvider.notifier).state = ref.watch(liquidBalanceInFormatProvider(btcFormart));
          break;
        case 1:
          ticker = AssetId.BRL;
          ref.read(currentBalanceProvider.notifier).state = ref.watch(balanceNotifierProvider).brlBalance.toStringAsFixed(2);
          break;
        case 2:
          ticker = AssetId.USD;
          ref.read(currentBalanceProvider.notifier).state = ref.watch(balanceNotifierProvider).usdBalance.toStringAsFixed(2);
          break;
        case 3:
          ticker = AssetId.EUR;
          ref.read(currentBalanceProvider.notifier).state = ref.watch(balanceNotifierProvider).eurBalance.toStringAsFixed(2);
          break;
        default:
          ticker = AssetId.LBTC;
          ref.read(currentBalanceProvider.notifier).state = ref.watch(liquidBalanceInFormatProvider(btcFormart));
      }
      String assetId = AssetMapper.reverseMapTicker(ticker);
      ref.read(sendTxProvider.notifier).updateAssetId(assetId);
      ref.read(sendTxProvider.notifier).updateAmount(0);
      controller.text = '';
      return true;
    }

    return Column(
      children: [
        Text("Balance to spend: ${currentBalance}", style: TextStyle(fontSize: dynamicFontSize, color: Colors.grey),),
        buildCard('Liquid Bitcoin', 'BTC', Colors.blueAccent, Colors.deepPurple, ref, context),
        GestureDetector(
          onTap: () {
            ref.read(sendBitcoinProvider.notifier).state = !sendBitcoin;
            ref.read(sendTxProvider.notifier).updateAddress('');
            ref.read(sendTxProvider.notifier).updateAmount(0);
            ref.read(sendBlocksProvider.notifier).state = 1;
          },              child: Column(
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
            scale: 0.1,
            padding: const EdgeInsets.all(0),
            allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true),
            cardsCount: cards.length,
            onSwipe: onSwipe,
            cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
              return cards[index];
            },
          ),
        ),
      ],
    );
  }

  Column buildCard(String title, String unit, Color color1, Color color2, WidgetRef ref, BuildContext context) {
    final dynamicMargin = MediaQuery.of(context).size.width * 0.04;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final showBitcoinRelatedWidgets = ref.watch(showBitcoinRelatedWidgetsProvider.notifier);
    final btcFormart = ref.read(settingsProvider).btcFormat;

    return Column(
      children: [
        const Icon(Icons.swipe, color: Colors.grey),
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
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: showBitcoinRelatedWidgets.state ? [DecimalTextInputFormatter(decimalRange: 8), CommaTextInputFormatter()] : [DecimalTextInputFormatter(decimalRange: 2), CommaTextInputFormatter()],
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: showBitcoinRelatedWidgets.state ? '0' : '0.00',
                        hintStyle: TextStyle(color: Colors.white),
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
}