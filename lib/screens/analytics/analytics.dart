import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/providers/navigation_provider.dart';
import 'package:satsails/screens/analytics/components/button_picker.dart';
import 'package:satsails/screens/analytics/components/calendar.dart';
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
    return Column(
      children: [
        Center(child: ButtonPicker()),
        Expanded(child: Chart()),
        Expanded(child: Calendar()),
        Expanded(child: BuildTransactions(showAllTransactions: false,)),
      ],
    );
  }
}