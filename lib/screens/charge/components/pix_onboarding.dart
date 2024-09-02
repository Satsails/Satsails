import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/charge/charge.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

class PixOnBoarding extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.4;
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDB8000), // Top color (orange gradient)
              Color(0xFF1C1C1E), // Bottom color (dark gradient)
            ],
          ),
        ),
        child: Stack(
          children: [
            IntroductionScreen(
              pages: [
                PageViewModel(
                  title: "",
                  bodyWidget: Column(
                    children: [
                      Image.asset(
                        'lib/assets/wallet.png',
                        height: iconSize,
                      ),
                      SizedBox(height: screenSize.height * 0.05),
                      Text(
                        "Charge your wallet".i18n(ref),
                        style: TextStyle(
                          fontSize: screenSize.width * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.05),
                      Text(
                        "Add funds to your wallet. Convert stablecoins to Bitcoin quickly and easily.".i18n(ref),
                        style: TextStyle(
                          fontSize: screenSize.width * 0.04,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  decoration: const PageDecoration(
                    pageColor: Colors.transparent, // Transparent to show the gradient background
                  ),
                ),
                PageViewModel(
                  title: "",
                  bodyWidget: Column(
                    children: [
                      Image.asset(
                        'lib/assets/click.png',
                        height: iconSize,
                      ),
                      SizedBox(height: screenSize.height * 0.05),
                      Text(
                        "Get your PIX key".i18n(ref),
                        style: TextStyle(
                          fontSize: screenSize.width * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.05),
                      Text(
                        "Receive an exclusive Pix key to add funds. This key is unique for each transaction.".i18n(ref),
                        style: TextStyle(
                          fontSize: screenSize.width * 0.04,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  decoration: const PageDecoration(
                    pageColor: Colors.transparent,
                  ),
                ),
                PageViewModel(
                  title: "",
                  bodyWidget: Column(
                    children: [
                      Image.asset(
                        'lib/assets/qr_code.png',
                        height: iconSize,
                      ),
                      SizedBox(height: screenSize.height * 0.05),
                      Text(
                        "Send us a PIX".i18n(ref),
                        style: TextStyle(
                          fontSize: screenSize.width * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.05),
                      Text(
                        "Make a Pix payment using the provided exclusive key. Your funds will be credited to your wallet.".i18n(ref),
                        style: TextStyle(
                          fontSize: screenSize.width * 0.04,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  decoration: const PageDecoration(
                    pageColor: Colors.transparent,
                  ),
                ),
                PageViewModel(
                  title: "",
                  bodyWidget: Column(
                    children: [
                      Image.asset(
                        'lib/assets/support.png',
                        height: iconSize,
                      ),
                      SizedBox(height: screenSize.height * 0.05),
                      Text(
                        "Daily limit".i18n(ref),
                        style: TextStyle(
                          fontSize: screenSize.width * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.05),
                      Text(
                        "Daily transaction limit: R\$ 5000. Need to send more? Contact our support.".i18n(ref),
                        style: TextStyle(
                          fontSize: screenSize.width * 0.04,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  decoration: const PageDecoration(
                    pageColor: Colors.transparent,
                  ),
                ),
              ],
              onDone: () async {
                ref.read(loadingProvider.notifier).state = true;
                ref.read(onBoardingInProgressProvider.notifier).state = false;
                await ref.read(userProvider.notifier).serOnboarded(true);
                Navigator.of(context).pushReplacementNamed('/pix');
                ref.read(loadingProvider.notifier).state = false;
              },
              showSkipButton: true,
              skip: Text('Skip'.i18n(ref), style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
              next: Icon(Icons.navigate_next, color: Colors.white),
              done: Text('Done'.i18n(ref), style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
              dotsDecorator: DotsDecorator(
                activeColor: Colors.white,
                color: Colors.white.withOpacity(0.5),
              ),
              globalBackgroundColor: Colors.transparent,
              controlsPadding: const EdgeInsets.all(16),
            ),
            if (isLoading)
              Padding(
                padding: EdgeInsets.only(bottom: screenSize.height * 0.1),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: LoadingAnimationWidget.threeArchedCircle(
                    size: MediaQuery.of(context).size.height * 0.1,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
