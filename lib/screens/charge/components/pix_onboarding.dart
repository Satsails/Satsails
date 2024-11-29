import 'dart:io';

import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/charge/charge.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

class PixOnBoarding extends ConsumerWidget {
  const PixOnBoarding({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.4;
    final isLoading = ref.watch(loadingProvider);
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin();
    if (Platform.isAndroid) {
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();
    } else if (Platform.isIOS) {
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()!
          .requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDB8000),
              Color(0xFF1C1C1E),
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: screenSize.height * 0.1),
            Expanded(
              child: IntroductionScreen(
                pages: [
                  PageViewModel(
                    title: "",
                    bodyWidget: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/assets/wallet.png',
                          height: iconSize,
                        ),
                        SizedBox(height: screenSize.height * 0.03),
                        Text(
                          "Charge your wallet".i18n(ref),
                          style: TextStyle(
                            fontSize: screenSize.width * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
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
                      pageColor: Colors.transparent,
                    ),
                  ),
                  PageViewModel(
                    title: "",
                    bodyWidget: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the content
                      children: [
                        Image.asset(
                          'lib/assets/click.png',
                          height: iconSize,
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        Text(
                          "Get your PIX key".i18n(ref),
                          style: TextStyle(
                            fontSize: screenSize.width * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
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
                      mainAxisAlignment: MainAxisAlignment.center, // Center the content
                      children: [
                        Image.asset(
                          'lib/assets/qr_code.png',
                          height: iconSize,
                        ),
                        SizedBox(height: screenSize.height * 0.03),
                        Text(
                          "Send us a PIX".i18n(ref),
                          style: TextStyle(
                            fontSize: screenSize.width * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
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
                      mainAxisAlignment: MainAxisAlignment.center, // Center the content
                      children: [
                        Image.asset(
                          'lib/assets/support.png',
                          height: iconSize,
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        Text(
                          "Daily limit".i18n(ref),
                          style: TextStyle(
                            fontSize: screenSize.width * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        Text(
                          "Daily transaction limit: BRL 5000. Need to send more? Contact our support.".i18n(ref),
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
                  await ref.read(userProvider.notifier).serOnboarded(true);
                  context.go('/home/pix');
                  ref.read(loadingProvider.notifier).state = false;
                },
                showSkipButton: true,
                skip: Text('Skip'.i18n(ref), style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                next: const Icon(Icons.navigate_next, color: Colors.white),
                done: Text('Done'.i18n(ref), style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                dotsDecorator: DotsDecorator(
                  activeColor: Colors.white,
                  color: Colors.white.withOpacity(0.5),
                ),
                globalBackgroundColor: Colors.transparent,
                controlsPadding: const EdgeInsets.all(16),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                alignment: Alignment.center,
                child: LoadingAnimationWidget.threeArchedCircle(
                  size: MediaQuery.of(context).size.height * 0.1,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

