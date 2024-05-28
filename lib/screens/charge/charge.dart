import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Charge extends ConsumerWidget {
  const Charge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Charge Wallet'.i18n(ref), style: TextStyle(fontSize: screenWidth * 0.05)), // 5% of screen width
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
                description: 'Coming Soon'.i18n(ref),
                icon: Icons.qr_code,
                screenWidth: screenWidth,
              ),
              PaymentMethodCard(
                title: 'Add money with Euro'.i18n(ref),
                description: 'Coming Soon'.i18n(ref),
                icon: Icons.euro,
                screenWidth: screenWidth,
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

  const PaymentMethodCard({Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}