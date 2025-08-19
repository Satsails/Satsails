import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/screens/analytics/analytics.dart';
import 'package:Satsails/screens/exchange/exchange.dart';
import 'package:Satsails/screens/explore/explore.dart';
import 'package:Satsails/screens/home/home.dart';
import 'package:Satsails/screens/settings/settings.dart';
import 'package:Satsails/screens/shared/custom_bottom_navigation_bar.dart';
import 'package:Satsails/services/background_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The widget is now a stateless ConsumerWidget.
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  final List<Widget> _screens = const [
    Home(),
    Analytics(),
    Exchange(),
    Explore(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);

    // Access the BackgroundSyncService singleton
    final backgroundSyncService = BackgroundSyncService();

    // Start or stop syncing based on current index
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentIndex == 1) {
        backgroundSyncService.stop();
      } else {
        backgroundSyncService.start(ref);
      }
    });

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: _screens[currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (currentIndex != index) {
            ref.read(sendTxProvider.notifier).resetToDefault();
            ref.read(navigationProvider.notifier).state = index;
          }
        },
      ),
    );
  }
}
