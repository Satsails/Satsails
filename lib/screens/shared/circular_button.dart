import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'dart:math' as math;

Widget buildCircularButton(BuildContext context, icon, String subtitle, VoidCallback onPressed, Color color) {
  final screenHeight = MediaQuery.of(context).size.height;
  const maxIconSize = 30.0; // Set your desired max size
  const maxTextSize = 15.0; // Set your desired max size

  return Column(
    children: [
      GestureDetector(
        onTap: onPressed,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color],
              ),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 25,
              child: Icon(
                icon,
                color: Colors.white,
                size: math.min(screenHeight * 0.04, maxIconSize), // 4% of screen height or maxIconSize, whichever is smaller
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: screenHeight * 0.01), // 1% of screen height
      Text(
        subtitle,
        style: TextStyle(fontSize: math.min(screenHeight * 0.015, maxTextSize), color: Colors.white), // 1.5% of screen height or maxTextSize, whichever is smaller
      ),
    ],
  );
}

Widget buildActionButtons(BuildContext context, WidgetRef ref) {
  final screenHeight = MediaQuery.of(context).size.height;

  return SizedBox(
    height: MediaQuery.of(context).padding.top + kToolbarHeight * 1.1,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildCircularButton(context, Clarity.add_line, 'Add Money'.i18n(ref), () {
          Navigator.pushNamed(context, '/charge');
        }, Colors.black),
        buildCircularButton(context, Clarity.two_way_arrows_line, 'Swaps'.i18n(ref), () {
          Navigator.pushNamed(context, '/exchange');
        }, Colors.black),
        buildCircularButton(context, Clarity.credit_card_line, 'Pay'.i18n(ref), () {
          Navigator.pushNamed(context, '/pay');
        }, Colors.black),
        buildCircularButton(context, TeenyIcons.arrow_down, 'Receive'.i18n(ref), () {
          Navigator.pushNamed(context, '/receive');
        }, Colors.black),
      ],
    ),
  );
}