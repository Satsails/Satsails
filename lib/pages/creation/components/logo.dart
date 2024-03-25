import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/assets/SatSailsWhite.png',
      width: 200,
      height: 200,
    );
  }
}
