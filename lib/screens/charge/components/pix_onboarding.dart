import 'package:Satsails/providers/create_user_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:introduction_screen/introduction_screen.dart';

class PixOnBoarding extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(settingsProvider.notifier).setPixOnboarding(false);
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome to charging your wallet with Pix!",
          body: "Here you will be able to add money to your wallet using Pix",
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
          body: "Simply send a pix to the code and you must send the code we provide to you so that we can credit your wallet",
          image: Center(
            child: Image.asset('assets/images/pix_logo.png', height: 200.0),
          ),
          decoration: const PageDecoration(
            pageColor: Colors.white,
            bodyTextStyle: TextStyle(fontSize: 20),
            titleTextStyle: TextStyle(fontSize: 30),
          ),
        ),
        PageViewModel(
          title: "Didn't get send the code or sent it wrong?",
          body: "Contact us via our support in settings with your cpf the date and the amount sent, so we can credit your wallet",
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
      onDone: () async {
        try {
          await ref.read(settingsProvider.notifier).setPixOnboarding(true);
          final paymentId = await ref.read(settingsProvider.notifier).setPixPaymentCode();
          final liquidAddress = await ref.read(liquidAddressProvider.future);
          await ref.read(createUserProvider).sendPostRequest(paymentId, liquidAddress.confidential);
          ref.refresh(settingsProvider);
          Navigator.of(context).pushNamed('/pix');
        } catch (e) {
          Fluttertoast.showToast(msg: 'There was an error saving your code. Please try again or contact support', toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.TOP, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
        }
      },
      showSkipButton: true,
      skip: const Text('Skip'),
      next: const Icon(Icons.navigate_next),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
