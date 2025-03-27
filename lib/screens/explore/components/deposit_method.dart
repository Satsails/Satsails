import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io' show Platform;

import 'package:go_router/go_router.dart';
import 'package:Satsails/providers/deposit_type_provider.dart' as helpers;

class DepositMethod extends ConsumerWidget {
  const DepositMethod({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depositMethods = ref.watch(helpers.depositMethodBasedOnTypeProvider);

    final List<_DepositMethodOption> allMethods = [
      _DepositMethodOption(
        title: "PIX".i18n,
        subtitle: "Transfer in minutes".i18n,
        method: helpers.DepositMethod.pix,
      ),
      _DepositMethodOption(
        title: "Credit Card".i18n,
        subtitle: "Transfer in minutes".i18n,
        method: helpers.DepositMethod.credit_card,
      ),
      _DepositMethodOption(
        title: Platform.isIOS ? "Apple Pay".i18n : "Google Pay".i18n,
        subtitle: "Transfer in minutes".i18n,
        method: helpers.DepositMethod.big_tech_pay,
      ),
      _DepositMethodOption(
        title: "Bank Transfer".i18n,
        subtitle: "Transfer in 1-2 days".i18n,
        method: helpers.DepositMethod.bank_transfer,
      ),
    ];

    final availableMethods = allMethods.where((method) => depositMethods.contains(method.method)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Deposit".i18n, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: availableMethods.map((method) => Padding(
            padding: EdgeInsets.only(bottom: 0.02.sh),
            child: method,
          )).toList(),
        ),
      ),
    );
  }
}

class _DepositMethodOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final helpers.DepositMethod method;

  const _DepositMethodOption({
    required this.title,
    required this.subtitle,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/home/explore/deposit_type/deposit_method/deposit_provider');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        child: Row(
          children: [
            Icon(
              _getIconForTitle(),
              size: 25.sp,
              color: Colors.white,
            ),
            SizedBox(width: 0.02.sw),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
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
      case "Bank Transfer":
        return Icons.account_balance;
      default:
        return Icons.help_outline;
    }
  }
}