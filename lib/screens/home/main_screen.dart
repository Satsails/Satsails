import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/screens/analytics/analytics.dart';
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
  bool _isLoopActive = false;

  final List<Widget> _screens = const [
    Home(),
    Analytics(),
    Exchange(),
    Explore(),
    Settings(),
  ];

  @override
  void initState() {
    super.initState();
    _startContinuousSync();
  }

  @override
  void dispose() {
    _isLoopActive = false;
    super.dispose();
  }

  Future<void> _startContinuousSync() async {
    _isLoopActive = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      while (_isLoopActive) {
        try {
          if (mounted && !ref.read(backgroundSyncInProgressProvider)) {
            await ref.read(backgroundSyncNotifierProvider.notifier).performFullUpdate();
          }
        } catch (e) {
          debugPrint("Sync loop failed, will retry: $e");
        }

        await Future.delayed(const Duration(seconds: 5));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

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