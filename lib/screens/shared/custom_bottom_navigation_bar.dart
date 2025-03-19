import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

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
        icon: Icon(Icons.settings, size: iconSize),
        selectedColor: Colors.orangeAccent,
        unselectedColor: Colors.white,
      ),
    ];

    return DotNavigationBar(
      items: bottomBarItems,
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      backgroundColor: Color(0xFF212121),// Transparent background
      dotIndicatorColor: Colors.transparent, // No dot indicator
      unselectedItemColor: Colors.grey[300], // Light grey for unselected items
      margin: const EdgeInsets.only(bottom: 20),
      marginR: const EdgeInsets.only(bottom: 20),
      splashColor: Colors.transparent, // Orange color for splash effect
    );
  }
}