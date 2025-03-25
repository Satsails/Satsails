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

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

    // Function to build the current screen based on the index
    Widget getCurrentScreen(int index) {
      Future.microtask(() {
        ref.read(sendTxProvider.notifier).resetToDefault();
        ref.read(sendBlocksProvider.notifier).state = 1;
      });

      switch (index) {
        case 0:
          return const Home();
        case 1:
          return const Explore();
        case 2:
          return const Exchange(); // Forces a new instance each time
        case 3:
          return const Transactions();
        case 4:
          return const Accounts();
        case 5:
          return const Settings();
        default:
          return const Home(); // Fallback to Home screen
      }
    }

    return Scaffold(
      body: getCurrentScreen(currentIndex),
    );
  }
}