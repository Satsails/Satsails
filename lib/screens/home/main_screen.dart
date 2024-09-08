import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/screens/home/home.dart';
import 'package:Satsails/screens/analytics/analytics.dart';
import 'package:Satsails/screens/services/services.dart';
import 'package:Satsails/screens/accounts/accounts.dart';
import 'package:Satsails/screens/shared/bottom_navigation_bar.dart';
import 'package:Satsails/providers/navigation_provider.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          Home(),
          Analytics(),
          Services(),
          Accounts(),
        ],
      ),
    );
  }
}