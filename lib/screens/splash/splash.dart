import 'package:flutter/material.dart';

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
              'lib/assets/SatSails.png',
              width: 200,  // Adjust as needed
              height: 200, // Adjust as needed
            ),
            SizedBox(height: 30), // Adjust as needed
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}