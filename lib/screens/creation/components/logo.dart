import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final double? widthFactor;
  final double? heightFactor;

  const Logo({super.key, this.widthFactor, this.heightFactor});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Image.asset(
      'lib/assets/app_icon.png',
      width: screenWidth * (widthFactor ?? 0.7),
      height: screenHeight * (heightFactor ?? 0.5),
    );
  }
}