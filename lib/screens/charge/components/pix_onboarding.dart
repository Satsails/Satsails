import 'package:Satsails/providers/pix_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

class PixOnBoarding extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.4;
    final isLoading = ref.watch(loadingProvider);

    return Stack(
      children: [
        IntroductionScreen(
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
            ref.read(loadingProvider.notifier).state = true;
            try {
              await ref.read(pixProvider.notifier).setPixOnboarding(true);
              var paymentId = ref.read(pixProvider).pixPaymentCode;
              if (paymentId == "") {
                paymentId = await ref.read(createUserProvider.future);
              }
              final message = 'Wallet unique id created successfully'.i18n(ref);
              Fluttertoast.showToast(
                msg: message.i18n(ref),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              await ref.read(pixProvider.notifier).setPixOnboarding(true);
              Navigator.of(context).pushReplacementNamed('/pix');
            } catch (e) {
              await ref.read(pixProvider.notifier).setPixOnboarding(false);
              Fluttertoast.showToast(
                msg: 'There was an error saving your code. Please try again or contact support'.i18n(ref),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            } finally {
              ref.read(loadingProvider.notifier).state = false;
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
        ),
        if (isLoading)
          Padding(
            padding: EdgeInsets.only(bottom: screenSize.height * 0.1),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: LoadingAnimationWidget.threeArchedCircle(
                size: MediaQuery.of(context).size.height * 0.1,
                color: Colors.orange,
              ),
            ),
          ),
      ],
    );
  }
}
