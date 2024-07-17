import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:introduction_screen/introduction_screen.dart';

class PixOnBoarding extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.4;

    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Charge your wallet".i18n(ref),
          body: "Get Real stablecoins, and convert them to Bitcoin".i18n(ref),
          image: Center(
            child: Icon(Icons.currency_bitcoin_outlined, size: iconSize, color: Colors.orange),
          ),
          decoration: const PageDecoration(
            pageColor: Colors.white,
            bodyTextStyle: TextStyle(fontSize: 20),
            titleTextStyle: TextStyle(fontSize: 30, color: Colors.orange),
          ),
        ),
        PageViewModel(
          title: "Simply send us a pix with your unique code".i18n(ref),
          body: "Send a pix with the to the key we provide you, and we will credit your wallet".i18n(ref),
          image: Center(
            child: Brand(Brands.pix, size: iconSize),
          ),
          decoration: const PageDecoration(
            pageColor: Colors.white,
            bodyTextStyle: TextStyle(fontSize: 20),
            titleTextStyle: TextStyle(fontSize: 30, color: Colors.orange),
          ),
        ),
        PageViewModel(
          title: "Your wallet did not get credited?".i18n(ref),
          body: "Contact us via our support in settings and we will help you".i18n(ref),
          image: Center(
            child: Icon(Clarity.error_solid, size: iconSize, color: Colors.red),
          ),
          decoration: const PageDecoration(
            pageColor: Colors.white,
            bodyTextStyle: TextStyle(fontSize: 20),
            titleTextStyle: TextStyle(fontSize: 30, color: Colors.orange),
          ),
        ),
        PageViewModel(
          title: "You can not send more than 5000 BRL per day".i18n(ref),
          body: "If you need to send more, contact us via our support in settings, and we will help you".i18n(ref),
          image: Center(
            child: Icon(Clarity.add_line, size: iconSize, color: Colors.orange),
          ),
          decoration: const PageDecoration(
            pageColor: Colors.white,
            bodyTextStyle: TextStyle(fontSize: 20),
            titleTextStyle: TextStyle(fontSize: 30, color: Colors.orange),
          ),
        ),
      ],
      onDone: () async {
        try {
          await ref.read(settingsProvider.notifier).setPixOnboarding(true);
          final paymentId = await ref.read(settingsProvider.notifier).setPixPaymentCode();
          final liquidAddress = await ref.read(liquidAddressProvider.future);
          UserArguments userArguments = UserArguments(paymentId: paymentId, liquidAddress: liquidAddress.confidential);
          final message = await ref.read(createUserProvider(userArguments).future);
          Fluttertoast.showToast(
            msg: message.i18n(ref),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Navigator.of(context).pushNamed('/pix');
        } catch (e) {
          await ref.read(settingsProvider.notifier).setPixOnboarding(false);
          Fluttertoast.showToast(
            msg: 'There was an error saving your code. Please try again or contact support'.i18n(ref),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      },
      showSkipButton: true,
      skip: Text('Skip'.i18n(ref), style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange)),
      next: Icon(Icons.navigate_next, color: Colors.orange),
      done: Text('Done'.i18n(ref), style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange)),
      dotsDecorator: DotsDecorator(
        activeColor: Colors.orange,
        color: Colors.orange.withOpacity(0.5),
      ),
      globalBackgroundColor: Colors.white,
      controlsPadding: const EdgeInsets.all(16),
    );
  }
}
