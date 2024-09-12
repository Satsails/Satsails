import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/screens/analytics/components/button_picker.dart';
import 'package:Satsails/screens/analytics/components/calendar.dart';
import 'package:Satsails/screens/analytics/components/bitcoin_expenses_diagram.dart';
import 'package:Satsails/screens/analytics/components/liquid_expenses_diagram.dart';
import 'package:Satsails/screens/analytics/components/swaps_builder.dart';
import 'package:Satsails/screens/shared/transactions_builder.dart';
import 'package:Satsails/screens/shared/bottom_navigation_bar.dart';

class Analytics extends ConsumerWidget {
  const Analytics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Center(child: Text('Analytics'.i18n(ref), style: const TextStyle(color: Colors.white))),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
        ),
        body: _buildBody(context, ref),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: ref.watch(navigationProvider),
          context: context,
          onTap: (int index) {
            ref.read(navigationProvider.notifier).state = index;
          },
        ),
      ),
    );
  }

  Widget _buildBody(context, ref) {
    final transactionType = ref.watch(topSelectedButtonProvider);
    return Column(
      children: [
        const Center(child: ButtonPicker()),
        // leave this commented out in case there are issues in the future to bring back functionality
        // if (transactionType == 'Bitcoin' || transactionType == 'Instant Bitcoin')
        //   const Calendar(),
        if (transactionType == 'Bitcoin') const BitcoinExpensesDiagram(),
        if (transactionType == 'Instant Bitcoin') const LiquidExpensesDiagram(),
        if (transactionType == 'Bitcoin' || transactionType == 'Instant Bitcoin')
        const BuildTransactions(showAllTransactions: false,),
        if(transactionType == 'Swap') const Expanded(child: SwapsBuilder()),
      ],
    );
  }
}