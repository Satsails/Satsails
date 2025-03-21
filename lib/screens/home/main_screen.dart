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
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const Home(),
      const Explore(),
      Exchange(key: UniqueKey()),
      const Transactions(),
      const Accounts(),
      const Settings(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

    // When navigating to Exchange (index 2), replace it with a new instance
    if (currentIndex == 2) {
      setState(() {
        _pages[2] = Exchange(key: UniqueKey());
      });
    }

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
    );
  }
}