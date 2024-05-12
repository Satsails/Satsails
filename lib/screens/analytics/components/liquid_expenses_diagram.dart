import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/helpers/asset_mapper.dart';
import 'package:satsails/models/expenses_model.dart';
import 'package:satsails/providers/settings_provider.dart';
import 'package:satsails/providers/transactions_provider.dart';
class LiquidExpensesDiagram extends ConsumerWidget {

  const LiquidExpensesDiagram({Key? key}) : super(key: key);

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bitcoinTransactions = ref.watch(liquidTransactionsByDate);
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final dynamicHeight = MediaQuery.of(context).size.height;

    List<Column> cards = [
    Column(children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Bitcoin", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
              Icon(Icons.swipe, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCard('Sent', _calculateLiquidExpenses(bitcoinTransactions).convertToDenomination(btcFormat).bitcoinSent, [Colors.blue, Colors.deepPurple], context, btcFormat),
              _buildCard('Received', _calculateLiquidExpenses(bitcoinTransactions).convertToDenomination(btcFormat).bitcoinReceived, [Colors.blue, Colors.deepPurple], context, btcFormat),
              _buildCard('Fee', _calculateLiquidExpenses(bitcoinTransactions).convertToDenomination(btcFormat).fee, [Colors.blue, Colors.deepPurple], context, btcFormat),
            ],),],
    ),
      Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Real", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
              Icon(Icons.swipe, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCard('Sent', _calculateLiquidExpenses(bitcoinTransactions).brlSent / 100000000, [Colors.blue, Colors.deepPurple], context, btcFormat),
              _buildCard('Received', _calculateLiquidExpenses(bitcoinTransactions).brlReceived / 100000000, [Colors.blue, Colors.deepPurple], context, btcFormat),
            ],
          ),
        ],
      ),
      Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Dollar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
              Icon(Icons.swipe, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCard('Sent', _calculateLiquidExpenses(bitcoinTransactions).usdSent / 100000000, [Colors.blue, Colors.deepPurple], context, btcFormat),
              _buildCard('Received', _calculateLiquidExpenses(bitcoinTransactions).usdReceived / 100000000, [Colors.blue, Colors.deepPurple], context, btcFormat),
            ],
          ),
        ],
      ),
      Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Euro", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
              Icon(Icons.swipe, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCard('Sent', _calculateLiquidExpenses(bitcoinTransactions).euroSent / 100000000, [Colors.blue, Colors.deepPurple], context, btcFormat),
              _buildCard('Received', _calculateLiquidExpenses(bitcoinTransactions).euroReceived / 100000000, [Colors.blue, Colors.deepPurple], context, btcFormat),
            ],
          ),
        ],
      ),
    ];



    return SizedBox(
      height: dynamicHeight / 5,
      child: CardSwiper(
        scale: 0.1,
        padding: const EdgeInsets.all(0),
        allowedSwipeDirection: const AllowedSwipeDirection.symmetric(horizontal: true),
        cardsCount: cards.length,
        initialIndex: 0,
        cardBuilder: (context, index, percentThresholdX, percentThresholdY) { return cards[index]; },
      ),
    );
  }

  Widget _buildCard(String title, double value, List<Color> gradientColors, BuildContext context, btcFormat) {
    final dynamicHeight = MediaQuery.of(context).size.height;
    final dynamicWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: dynamicWidth / 3.5,
      height: dynamicHeight / 7,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                btcFormat == 'sats' ? value.toStringAsFixed(0) : value.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 14),
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
