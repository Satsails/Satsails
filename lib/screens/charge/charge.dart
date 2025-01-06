import 'dart:io';

import 'package:Satsails/providers/affiliate_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final isLoadingProvider = StateProvider<bool>((ref) => false);

class Charge extends ConsumerWidget {
  const Charge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final paymentId = ref
        .watch(userProvider)
        .paymentId ?? '';
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // black app bar
        title: Text('Charge Wallet'.i18n(ref),
            style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PaymentMethodCard(
                    title: 'Add Money with Pix'.i18n(ref),
                    description: 'Send a pix and we will credit your wallet'
                        .i18n(ref),
                    icon: Icons.qr_code,
                    screenWidth: screenWidth,
                    onPressed: () => _handleOnPress(ref, context, paymentId),
                  ),
                ],
              ),
            ),
          ),
          // Show loading indicator if the isLoading state is true
          if (isLoading)
            Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                size: MediaQuery
                    .of(context)
                    .size
                    .height * 0.1,
                color: Colors.orange,
              ),
            )
        ],
      ),
    );
  }

  Future<void> _handleOnPress(WidgetRef ref, BuildContext context, String paymentId) async {
    final userHasInsertedAffiliate = ref.watch(userProvider).hasInsertedAffiliate;
    final insertedAffiliateCode = ref.watch(affiliateProvider).insertedAffiliateCode;
    ref.read(isLoadingProvider.notifier).state = true;

    try {
      if (paymentId.isEmpty) {
        await ref.watch(createUserProvider.future);

        FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        if (Platform.isAndroid) {
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();
        } else if (Platform.isIOS) {
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
        }

      } else {
        if (!userHasInsertedAffiliate && insertedAffiliateCode.isNotEmpty) {
          await ref.read(addAffiliateCodeProvider(insertedAffiliateCode).future);
        }
      }

      context.push('/home/pix');
      ref.read(isLoadingProvider.notifier).state = false;
    } catch (e) {
      showBottomOverlayMessage(
        message: e.toString(),
        context: context,
        error: true,
      );

      ref.read(isLoadingProvider.notifier).state = false;
    }
  }
}


class PaymentMethodCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final double screenWidth;
  final VoidCallback? onPressed;

  const PaymentMethodCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.screenWidth,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        color: Colors.black, // black card background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // rounded corners
          side: const BorderSide(color: Colors.white, width: 1), // white border
        ),
        elevation: 0, // no shadow
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.05, horizontal: screenWidth * 0.04), // balanced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.orangeAccent, size: screenWidth * 0.06), // icon size adjustment
                  const SizedBox(width: 12.0),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // white text color
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                description,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: const Color(0xFFB0B0B0), // lighter grey for the description text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
