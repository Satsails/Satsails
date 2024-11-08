import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/screens/analytics/components/bitcoin_expenses_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class BitcoinExpensesDiagram extends ConsumerWidget {
  const BitcoinExpensesDiagram({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          // Display the Bitcoin balance
          Text(
            '$btcBalanceInFormat $btcFormat',
            style: TextStyle(
              fontSize: screenWidth / 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Always display the ExpensesGraph
          bitcoinIsLoading
              ? Center(
            child: LoadingAnimationWidget.fourRotatingDots(
              color: Colors.orangeAccent,
              size: screenHeight * 0.08,
            ),
          )
              : const Expanded(child:
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ExpensesGraph(),
          )),
        ],
      ),
    );
  }
}
