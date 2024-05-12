import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/expenses_model.dart';
import 'package:satsails/providers/settings_provider.dart';
import 'package:satsails/providers/transactions_provider.dart';

class BitcoinExpensesDiagram extends ConsumerWidget {

  const BitcoinExpensesDiagram({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bitcoinTransactions = ref.watch(bitcoinTransactionsByDate);
    final btcFormat = ref.watch(settingsProvider).btcFormat;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCard('Sent',_calculateBitcoinExpenses(bitcoinTransactions).convertToDenomination(btcFormat).sent, [Colors.orange, Colors.deepOrange], context, btcFormat),
            _buildCard('Received',_calculateBitcoinExpenses(bitcoinTransactions).convertToDenomination(btcFormat).received, [Colors.orange, Colors.deepOrange], context, btcFormat),
            _buildCard('Fee',_calculateBitcoinExpenses(bitcoinTransactions).convertToDenomination(btcFormat).fee, [Colors.orange, Colors.deepOrange], context, btcFormat),
          ],),
      ],
    );
  }

  Widget _buildCard(String title, double value, List<Color> gradientColors, BuildContext context, String btcFormat) {
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
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                btcFormat == 'sats' ? value.toStringAsFixed(0) : value.toString(),
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BitcoinExpenses _calculateBitcoinExpenses(List<dynamic> transactions) {
    int received = 0;
    int sent = 0;
    int fee = 0;
    for (var transaction in transactions) {
      received += transaction.received as int;
      sent += transaction.sent as int;
      if (transaction.sent > 0) {
        fee += transaction.fee as int;
      }
    }
    return BitcoinExpenses(received: received, sent: sent, fee: fee);
  }
}
