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
      width: 187.0,
      height: 187.0,
    );
  }
}