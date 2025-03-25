import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  _CustomBottomNavigationBarState createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final iconSize = 25.0.sp;

    // List of navigation items
    final List<DotNavigationBarItem> bottomBarItems = [
      DotNavigationBarItem(
        icon: Icon(Icons.home, size: iconSize),
        selectedColor: Colors.orangeAccent,
        unselectedColor: Colors.white,
      ),
      DotNavigationBarItem(
        icon: Icon(Icons.add, size: iconSize),
        selectedColor: Colors.orangeAccent,
        unselectedColor: Colors.white,
      ),
      DotNavigationBarItem(
        icon: Icon(Icons.swap_horiz_rounded, size: iconSize),
        selectedColor: Colors.orangeAccent,
        unselectedColor: Colors.white,
      ),
      DotNavigationBarItem(
        icon: Icon(Icons.history, size: iconSize),
        selectedColor: Colors.orangeAccent,
        unselectedColor: Colors.white,
      ),
      DotNavigationBarItem(
        icon: Icon(Icons.wallet, size: iconSize),
        selectedColor: Colors.orangeAccent,
        unselectedColor: Colors.white,
      ),
      DotNavigationBarItem(
        icon: Icon(Icons.settings, size: iconSize),
        selectedColor: Colors.orangeAccent,
        unselectedColor: Colors.white,
      ),
    ];

    return DotNavigationBar(
      items: bottomBarItems,
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      backgroundColor: const Color(0xFF212121), // Your preferred background color
      dotIndicatorColor: Colors.transparent,
      unselectedItemColor: Colors.grey[300],
      marginR: EdgeInsets.zero, // Key change to remove external space
      splashColor: Colors.transparent,
    );
  }
}