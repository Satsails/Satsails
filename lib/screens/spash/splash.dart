import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dynamicAnimationSize = screenHeight * 0.05; // 5% of screen height

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'lib/assets/satsails.svg',
            ),
            SizedBox(height: screenHeight * 0.03),
            LoadingAnimationWidget.threeArchedCircle(size: dynamicAnimationSize, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}