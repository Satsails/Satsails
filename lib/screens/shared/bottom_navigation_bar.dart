import 'package:flutter/material.dart';
import 'package:satsails/screens/analytics/analytics.dart';
import 'package:satsails/screens/home/home.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final BuildContext context;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    List<BottomNavigationBarItem> bottomNavBarItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      // const BottomNavigationBarItem(
      //   icon: Icon(Icons.apps),
      //   label: 'Services',
      // ),
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
          _navigateToScreen(index, context);
          onTap(index);
        },
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
    // case 1:
    //   page = Services();
    //   break;
      case 1:
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