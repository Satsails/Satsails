import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final sendLiquidProvider = StateProvider((ref) => true);

class LightningCards extends StatelessWidget {
  final double titleFontSize;
  final AsyncValue initializeBalance;
  final dynamic liquidFormart;
  final dynamic btcFormart;
  final dynamic liquidBalanceInFormat;
  final dynamic btcBalanceInFormat;
  final double dynamicPadding;
  final double dynamicMargin;
  final double dynamicCardHeight;
  final WidgetRef ref;

  const LightningCards({
    Key? key,
    required this.titleFontSize,
    required this.initializeBalance,
    required this.liquidFormart,
    required this.btcFormart,
    required this.liquidBalanceInFormat,
    required this.btcBalanceInFormat,
    required this.dynamicPadding,
    required this.dynamicMargin,
    required this.dynamicCardHeight,
    required this.ref,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final liquidBalanceInFormat = ref.watch(liquidBalanceInFormatProvider('BTC')) == '0.00000000'? 0 : double.parse(ref.watch(liquidBalanceInFormatProvider('BTC')));
    final currency = ref.read(settingsProvider).currency;
    final currencyRate = ref.read(selectedCurrencyProvider(currency));
    final liquidBalanceInSelectedCurrency = (currencyRate * liquidBalanceInFormat);
    final bitcoinBalanceInFormat = ref.watch(btcBalanceInFormatProvider('BTC')) == '0.00000000' ? 0: double.parse(ref.watch(btcBalanceInFormatProvider('BTC')));
    final bitcoinBalanceInSelectedCurrency = (currencyRate * bitcoinBalanceInFormat);

    return SizedBox(
      height: dynamicCardHeight,
      child: CardSwiper(
        scale: 0.1,
        padding: const EdgeInsets.all(0),
        allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true),
        cardsCount: 2, // Number of cards in the swiper
        initialIndex: ref.watch(currentCardIndexProvider),
        onSwipe: (previousIndex, currentIndex, direction) => onSwipe(previousIndex, currentIndex, direction),
        cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
          return _buildCard(
            context,
            index,
            liquidBalanceInSelectedCurrency.toStringAsFixed(2),
            bitcoinBalanceInSelectedCurrency.toStringAsFixed(2),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, int index, String liquidBalanceInSelectedCurrency, String btcBalanceInSelectedCurrency) {
    String title;
    String balanceText;
    List<Color> gradientColors;
    bool isLiquid = true;

    switch (index) {
      case 0:
        title = 'Liquid Balance';
        balanceText = '$liquidBalanceInFormat $liquidFormart';
        gradientColors = const [Color(0xFF288BEC), Color(0xFF288BEC)];
        break;
      case 1:
        title = 'Bitcoin Balance';
        balanceText = '$btcBalanceInFormat $btcFormart';
        gradientColors = const [Colors.orange, Colors.orange];
        isLiquid = false;
        break;
      default:
        title = 'Liquid Balance';
        balanceText = '$liquidBalanceInFormat $liquidFormart';
        gradientColors = const [Color(0xFF288BEC), Color(0xFF288BEC)];
        break;
    }

    return SizedBox(
      width: double.infinity,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        elevation: 10,
        margin: EdgeInsets.all(dynamicMargin),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height < 800
                    ? dynamicPadding
                    : dynamicPadding * 2,
                horizontal: dynamicPadding * 2),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          title.i18n(ref),
                          style: TextStyle(
                            fontSize: titleFontSize / 1.5,
                            color: Colors.black,),
                          textAlign: TextAlign.center),
                      initializeBalance.when(
                        data: (_) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(balanceText,
                                style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                textAlign: TextAlign.center),
                            if (isLiquid)
                              Text(
                                '$liquidBalanceInSelectedCurrency ${ref.read(settingsProvider).currency}',
                                style: TextStyle(
                                    fontSize: titleFontSize / 1.24,
                                    color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                            if (!isLiquid)
                              Text(
                                '$btcBalanceInSelectedCurrency ${ref.read(settingsProvider).currency}',
                                style: TextStyle(
                                    fontSize: titleFontSize / 1.24,
                                    color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                        loading: () => LoadingAnimationWidget.prograssiveDots(
                            size: titleFontSize, color: Colors.black),
                        error: (error, stack) => TextButton(
                          onPressed: () {
                            ref.refresh(initializeBalanceProvider);
                          },
                          child: Text('Retry',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: titleFontSize)),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: dynamicPadding / 2,
                  right: dynamicPadding / 2,
                  child: const Icon(Icons.swipe_outlined, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool onSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    switch (currentIndex) {
      case 0:
        ref.read(sendLiquidProvider.notifier).state = true;
        ref.read(sendBlocksProvider.notifier).state = 1.0;
        break;
      case 1:
        ref.read(sendLiquidProvider.notifier).state = false;
        ref.read(sendBlocksProvider.notifier).state = 1.0;
        break;
      default:
        ref.read(sendLiquidProvider.notifier).state = true;
        ref.read(sendBlocksProvider.notifier).state = 1.0;
    }
    return true;
  }
}