import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/datetime_range_model.dart';
import 'package:satsails/providers/analytics_provider.dart';
import 'package:satsails/providers/navigation_provider.dart';
import 'package:satsails/screens/analytics/components/button_picker.dart';
import 'package:satsails/screens/analytics/components/calendar.dart';
import 'package:satsails/screens/analytics/components/bitcoin_expenses_diagram.dart';
import 'package:satsails/screens/analytics/components/liquid_expenses_diagram.dart';
import 'package:satsails/screens/analytics/components/swaps_builder.dart';
import 'package:satsails/screens/shared/transactions_builder.dart';
import 'package:satsails/screens/shared/bottom_navigation_bar.dart';

final date = StateProvider<DateTime>((ref) => DateTime.now());

class Analytics extends ConsumerWidget {
  const Analytics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(child: Text('Analytics')),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: _buildBody(context, ref),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: ref.watch(navigationProvider),
        context: context,
        onTap: (int index) {
          ref.read(navigationProvider.notifier).state = index;
        },
      ),
    );
  }

  Widget _buildBody(context, ref) {
    final transactionType = ref.watch(selectedButtonProvider);
    return Column(
      children: [
        const Center(child: ButtonPicker()),
        if (transactionType == 'Bitcoin') const BitcoinExpensesDiagram(),
        if (transactionType == 'Liquid') const LiquidExpensesDiagram(),
        if (transactionType == 'Bitcoin' || transactionType == 'Liquid')
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Calendar(),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.deepOrangeAccent),
                elevation: MaterialStateProperty.all<double>(4),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              onPressed: () {
                ref.read(dateTimeSelectProvider.notifier).update(DateTimeSelect(
                    start: DateTime.utc(0), end: DateTime.now()));
              },
              child: const Text('All Transactions', style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ],
        ),
        if (transactionType == 'Bitcoin' || transactionType == 'Liquid')
        const Expanded(child: BuildTransactions(showAllTransactions: false,)),
        if(transactionType == 'Swap') const Expanded(child: SwapsBuilder()),
      ],
    );
  }
}