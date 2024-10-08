import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Logo extends StatelessWidget {
  final double? widthFactor;
  final double? heightFactor;

  const Logo({super.key, this.widthFactor, this.heightFactor});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SvgPicture.asset(
      'lib/assets/satsails.svg',
      width: screenWidth * (widthFactor ?? 0.9),
      height: screenHeight * (heightFactor ?? 0.25),
    );
  }
}