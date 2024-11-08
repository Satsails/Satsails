import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/screens/analytics/components/liquid_expenses_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LiquidExpensesDiagram extends ConsumerWidget {
  const LiquidExpensesDiagram({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bitcoinIsLoading = ref.watch(transactionNotifierProvider).liquidTransactions.isNotEmpty
        ? ref.watch(transactionNotifierProvider).liquidTransactions.first.balances.isEmpty
        : false;
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final liquidBalanceInFormat = ref.watch(liquidBalanceInFormatProvider(btcFormat));
    final balance = ref.watch(balanceNotifierProvider);

    List<Widget> cards = [
      Column(
        children: [
          Text(
            '$liquidBalanceInFormat $btcFormat',
            style: TextStyle(
              fontSize: screenWidth / 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Asset Label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Bitcoin",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Icon(Icons.swipe, color: Colors.white),
            ],
          ),
          // Always display the ExpensesGraph
          bitcoinIsLoading
              ? Center(
            child: LoadingAnimationWidget.fourRotatingDots(
              color: Colors.orange,
              size: screenHeight * 0.1,
            ),
          )
              : Expanded(
            child: ExpensesGraph(
              assetId: AssetMapper.reverseMapTicker(AssetId.LBTC),
            ),
          ),
        ],
      ),
      Column(
        children: [
          Text(
            '${fiatInDenominationFormatted(balance.brlBalance)}',
            style: TextStyle(
              fontSize: screenWidth / 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Asset Label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Depix",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Icon(Icons.swipe, color: Colors.white),
            ],
          ),
          // Always display the ExpensesGraph
          bitcoinIsLoading
              ? Center(
            child: LoadingAnimationWidget.fourRotatingDots(
              color: Colors.orange,
              size: screenHeight * 0.1,
            ),
          )
              : Expanded(
            child: ExpensesGraph(
              assetId: AssetMapper.reverseMapTicker(AssetId.BRL),
            ),
          ),
        ],
      ),
      Column(
        children: [
          Text(
            '${fiatInDenominationFormatted(balance.usdBalance)}',
            style: TextStyle(
              fontSize: screenWidth / 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Asset Label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "USDt",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Icon(Icons.swipe, color: Colors.white),
            ],
          ),
          // Always display the ExpensesGraph
          bitcoinIsLoading
              ? Center(
            child: LoadingAnimationWidget.fourRotatingDots(
              color: Colors.orange,
              size: screenHeight * 0.1,
            ),
          )
              : Expanded(
            child: ExpensesGraph(
              assetId: AssetMapper.reverseMapTicker(AssetId.USD),
            ),
          ),
        ],
      ),
      Column(
        children: [
          Text(
            '${fiatInDenominationFormatted(balance.eurBalance)}',
            style: TextStyle(
              fontSize: screenWidth / 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Asset Label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "EURx",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Icon(Icons.swipe, color: Colors.white),
            ],
          ),
          // Always display the ExpensesGraph
          bitcoinIsLoading
              ? Center(
            child: LoadingAnimationWidget.fourRotatingDots(
              color: Colors.orange,
              size: screenHeight * 0.1,
            ),
          )
              : Expanded(
            child: ExpensesGraph(
              assetId: AssetMapper.reverseMapTicker(AssetId.EUR),
            ),
          ),
        ],
      ),
    ];

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ImageSlideshow(
          initialPage: 0,
          indicatorBottomPadding: 0,
          indicatorColor: Colors.orangeAccent,
          indicatorBackgroundColor: Colors.grey,
          children: cards,
        ),
      ),
    );
  }
}
