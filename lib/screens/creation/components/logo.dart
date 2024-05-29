import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final double? widthFactor;
  final double? heightFactor;

  const Logo({Key? key, this.widthFactor, this.heightFactor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Image.asset(
      'lib/assets/app_icon.png',
      width: screenWidth * (widthFactor ?? 0.5), // Use provided widthFactor or default to 50%
      height: screenHeight * (heightFactor ?? 0.3), // Use provided heightFactor or default to 30%
    );
  }
}