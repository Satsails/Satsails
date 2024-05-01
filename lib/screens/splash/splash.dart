import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

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
              width: 200,  // Adjust as needed
              height: 200, // Adjust as needed
            ),
            SizedBox(height: 30), // Adjust as needed
            LoadingAnimationWidget.threeArchedCircle(size: 50, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}