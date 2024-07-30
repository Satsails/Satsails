import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:google_fonts/google_fonts.dart';
import './components/logo.dart';

class Start extends ConsumerWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      style: GoogleFonts.fragmentMono(
                        fontSize: screenWidth * 0.1,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary, // Usar cor secundária do tema
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Opacity(
                      opacity: 0.5,
                      child: Text(
                          'Opt out of the system'.i18n(ref),
                          style: GoogleFonts.fragmentMono(
                            fontSize: screenWidth * 0.05,
                            // color: Theme.of(context).textTheme.bodyText2?.color, // Usar cor de texto do tema
                          )
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Opacity(
                      opacity: 0.5,
                      child: Text(
                          'Beta software, use at your own risk'.i18n(ref),
                          style: GoogleFonts.fragmentMono(
                            fontSize: screenWidth * 0.03,
                            // color: Theme.of(context).textTheme.bodyText2?.color, // Usar cor de texto do tema
                          )
                      ),
                    ),
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
                      ),
                    ],
                  ),
                ),
              ),
              Opacity(
                opacity: 0.5,
                child: Text(
                    'Version: Forward Unto Dawn'.i18n(ref),
                    style: GoogleFonts.fragmentMono(
                      fontSize: screenWidth * 0.03,
                      // color: Theme.of(context).textTheme.bodyText2?.color,
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
