import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;

import 'package:go_router/go_router.dart';

class Deposit extends ConsumerWidget {
  const Deposit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Deposit".i18n(ref), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DepositOption(
              title: "Credit Card".i18n(ref),
              subtitle: "Transfer in minutes".i18n(ref),
              isAvailable: false,
            ),
            const SizedBox(height: 15),
            _DepositOption(
              title: Platform.isIOS ? "Apple Pay".i18n(ref) : "Google Pay".i18n(ref),
              subtitle: "Transfer in minutes".i18n(ref),
              isAvailable: false,
            ),
            const SizedBox(height: 15),
            _DepositOption(
              title: "PIX".i18n(ref),
              subtitle: "Transfer in minutes".i18n(ref),
              isAvailable: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DepositOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isAvailable;

  const _DepositOption({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.isAvailable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isAvailable
          ? () {
        context.push('/home/explore/deposit/deposit_pix');
      }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _getIconForTitle(),
              size: 30,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (!isAvailable)
              const Text(
                "Coming soon",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle() {
    switch (title) {
      case "Credit Card":
        return Icons.credit_card;
      case "Apple Pay":
        return Icons.apple;
      case "Google Pay":
        return Icons.android;
      case "PIX":
        return Icons.pix;
      default:
        return Icons.help_outline;
    }
  }
}
