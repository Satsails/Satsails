import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Image.asset(
      'lib/assets/app_icon.png',
      width: screenWidth * 0.5, // 50% of screen width
      height: screenHeight * 0.3, // 30% of screen height
    );
  }
}