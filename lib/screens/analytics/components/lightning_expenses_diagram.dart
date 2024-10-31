import 'package:Satsails/screens/analytics/components/lightning_expenses_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LightningExpensesDiagram extends ConsumerWidget {
  const LightningExpensesDiagram({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Expanded(
      child: LightningExpensesGraph(),
    );
  }
}
