import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'dart:math' as math;

class CustomBottomNavigationBar extends ConsumerWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final BuildContext context;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.context,
  });


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    const maxFontSize = 16.0;

    List<BottomNavigationBarItem> bottomNavBarItems = [
      BottomNavigationBarItem(
        icon: GestureDetector(
          onTapDown: (_) => onTap(0), // Trigger on tap down immediately
          onLongPress: () {}, // Disable long press by doing nothing
          child: Icon(Icons.dashboard, size: math.min(screenHeight * 0.03, 25.0)),
        ),
        label: 'Home'.i18n,
      ),
      BottomNavigationBarItem(
        icon: GestureDetector(
          onTapDown: (_) => onTap(1), // Trigger on tap down immediately
          onLongPress: () {}, // Disable long press by doing nothing
          child: Icon(Icons.analytics, size: math.min(screenHeight * 0.03, 25.0)),
        ),
        label: 'Analytics'.i18n,
      ),
      BottomNavigationBarItem(
        icon: GestureDetector(
          onTapDown: (_) => onTap(2), // Trigger on tap down immediately
          onLongPress: () {}, // Disable long press by doing nothing
          child: Icon(Icons.lightbulb, size: math.min(screenHeight * 0.03, 25.0)),
        ),
        label: 'Services'.i18n,
      ),
      BottomNavigationBarItem(
        icon: GestureDetector(
          onTapDown: (_) => onTap(3), // Trigger on tap down immediately
          onLongPress: () {}, // Disable long press by doing nothing
          child: Icon(Icons.account_balance_wallet, size: math.min(screenHeight * 0.03, 25.0)),
        ),
        label: 'Wallets'.i18n,
      ),
    ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black,
      currentIndex: currentIndex,
      onTap: onTap, // Regular tap
      unselectedItemColor: Colors.white,
      selectedItemColor: Colors.orangeAccent,
      elevation: 8.0,
      items: bottomNavBarItems,
      unselectedFontSize: math.min(screenHeight * 0.02, maxFontSize),
      selectedFontSize: math.min(screenHeight * 0.02, maxFontSize),
    );
  }
}

