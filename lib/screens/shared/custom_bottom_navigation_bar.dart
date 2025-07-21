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

    final List<DotNavigationBarItem> bottomBarItems = [
      DotNavigationBarItem(
        icon: Icon(Icons.home, size: iconSize),
        selectedColor: Colors.orangeAccent,
        unselectedColor: Colors.white,
      ),
      DotNavigationBarItem(
        icon: Icon(Icons.bar_chart, size: iconSize),
        selectedColor: Colors.orangeAccent,
        unselectedColor: Colors.white,
      ),
      DotNavigationBarItem(
        icon: Icon(Icons.swap_horiz, size: iconSize),
        selectedColor: Colors.orangeAccent,
        unselectedColor: Colors.white,
      ),
      DotNavigationBarItem(
        icon: Icon(Icons.add, size: iconSize),
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
      enablePaddingAnimation:false,
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      backgroundColor: const Color(0x00333333).withOpacity(0.4),
      dotIndicatorColor: Colors.transparent,
      unselectedItemColor: Colors.grey[300],
      splashColor: Colors.transparent,
      marginR: EdgeInsets.zero,
      itemPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
    );
  }
}