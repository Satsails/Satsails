import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'lib/assets/satsails.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 30),
            LoadingAnimationWidget.threeArchedCircle(size: 50, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}