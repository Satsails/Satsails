import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/screens/exchange/exchange.dart';
import 'package:Satsails/screens/explore/explore.dart';
import 'package:Satsails/screens/settings/settings.dart';
import 'package:Satsails/screens/transactions/transactions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/screens/home/home.dart';
import 'package:Satsails/screens/accounts/accounts.dart';
import 'package:Satsails/providers/navigation_provider.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  // Reset providers unless the screen is Exchange (index 2)
  void _resetProviders(WidgetRef ref, int index) {
    if (index != 2) { // Skip reset for Exchange screen
      Future.microtask(() {
        ref.read(sendTxProvider.notifier).resetToDefault();
        ref.read(sendBlocksProvider.notifier).state = 1;
      });
    }
  }

  // Map of index to screen widget
  Widget _getCurrentScreen(int index) {
    const screens = {
      0: Home(),
      1: Accounts(),
      2: Exchange(),
      3: Transactions(),
      4: Explore(),
      5: Settings(),
    };

    // Return the screen for the given index, or Home as fallback
    return screens[index] ?? const Home();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider); // Watch for reactivity

    // Reset providers conditionally based on the current index
    _resetProviders(ref, currentIndex);

    return Scaffold(
      body: _getCurrentScreen(currentIndex),
    );
  }
}