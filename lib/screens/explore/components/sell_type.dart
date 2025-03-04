import 'package:Satsails/providers/deposit_type_provider.dart' as helpers;
import 'package:Satsails/helpers/swap_helpers.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';

class SellType extends ConsumerWidget {
  const SellType({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selling Type".i18n, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SellOption(
              title: "Bitcoin".i18n,
              subtitle: "Transfer 15-30 minutes".i18n,
              isAvailable: true,
              onTap: () => handleBitcoinSelection(context, ref),
            ),
            SizedBox(height: 0.02.sh),
            _SellOption(
              title: "Depix".i18n,
              subtitle: "Coming soon".i18n,
              isAvailable: false,
            ),
            SizedBox(height: 0.02.sh),
            _SellOption(
              title: "Lightning Bitcoin".i18n,
              subtitle: "Coming soon".i18n,
              isAvailable: false,
            ),
            SizedBox(height: 0.02.sh),
            _SellOption(
              title: "USDT".i18n,
              subtitle: "Coming soon".i18n,
              isAvailable: false,
            ),
            SizedBox(height: 0.02.sh),
            _SellOption(
              title: "Liquid Bitcoin".i18n,
              subtitle: "Coming soon".i18n,
              isAvailable: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _SellOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isAvailable;
  final VoidCallback? onTap;

  const _SellOption({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.isAvailable,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        padding:EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        child: Row(
          children: [
            getAssetImage(title, width: 28.0.sp, height: 28.0.sp),  // Use getAssetImage function here
            SizedBox(width: 0.025.sw),
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
}

void handleBitcoinSelection(BuildContext context, WidgetRef ref) {
  ref.read(helpers.depositTypeProvider.notifier).state = helpers.DepositType.bitcoin;
  context.push('/home/explore/deposit_type/deposit_method');
}
