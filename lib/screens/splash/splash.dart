import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final dynamicImageSize = screenHeight * 0.2; // 20% of screen height
    final dynamicAnimationSize = screenHeight * 0.05; // 5% of screen height

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'lib/assets/app_icon.png',
              width: dynamicImageSize,
              height: dynamicImageSize,
            ),
            SizedBox(height: screenHeight * 0.03), // 3% of screen height
            LoadingAnimationWidget.threeArchedCircle(size: dynamicAnimationSize, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}