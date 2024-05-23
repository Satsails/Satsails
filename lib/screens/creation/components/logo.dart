import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/assets/app_icon.png',
      width: 500,
      height: 300,
    );
  }
}
