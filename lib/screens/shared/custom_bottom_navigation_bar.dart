import 'package:Satsails/translations/translations.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNavigationBar extends ConsumerStatefulWidget {
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

class _CustomBottomNavigationBarState extends ConsumerState<CustomBottomNavigationBar> {
  late NotchBottomBarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotchBottomBarController(index: widget.currentIndex);
  }

  @override
  void didUpdateWidget(CustomBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _controller.jumpTo(widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = 10.h;
    final iconSize = 25.sp;

    List<BottomBarItem> bottomBarItems = [
      BottomBarItem(
        inActiveItem: Icon(
          Icons.home,
          size: iconSize,
          color: Colors.white,
        ),
        activeItem: Icon(
          Icons.home,
          size: iconSize,
          color: Colors.orangeAccent,
        ),
        itemLabel: 'Home'.i18n,
      ),
      BottomBarItem(
        inActiveItem: Icon(
          Icons.add,
          size: iconSize,
          color: Colors.white,
        ),
        activeItem: Icon(
          Icons.add,
          size: iconSize,
          color: Colors.orangeAccent,
        ),
        itemLabel: 'Explore'.i18n,
      ),
      BottomBarItem(
        inActiveItem: Icon(
          Icons.swap_horiz_rounded,
          size: iconSize,
          color: Colors.white,
        ),
        activeItem: Icon(
          Icons.swap_horiz_rounded,
          size: iconSize,
          color: Colors.orangeAccent,
        ),
        itemLabel: 'Swap'.i18n,
      ),
      BottomBarItem(
        inActiveItem: Icon(
          Icons.history,
          size: iconSize,
          color: Colors.white,
        ),
        activeItem: Icon(
          Icons.history,
          size: iconSize,
          color: Colors.orangeAccent,
        ),
        itemLabel: 'History'.i18n,
      ),
      BottomBarItem(
        inActiveItem: Icon(
          Icons.settings,
          size: iconSize,
          color: Colors.white,
        ),
        activeItem: Icon(
          Icons.settings,
          size: iconSize,
          color: Colors.orangeAccent,
        ),
        itemLabel: 'Settings'.i18n,
      ),
    ];

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: AnimatedNotchBottomBar(
        bottomBarItems: bottomBarItems,
        onTap: widget.onTap,
        kIconSize: 16.sp,      // Responsive icon size
        kBottomRadius: 10.r,   // Responsive radius
        showLabel: false,
        notchBottomBarController: _controller,
        color: const Color(0xFF212121),
        notchColor: const Color(0xFF212121),
        durationInMilliSeconds: 100,
      ),
    );
  }
}