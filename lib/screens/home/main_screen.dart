import 'dart:async';
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
  Timer? _syncTimer;

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
      _performSync();
    });
  }

  /// Starts the periodic sync timer.
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _performSync();
    });
  }

  /// Cancels the sync timer.
  void _stopPeriodicSync() {
    _syncTimer?.cancel();
  }

  /// Performs the actual data sync.
  void _performSync() {
    if (!ref.read(backgroundSyncInProgressProvider)) {
      ref.read(backgroundSyncNotifierProvider.notifier).performFullUpdate();
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

    ref.listen<int>(navigationProvider, (previous, next) {
      if (previous == next) return;

      if (next == 0) {
        _performSync();
        _startPeriodicSync();
      } else {
        _stopPeriodicSync();
        _performSync();
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
            ref.read(sendTxProvider.notifier).resetToDefault(); // Example if not auto-disposed
            ref.read(navigationProvider.notifier).state = index;
          }
        },
      ),
    );
  }
}
