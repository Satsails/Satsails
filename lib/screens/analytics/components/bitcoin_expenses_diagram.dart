import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/screens/analytics/components/bitcoin_expenses_graph.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/expenses_model.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class BitcoinExpensesDiagram extends ConsumerWidget {
  const BitcoinExpensesDiagram({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bitcoinTransactions = ref.watch(bitcoinTransactionsByDate);
    final bitcoinIsLoading = ref.watch(transactionNotifierProvider).bitcoinTransactions.isNotEmpty
        ? ref.watch(transactionNotifierProvider).bitcoinTransactions.first.txid == ''
        : false;
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final btcBalanceInFormat = ref.watch(btcBalanceInFormatProvider(btcFormat));
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                '$btcBalanceInFormat $btcFormat',
                style: TextStyle(
                  fontSize: screenWidth / 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Display Sent, Received, and Fee Cards or Expenses Graph
          if (ref.watch(oneDayProvider))
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildExpenseCard(
                    title: 'Sent'.i18n(ref),
                    value: _calculateBitcoinExpenses(bitcoinTransactions).convertToDenomination(btcFormat).sent,
                    gradientColors: [Colors.deepOrangeAccent, Colors.orange],
                    context: context,
                    btcFormat: btcFormat,
                    icon: Icons.arrow_upward,
                  ),
                  _buildExpenseCard(
                    title: 'Received'.i18n(ref),
                    value: _calculateBitcoinExpenses(bitcoinTransactions).convertToDenomination(btcFormat).received,
                    gradientColors: [Colors.lightGreenAccent, Colors.green],
                    context: context,
                    btcFormat: btcFormat,
                    icon: Icons.arrow_downward,
                  ),
                  _buildExpenseCard(
                    title: 'Fee'.i18n(ref),
                    value: _calculateBitcoinExpenses(bitcoinTransactions).convertToDenomination(btcFormat).fee,
                    gradientColors: [Colors.blueAccent, Colors.blue],
                    context: context,
                    btcFormat: btcFormat,
                    icon: Icons.receipt,
                  ),
                ],
              ),
            )
          else
            bitcoinIsLoading
                ? Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Colors.orangeAccent,
                size: screenHeight * 0.08,
              ),
            )
                : const Expanded(child: ExpensesGraph()),
        ],
      ),
    );
  }

  // Updated card widget for a modern look
  Widget _buildExpenseCard({
    required String title,
    required double value,
    required List<Color> gradientColors,
    required BuildContext context,
    required String btcFormat,
    required IconData icon,
  }) {
    final dynamicWidth = MediaQuery.of(context).size.width;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: dynamicWidth / 12),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: dynamicWidth / 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              btcFormat == 'sats' ? value.toStringAsFixed(0) : value.toStringAsFixed(2),
              style: TextStyle(
                color: Colors.white,
                fontSize: dynamicWidth / 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to calculate Bitcoin expenses
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
