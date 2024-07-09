import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';

class PixOnBoarding extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(settingsProvider.notifier).setPixOnboarding(false);
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome to Satsails",
          body: "We are happy to have you here",
          image: Center(
            child: Image.asset('assets/images/satsails_logo.png', height: 200.0),
          ),
          decoration: const PageDecoration(
            pageColor: Colors.white,
            bodyTextStyle: TextStyle(fontSize: 20),
            titleTextStyle: TextStyle(fontSize: 30),
          ),
        ),
        PageViewModel(
          title: "Add Money with Pix",
          body: "Buy using telegram",
          image: Center(
            child: Image.asset('assets/images/pix_logo.png', height: 200.0),
          ),
          decoration: const PageDecoration(
            pageColor: Colors.white,
            bodyTextStyle: TextStyle(fontSize: 20),
            titleTextStyle: TextStyle(fontSize: 30),
          ),
        ),
      ],
      onDone: () {
        ref.read(settingsProvider.notifier).setPixOnboarding(true);
        ref.read(settingsProvider.notifier).setPixPaymentCode();
        ref.refresh(settingsProvider);
        Navigator.of(context).pushNamed('/pix');
      },
      showSkipButton: true,
      skip: const Text('Skip'),
      next: const Icon(Icons.navigate_next),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}