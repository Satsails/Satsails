import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/assets/SatSails.png',
      width: 300,
      height: 300,
    );
  }
}
