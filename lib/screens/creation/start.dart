import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:google_fonts/google_fonts.dart';
import './components/logo.dart';

class Start extends ConsumerWidget {
  const Start({super.key});

  Shader createGradientShader(Rect bounds) {
    return LinearGradient(
      colors: [Colors.redAccent, Colors.orangeAccent],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(bounds);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.03,
              ),
              const Expanded(
                flex: 1,
                child: Center(
                  child: Logo(),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Satsails',
                      style: TextStyle(
                        foreground: Paint()
                          ..shader = createGradientShader(
                            Rect.fromLTWH(0.0, 0.0, screenWidth * 0.6, screenHeight * 0.1),
                          ),
                        fontSize: screenWidth * 0.15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                        'Become sovereign and freely opt out of the system.'.i18n(ref),
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.02), // 2% of screen width
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.01), // 1% of screen height
                      CustomButton(
                        text: 'Register Account'.i18n(ref),
                        onPressed: () {
                          Navigator.pushNamed(context, '/set_pin');
                        },
                      ),
                      SizedBox(height: screenHeight * 0.01), // 1% of screen height
                      CustomButton(
                        text: 'Recover Account'.i18n(ref),
                        onPressed: () {
                          Navigator.pushNamed(context, '/recover_wallet');
                        },
                        primaryColor: Colors.black,
                        secondaryColor: Colors.black
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
