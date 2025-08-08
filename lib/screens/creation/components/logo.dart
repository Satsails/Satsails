import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Logo extends StatelessWidget {
  final Color color;
  final double opacity;
  final double? size;

  const Logo({
    super.key,
    this.color = Colors.white,
    this.opacity = 1.0,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'lib/assets/satsails.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(
        color.withOpacity(opacity),
        BlendMode.srcIn,
      ),
    );
  }
}