import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

final onBoardingInProgressProvider = StateProvider<bool>((ref) => false);

class Charge extends ConsumerWidget {
  const Charge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final hasOnboarded = ref.watch(userProvider).onboarded ?? false;
    final paymentId = ref.watch(userProvider).paymentId ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // black app bar
        title: Text('Charge Wallet'.i18n(ref), style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PaymentMethodCard(
                title: 'Add Money with Pix'.i18n(ref),
                description: 'Send a pix and we will credit your wallet'.i18n(ref),
                icon: Icons.qr_code,
                screenWidth: screenWidth,
                onPressed: () => _handleOnPress(ref, context, hasOnboarded, paymentId),
              ),
              const SizedBox(height: 16.0),
              PaymentMethodCard(
                title: 'Add money with EURx'.i18n(ref),
                description: 'Coming Soon'.i18n(ref),
                icon: Icons.euro,
                screenWidth: screenWidth,
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleOnPress(WidgetRef ref, BuildContext context, bool hasOnboarded, String paymentId) async {
    // If the user doesn't have a payment ID, prompt onboarding
    if (paymentId.isEmpty) {
      ref.read(onBoardingInProgressProvider.notifier).state = true;
      Navigator.of(context).pushNamed('/user_creation');
      return;
    }

    try {
      final walletBelongsToUser = await ref.watch(
          checkIfAccountBelongsToSetPrivateKeyProvider.future);

      if (walletBelongsToUser == false) {
        Fluttertoast.showToast(
          msg: 'Your wallet does not belong to the account you are trying to charge'.i18n(ref),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 4,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().i18n(ref),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 4,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    if (hasOnboarded) {
      Navigator.of(context).pushNamed('/pix');
    } else {
      Navigator.of(context).pushNamed('/pix_onboarding');
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
