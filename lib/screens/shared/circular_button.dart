import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';

Widget buildCircularButton(BuildContext context, icon, String subtitle, VoidCallback onPressed, Color color) {
  final screenHeight = MediaQuery.of(context).size.height;

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
              radius: screenHeight * 0.03, // 3% of screen height
              child: Icon(
                icon,
                color: Colors.orange,
                size: screenHeight * 0.04, // 3% of screen height
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: screenHeight * 0.01), // 1% of screen height
      Text(subtitle, style: TextStyle(fontSize: screenHeight * 0.015, color: Colors.black)), // 2% of screen height
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
        }, Colors.white),
        buildCircularButton(context, Clarity.two_way_arrows_line, 'Exchange'.i18n(ref), () {
          Navigator.pushNamed(context, '/exchange');
        }, Colors.white),
        buildCircularButton(context, Clarity.credit_card_line, 'Pay'.i18n(ref), () {
          Navigator.pushNamed(context, '/pay');
        }, Colors.white),
        buildCircularButton(context, TeenyIcons.arrow_down, 'Receive'.i18n(ref), () {
          Navigator.pushNamed(context, '/receive');
        }, Colors.white),
      ],
    ),
  );
}