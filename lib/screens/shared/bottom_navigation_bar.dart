import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:Satsails/screens/analytics/analytics.dart';
import 'package:Satsails/screens/home/home.dart';
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
    const maxFontSize = 16.0; // Set your desired max size

    List<BottomNavigationBarItem> bottomNavBarItems = [
      BottomNavigationBarItem(
        icon: Icon(AntDesign.home_outline, size: math.min(screenHeight * 0.03, 25.0)),
        label: 'Home'.i18n(ref),
      ),
      BottomNavigationBarItem(
        icon: Icon(AntDesign.bar_chart_outline, size: math.min(screenHeight * 0.03, 25.0)),
        label: 'Analytics'.i18n(ref),
      ),
    ];

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        onTap: (index) {
          _navigateToScreen(index, context);
          onTap(index);
        },
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.orangeAccent,
        elevation: 8.0,
        items: bottomNavBarItems,
        unselectedFontSize: math.min(screenHeight * 0.02, maxFontSize), // 2% of screen height or maxFontSize, whichever is smaller
        selectedFontSize: math.min(screenHeight * 0.02, maxFontSize), // 2% of screen height or maxFontSize, whichever is smaller
      ),
    );
  }

  void _navigateToScreen(int index, BuildContext context) {
    Widget page = const Home();

    switch (index) {
      case 0:
        page = const Home();
        break;
      case 1:
        page = const Analytics();
        break;
    }

    _navigateToPage(page, context);
  }

  void _navigateToPage(Widget page, BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation1, Animation<double> animation2) {
          return page;
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}