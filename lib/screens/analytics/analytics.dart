import 'package:Satsails/providers/coinos_provider.dart';
import 'package:Satsails/screens/analytics/components/lightning_expenses_diagram.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/screens/analytics/components/bitcoin_expenses_diagram.dart';

import 'components/calendar.dart';

final selectedExpenseTypeProvider = StateProvider<String>((ref) => "Bitcoin");

class Analytics extends ConsumerWidget {
  const Analytics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: _buildBody(context, ref)),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final transactionType = ref.watch(selectedExpenseTypeProvider);
    final hasLightning = ref.watch(coinosLnProvider).token.isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 16),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: transactionType,
              isExpanded: true,
              dropdownColor: Colors.grey[900],
              icon: Icon(Icons.arrow_drop_down, color: Colors.orange, size: screenWidth * 0.08),
              underline: SizedBox(),
              style: TextStyle(color: Colors.orange, fontSize: screenWidth * 0.05, fontWeight: FontWeight.w500),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  ref.read(selectedButtonProvider.notifier).state = 1;
                  ref.read(selectedExpenseTypeProvider.notifier).state = newValue;
                }
              },
              items: <String>["Bitcoin", "Liquid", "Swaps", if (hasLightning) "Lightning"]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      value.i18n,
                      style: TextStyle(color: Colors.orange, fontSize: screenWidth * 0.045),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (transactionType == 'Bitcoin') const BitcoinExpensesDiagram(),
        // if (transactionType == 'Liquid') const LiquidExpensesDiagram(),
        // if (transactionType == 'Swaps') const Expanded(child: SwapsBuilder()),
        if (transactionType == 'Lightning' && hasLightning) const LightningExpensesDiagram(),
      ],
    );
  }
}