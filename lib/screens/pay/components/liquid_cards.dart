import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LiquidCards extends StatelessWidget {
  final double titleFontSize;
  final AsyncValue initializeBalance;
  final dynamic liquidFormart;
  final dynamic liquidBalanceInFormat;
  final dynamic balance;
  final double dynamicPadding;
  final double dynamicMargin;
  final double dynamicCardHeight;
  final dynamic ref;
  final TextEditingController controller;

  const LiquidCards({
    Key? key,
    required this.titleFontSize,
    required this.initializeBalance,
    required this.liquidFormart,
    required this.liquidBalanceInFormat,
    required this.balance,
    required this.dynamicPadding,
    required this.dynamicMargin,
    required this.dynamicCardHeight,
    required this.ref,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final liquidBalanceInFormat = ref.watch(liquidBalanceInFormatProvider('BTC')) == '0.00000000'
        ? 0
        : double.parse(ref.watch(liquidBalanceInFormatProvider('BTC')));
    final currency = ref.read(settingsProvider).currency;
    final currencyRate = ref.read(selectedCurrencyProvider(currency));
    final liquidBalanceInSelectedCurrency = (currencyRate * liquidBalanceInFormat);

    return SizedBox(
      height: dynamicCardHeight,
      child: CardSwiper(
        scale: 0.1,
        padding: const EdgeInsets.all(0),
        allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true),
        cardsCount: 4, // Number of cards in the swiper
        initialIndex: ref.watch(currentCardIndexProvider),
        onSwipe: (previousIndex, currentIndex, direction) =>
            onSwipe(previousIndex, currentIndex, direction),
        cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
          return _buildCard(
            context,
            index,
            liquidBalanceInSelectedCurrency,  // Pass the calculated value here
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, int index, double liquidBalanceInSelectedCurrency) {
    String title;
    String balanceText;
    List<Color> gradientColors;
    bool isLiquid = false;

    switch (index) {
      case 0:
        title = 'Liquid Balance';
        balanceText = '$liquidBalanceInFormat $liquidFormart';
        gradientColors = [Color(0xFF288BEC), Color(0xFF288BEC)];
        isLiquid = true;  // Mark this card as Liquid
        break;
      case 1:
        title = 'Depix Balance';
        balanceText = '${fiatInDenominationFormatted(balance.brlBalance)} BRL';
        gradientColors = [Color(0xFF009B3A), Color(0xFF009B3A)];
        break;
      case 2:
        title = 'USDt Balance';
        balanceText = '${fiatInDenominationFormatted(balance.usdBalance)} USD';
        gradientColors = [Color(0xFF008000), Color(0xFF008000)];
        break;
      case 3:
        title = 'EURx Balance';
        balanceText = '${fiatInDenominationFormatted(balance.eurBalance)} EUR';
        gradientColors = [Color(0xFF003399), Color(0xFF003399)];
        break;
      default:
        title = 'Liquid Balance';
        balanceText = '$liquidBalanceInFormat $liquidFormart';
        gradientColors = [Color(0xFF288BEC), Color(0xFF288BEC)];
        isLiquid = true;  // Default to Liquid
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
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
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
}
