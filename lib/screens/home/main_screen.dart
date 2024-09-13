import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/screens/home/home.dart';
import 'package:Satsails/screens/analytics/analytics.dart';
import 'package:Satsails/screens/services/services.dart';
import 'package:Satsails/screens/accounts/accounts.dart';
import 'package:Satsails/providers/navigation_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _isServicesLoaded = false;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const Home(),
      const Analytics(),
      Container(),
      const Accounts(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

    if (currentIndex == 2 && !_isServicesLoaded) {
      setState(() {
        _pages[2] = const Services();
        _isServicesLoaded = true;
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
