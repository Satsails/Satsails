import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/screens/analytics/components/liquid_expenses_graph.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/expenses_model.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';

class LiquidExpensesDiagram extends ConsumerWidget {
  const LiquidExpensesDiagram({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bitcoinTransactions = ref.watch(liquidTransactionsByDate);
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final liquidBalanceInFormat = ref.watch(liquidBalanceInFormatProvider(btcFormat));
    final balance = ref.watch(balanceNotifierProvider);
    final oneDay = ref.watch(oneDayProvider);

    List<Widget> cards = [
      Column(
        children: [
          Text(
            '${'Current Balance'.i18n(ref)}: $liquidBalanceInFormat $btcFormat', style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Bitcoin", style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.white)),
              const Icon(Icons.swipe, color: Colors.white),
            ],
          ),
          if (oneDay)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCard('Sent'.i18n(ref), _calculateLiquidExpenses(bitcoinTransactions).convertToDenomination(btcFormat).bitcoinSent, [const Color(0xFF288BEC), const Color(0xFF288BEC)], context, btcFormat, screenWidth, screenHeight),
                _buildCard('Received'.i18n(ref), _calculateLiquidExpenses(bitcoinTransactions).convertToDenomination(btcFormat).bitcoinReceived, [const Color(0xFF288BEC), const Color(0xFF288BEC)], context, btcFormat, screenWidth, screenHeight),
                _buildCard('Fee'.i18n(ref), _calculateLiquidExpenses(bitcoinTransactions).convertToDenomination(btcFormat).fee,[const Color(0xFF288BEC), const Color(0xFF288BEC)], context, btcFormat, screenWidth, screenHeight),
              ],
            ),
          if (!oneDay)
            Expanded(child: ExpensesGraph(assetId: AssetMapper.reverseMapTicker(AssetId.LBTC))),
        ],
      ),
      Column(
        children: [
          Text(
            '${'Current Balance'.i18n(ref)}: ${fiatInDenominationFormatted(balance.brlBalance)}', style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Depix", style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.white)),
              const Icon(Icons.swipe, color: Colors.white),
            ],
          ),
          if (oneDay)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCard('Sent'.i18n(ref), _calculateLiquidExpenses(bitcoinTransactions).brlSent / 100000000, [const Color(0xFF288BEC), const Color(0xFF288BEC)], context, btcFormat, screenWidth, screenHeight),
                _buildCard('Received'.i18n(ref), _calculateLiquidExpenses(bitcoinTransactions).brlReceived / 100000000, [const Color(0xFF288BEC), const Color(0xFF288BEC)], context, btcFormat, screenWidth, screenHeight),
              ],
            ),
          if (!oneDay)
            Expanded(child: ExpensesGraph(assetId: AssetMapper.reverseMapTicker(AssetId.BRL))),
        ],
      ),
      Column(
        children: [
          Text(
            '${'Current Balance'.i18n(ref)}: ${fiatInDenominationFormatted(balance.usdBalance)}', style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("USDt", style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.white)),
              const Icon(Icons.swipe, color: Colors.white),
            ],
          ),
          if (oneDay)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCard('Sent'.i18n(ref), _calculateLiquidExpenses(bitcoinTransactions).usdSent / 100000000, [const Color(0xFF288BEC), const Color(0xFF288BEC)], context, btcFormat, screenWidth, screenHeight),
                _buildCard('Received'.i18n(ref), _calculateLiquidExpenses(bitcoinTransactions).usdReceived / 100000000, [const Color(0xFF288BEC), const Color(0xFF288BEC)], context, btcFormat, screenWidth, screenHeight),
              ],
            ),
          if (!oneDay)
            Expanded(child: ExpensesGraph(assetId: AssetMapper.reverseMapTicker(AssetId.USD))),
        ],
      ),
      Column(
        children: [
          Text(
            '${'Current Balance'.i18n(ref)}: ${fiatInDenominationFormatted(balance.eurBalance)}', style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("EURx", style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: Colors.white)),
              const Icon(Icons.swipe, color: Colors.white),
            ],
          ),
          if (oneDay)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCard('Sent'.i18n(ref), _calculateLiquidExpenses(bitcoinTransactions).euroSent / 100000000, [const Color(0xFF288BEC), const Color(0xFF288BEC)], context, btcFormat, screenWidth, screenHeight),
                _buildCard('Received'.i18n(ref), _calculateLiquidExpenses(bitcoinTransactions).euroReceived / 100000000, [const Color(0xFF288BEC), const Color(0xFF288BEC)], context, btcFormat, screenWidth, screenHeight),
              ],
            ),
          if (!oneDay)
            Expanded(child: ExpensesGraph(assetId: AssetMapper.reverseMapTicker(AssetId.EUR))),
        ],
      ),
    ];

    return Expanded(
      child: ImageSlideshow(
        initialPage: 0,
        indicatorBottomPadding: 0,
        indicatorColor: Colors.orangeAccent,
        indicatorBackgroundColor: Colors.grey,
        children: cards,
      ),
    );
  }

  Widget _buildCard(String title, double value, List<Color> gradientColors, BuildContext context, btcFormat, double screenWidth, double screenHeight) {
    final dynamicWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth / 3.5,
      height: screenHeight / 7,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.black, fontSize: dynamicWidth / 23, fontWeight: FontWeight.bold), // 3% of screen width
              ),
              Text(
                btcFormat == 'sats' ? value.toStringAsFixed(0) : value.toString(),
                style: TextStyle(color: Colors.black, fontSize: dynamicWidth / 25),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LiquidExpenses _calculateLiquidExpenses(List<dynamic> transactions) {
    int bitcoinSent = 0;
    int bitcoinReceived = 0;
    int fee = 0;
    int brlSent = 0;
    int brlReceived = 0;
    int usdSent = 0;
    int usdReceived = 0;
    int euroSent = 0;
    int euroReceived = 0;

    for (final transaction in transactions) {
      final balances = transaction.balances;

      if (transaction.kind == "incoming"){
        fee += transaction.fee as int;
        for (final balance in balances){
          if (balance.assetId == AssetMapper.reverseMapTicker(AssetId.LBTC)){
            bitcoinReceived += balance.value as int;
          } else if (balance.assetId == AssetMapper.reverseMapTicker(AssetId.BRL)){
            brlReceived += balance.value as int;
          } else if (balance.assetId == AssetMapper.reverseMapTicker(AssetId.USD)){
            usdReceived += balance.value as int;
          } else if (balance.assetId == AssetMapper.reverseMapTicker(AssetId.EUR)){
            euroReceived += balance.value as int;
          }
        }
      } else if (transaction.kind == "outgoing"){
        for (final balance in balances){
          if (balance.assetId == AssetMapper.reverseMapTicker(AssetId.LBTC)){
            bitcoinSent += balance.value as int;
          } else if (balance.assetId == AssetMapper.reverseMapTicker(AssetId.BRL)){
            brlSent += balance.value as int;
          } else if (balance.assetId == AssetMapper.reverseMapTicker(AssetId.USD)){
            usdSent += balance.value as int;
          } else if (balance.assetId == AssetMapper.reverseMapTicker(AssetId.EUR)){
            euroSent += balance.value as int;
          }
        }
      }
    }
    return LiquidExpenses(
      bitcoinSent: bitcoinSent.abs(),
      bitcoinReceived: bitcoinReceived.abs(),
      brlSent: brlSent.abs(),
      brlReceived: brlReceived.abs(),
      usdSent: usdSent.abs(),
      usdReceived: usdReceived.abs(),
      euroSent: euroSent.abs(),
      euroReceived: euroReceived.abs(),
      fee: fee.abs(),
    );
  }
}
