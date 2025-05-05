import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Logo extends StatelessWidget {
  final double? widthFactor;
  final double? heightFactor;

  const Logo({super.key, this.widthFactor, this.heightFactor});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'lib/assets/satsails.svg',
      fit: BoxFit.contain, // Ensures the SVG scales proportionally
    );
  }
}


class InitialLogo extends StatelessWidget {
  const InitialLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/assets/initialLogo.png',
      fit: BoxFit.contain,
    );
  }
}