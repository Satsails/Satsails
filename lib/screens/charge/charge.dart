import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Charge extends ConsumerWidget {
  const Charge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Charge Wallet'.i18n(ref), style: TextStyle(fontSize: screenWidth * 0.05)),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PaymentMethodCard(
                title: 'Add Money with Pix'.i18n(ref),
                description: 'Buy using telegram'.i18n(ref),
                icon: Icons.qr_code,
                screenWidth: screenWidth,
                onPressed: () => Navigator.pushNamed(context, '/pix')
              ),
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
}

class PaymentMethodCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final double screenWidth;
  final VoidCallback? onPressed;

  const PaymentMethodCard({super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.screenWidth,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed, // Handle tap action
      child: Card(
        elevation: 4.0,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05), // 5% of screen width
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.orangeAccent, size: screenWidth * 0.06), // 6% of screen width
                  const SizedBox(width: 8.0),
                  Text(
                    title,
                    style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold), // 4.5% of screen width
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                description,
                style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey), // 4% of screen width
              ),
            ],
          ),
        ),
      ),
    );
  }
}
