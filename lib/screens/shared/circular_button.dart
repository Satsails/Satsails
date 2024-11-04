import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  return SizedBox(
    height: MediaQuery.of(context).padding.top + kToolbarHeight * 1.1,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildCircularButton(context, Icons.add, 'Add Money'.i18n(ref), () {
          context.push('/home/charge');
        }, Colors.black),
        buildCircularButton(context, Icons.compare_arrows, 'Swaps'.i18n(ref), () {
          context.push('/home/exchange');
        }, Colors.black),
        buildCircularButton(context, Icons.credit_card, 'Pay'.i18n(ref), () {
          context.push('/home/pay');
        }, Colors.black),
        buildCircularButton(context, Icons.arrow_downward_outlined, 'Receive'.i18n(ref), () {
          context.push('/home/receive');
        }, Colors.black),
      ],
    ),
  );
}