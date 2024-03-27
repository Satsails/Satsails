import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails_wallet/screens/analytics/analytics.dart';
import 'package:satsails_wallet/screens/services/services.dart';
import '../home.dart';

class CustomBottomNavigationBar extends ConsumerWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final BuildContext context; // Add this line to store the context

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    required this.context,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<BottomNavigationBarItem> bottomNavBarItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.apps),
        label: 'Services',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart),
        label: 'Analytics',
      ),
    ];

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        currentIndex: currentIndex,
        onTap: (index) {
          _navigateToScreen(index, context); // Call the navigation method
          onTap(index); // Call the provided onTap callback
        },
        selectedFontSize: 12,
        unselectedFontSize: 12,
        iconSize: 24,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.orangeAccent,
        elevation: 0.0,
        items: bottomNavBarItems,
      ),
    );
  }

  void _navigateToScreen(int index, BuildContext context) {
    Widget page = Home();

    switch (index) {
      case 0:
        page = Home();
        break;
      case 1:
        page = Services();
        break;
      case 2:
        page = Analytics();
        break;
    }

    _navigateToPage(page, context);
  }

  void _navigateToPage(Widget page, BuildContext context) {
    Navigator.push(
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
