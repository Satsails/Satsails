import 'package:Satsails/screens/analytics/components/lightning_expenses_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LightningExpensesDiagram extends ConsumerStatefulWidget {
  const LightningExpensesDiagram({super.key});

  @override
  _LightningExpensesDiagramState createState() =>
      _LightningExpensesDiagramState();
}

class _LightningExpensesDiagramState
    extends ConsumerState<LightningExpensesDiagram> {

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LightningExpensesGraph(),
    );
  }
}
