import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/expenses_model.dart';
import 'package:satsails/providers/settings_provider.dart';
import 'package:satsails/providers/transactions_provider.dart';
import 'package:icons_plus/icons_plus.dart';
class ExpensesDiagram extends ConsumerWidget {

  const ExpensesDiagram({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bitcoinTransactions = ref.watch(bitcoinTransactionsByDate);
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final dynamicWidth = MediaQuery.of(context).size.width;
    final dynamicHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(
          width: dynamicWidth,
          height: dynamicHeight / 5,
          child: _calculateBitcoinExpenses(bitcoinTransactions).total == 0
              ? PieChart(PieChartData(sections: [PieChartSectionData(value: 1, title: '', radius: 20, color: Colors.grey)], borderData: FlBorderData(show: false)))
              : PieChart(PieChartData(
            sections: [
              PieChartSectionData(value: _calculateBitcoinExpenses(bitcoinTransactions).sent.toDouble(), title: '', radius: 20, badgeWidget: const Icon(Icons.arrow_downward, color: Colors.white), color: Colors.greenAccent),
              PieChartSectionData(value: _calculateBitcoinExpenses(bitcoinTransactions).received.toDouble(), title: '', radius: 20, badgeWidget: const Icon(Icons.arrow_upward, color: Colors.white), color: Colors.redAccent),
              PieChartSectionData(value: _calculateBitcoinExpenses(bitcoinTransactions).fee.toDouble(), title: '', radius: 20, badgeWidget: const Icon(MingCute.pickax_fill, color: Colors.white), color: Colors.deepOrange),
            ],
            borderData: FlBorderData(show: false),
          )),
        ),
        SizedBox(height: dynamicHeight / 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Card(
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.red, Colors.redAccent],
                  ),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Sent: ${_calculateBitcoinExpenses(bitcoinTransactions).convertToDenomination(btcFormat).sent}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ),
            Card(
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.greenAccent, Colors.greenAccent],
                  ),
                  borderRadius: BorderRadius.circular(6.0), // Add this line
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Received: ${_calculateBitcoinExpenses(bitcoinTransactions).convertToDenomination(btcFormat).received}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ),
            Card(
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.deepOrange, Colors.orangeAccent],
                  ),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Fees: ${_calculateBitcoinExpenses(bitcoinTransactions).convertToDenomination(btcFormat).fee}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
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
