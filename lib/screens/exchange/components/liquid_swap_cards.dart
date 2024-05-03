import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/helpers/asset_mapper.dart';
import 'package:satsails/providers/send_tx_provider.dart';
import 'package:satsails/providers/settings_provider.dart';

class LiquidSwapCards extends ConsumerWidget {
  final controller = TextEditingController();
  LiquidSwapCards({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicCardHeight = MediaQuery.of(context).size.height * 0.21;
    final liquidFormart = ref.read(settingsProvider).btcFormat;

    List<Column> cards = [
      buildCard('Bitcoin', 'BTC', Colors.orange, Colors.orangeAccent, ref, context),
      buildCard('Real', 'BRL', Colors.green, Colors.greenAccent, ref, context),
      buildCard('Dollar', 'USD', Colors.blue, Colors.blueAccent, ref, context),
      buildCard('Euro', 'EUR', Colors.purple, Colors.purpleAccent, ref, context),
    ];


    bool onSwipe(
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

    return SizedBox(
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
    );
  }

  Column buildCard(String title, String unit, Color color1, Color color2, WidgetRef ref, BuildContext context) {
    final dynamicMargin = MediaQuery.of(context).size.width * 0.04;
    final dynamicPadding = MediaQuery.of(context).size.width * 0.05;
    final dynamicFontSize = MediaQuery.of(context).size.height * 0.02;


    return Column(
      children: [
        Text("Balance to spend:", style: TextStyle(fontSize: dynamicFontSize, color: Colors.grey),),
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
                padding: EdgeInsets.symmetric(vertical: dynamicPadding, horizontal: dynamicPadding / 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
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