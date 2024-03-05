import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';
import '../../apps/apps.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final BuildContext context; // Add this line to store the context

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        List<BottomNavigationBarItem> bottomNavBarItems = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
        ];

        bottomNavBarItems.insert(
          1,
          const BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'Apps',
          ),
        );

        return Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            currentIndex: currentIndex,
            onTap: (index) {
              _navigateToScreen(index); // Call the navigation method
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
      },
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
      case 1:
        Navigator.pushNamed(context, '/apps');
      case 2:
        Navigator.pushNamed(context, '/analytics');
    }
  }
}
