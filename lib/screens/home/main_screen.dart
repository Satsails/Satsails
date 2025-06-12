import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/screens/exchange/exchange.dart';
import 'package:Satsails/screens/explore/explore.dart';
import 'package:Satsails/screens/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/screens/home/home.dart';
import 'package:Satsails/screens/accounts/accounts.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/screens/shared/custom_bottom_navigation_bar.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  void _resetProviders(WidgetRef ref, int index) {
    if (index == 2) { // Skip reset for Exchange screen
      Future.microtask(() {
        ref.read(sendTxProvider.notifier).resetToDefault();
        ref.read(sendBlocksProvider.notifier).state = 1;
        ref.read(shouldUpdateMemoryProvider.notifier).state = false;
      });
    } else {
      ref.read(sendTxProvider.notifier).resetToDefault();
      ref.read(sendBlocksProvider.notifier).state = 1;
      ref.read(shouldUpdateMemoryProvider.notifier).state = true;
    }
  }

  Widget _getCurrentScreen(int index) {
    const screens = {
      0: Home(),
      1: Accounts(),
      2: Exchange(),
      3: Explore(),
      4: Settings(),
    };
    return screens[index] ?? const Home();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);
    final isSyncing = ref.watch(backgroundSyncInProgressProvider);

    // Listen to changes in navigationProvider and handle resets and sync actions
    ref.listen<int>(navigationProvider, (previous, next) {
      if (previous != next) {
        _resetProviders(ref, next);
        // Perform sync actions when navigating to Home (index 0) and not syncing
        if (next == 0 && !isSyncing) {
          ref.read(backgroundSyncNotifierProvider.notifier).performSync();
          ref.read(updateCurrencyProvider.future);
          ref.read(getFiatPurchasesProvider.future);
        }
      }
    });

    return Scaffold(
      extendBody: currentIndex != 0,
      backgroundColor: Colors.black,
      body: _getCurrentScreen(currentIndex),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(navigationProvider.notifier).state = index;
        },
      ),
    );
  }
}