import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/screens/accounts/accounts.dart';
import 'package:Satsails/screens/exchange/exchange.dart';
import 'package:Satsails/screens/explore/explore.dart';
import 'package:Satsails/screens/home/home.dart';
import 'package:Satsails/screens/settings/settings.dart';
import 'package:Satsails/screens/shared/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final List<Widget> _screens = const [
    Home(),
    Accounts(),
    Exchange(),
    Explore(),
    Settings(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(backgroundSyncInProgressProvider)) {
        ref.read(backgroundSyncNotifierProvider.notifier).performFullUpdate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);
    final isSyncing = ref.watch(backgroundSyncInProgressProvider);

    ref.listen<int>(navigationProvider, (previous, next) {
      if (previous != next && next == 0 && !isSyncing) {
        ref.read(backgroundSyncNotifierProvider.notifier).performFullUpdate();
      }
    });

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (currentIndex != index) {
            ref.read(sendTxProvider.notifier).resetToDefault();
            ref.read(sendBlocksProvider.notifier).state = 1;
            ref.read(navigationProvider.notifier).state = index;
          }
        },
      ),
    );
  }
}
