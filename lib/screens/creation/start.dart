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
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(
                height: 30.0,
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
                      style: GoogleFonts.roboto(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Opacity(
                      opacity: 0.5,
                      child: Text(
                        'Sail your wealth to the cloud'.i18n(ref),
                        style: const TextStyle(
                          fontSize: 25.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Opacity(
                      opacity: 0.5,
                      child: Text(
                        'Opt out of the system'.i18n(ref),
                        style: const TextStyle(
                          fontSize: 25.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Opacity(
                      opacity: 0.5,
                      child: Text(
                        'Beta software, use at your own risk'.i18n(ref),
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      CustomButton(
                        text: 'Register Account'.i18n(ref),
                        onPressed: () {
                          Navigator.pushNamed(context, '/set_pin');
                        },
                      ),
                      const SizedBox(height: 10),
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
            ],
          ),
        ),
      ),
    );
  }
}