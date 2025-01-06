import 'package:Satsails/helpers/deposit_type.dart' as helpers;
import 'package:Satsails/helpers/swap_helpers.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';

class DepositType extends ConsumerWidget {
  const DepositType({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Deposit Type".i18n(ref), style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.02.sh, horizontal: 0.02.sw),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DepositOption(
              title: "Depix".i18n(ref),
              subtitle: "Transfer in minutes".i18n(ref),
              isAvailable: true,
              onTap: () => handleDepixSelection(context, ref),
            ),
            SizedBox(height: 0.02.sh),
            _DepositOption(
              title: "Bitcoin".i18n(ref),
              subtitle: "Coming soon".i18n(ref),
              isAvailable: false,
            ),
            SizedBox(height: 0.02.sh),
            _DepositOption(
              title: "Lightning Bitcoin".i18n(ref),
              subtitle: "Coming soon".i18n(ref),
              isAvailable: false,
            ),
            SizedBox(height: 0.02.sh),
            _DepositOption(
              title: "USDT".i18n(ref),
              subtitle: "Coming soon".i18n(ref),
              isAvailable: false,
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
  final VoidCallback? onTap;

  const _DepositOption({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.isAvailable,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isAvailable ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 0.02.sh, horizontal: 0.02.sw),
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

void handleDepixSelection(BuildContext context, WidgetRef ref) {
  ref.read(helpers.depositTypeProvider.notifier).state = helpers.DepositType.depix;
  context.push('/home/explore/deposit_type/deposit_method');
}
