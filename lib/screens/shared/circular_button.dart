import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildCircularButton(BuildContext context, icon, String subtitle, VoidCallback onPressed, Color color) {
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
              border: Border.all(color: Colors.black.withOpacity(0.7)),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 25,
              child: Icon(
                icon,
                color: Colors.black.withOpacity(0.7),
                size: 25,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(subtitle,style: const TextStyle(fontSize: 10, color: Colors.black)),
    ],
  );
}


Widget buildActionButtons(BuildContext context, WidgetRef ref) {
  return SizedBox(
    height: MediaQuery
        .of(context)
        .padding
        .top + kToolbarHeight + 30,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildCircularButton(context, Icons.add, 'Add Money'.i18n(ref), () {
          Navigator.pushNamed(context, '/charge');
        }, Colors.white),
        buildCircularButton(context, Icons.swap_horizontal_circle, 'Exchange'.i18n(ref),
                () {
              Navigator.pushNamed(context, '/exchange');
            }, Colors.white),
        buildCircularButton(context, Icons.payments, 'Pay'.i18n(ref), () {
          Navigator.pushNamed(context, '/pay');
        }, Colors.white),
        buildCircularButton(
            context, Icons.arrow_downward_sharp, 'Receive'.i18n(ref), () {
          Navigator.pushNamed(context, '/receive');
        }, Colors.white),
      ],
    ),
  );
}