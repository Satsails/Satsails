import 'dart:io';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/transactions_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/screens/shared/balance_card.dart';
import 'package:go_router/go_router.dart';
import 'package:upgrader/upgrader.dart';
import 'package:Satsails/translations/translations.dart';

// This provider holds the state for the selected asset.
final selectedAssetProvider = StateProvider<String>((ref) => 'Bitcoin');

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.read(settingsProvider).language;
    final dialogStyle = Platform.isIOS ? UpgradeDialogStyle.cupertino : UpgradeDialogStyle.material;
    final backupNeeded = !ref.watch(settingsProvider).backup;

    return UpgradeAlert(
      dialogStyle: dialogStyle,
      upgrader: Upgrader(
        languageCode: language,
        durationUntilAlertAgain: const Duration(days: 3),
      ),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          body: SafeArea(
            bottom: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BalanceScreen(),
                _buildHeaderRow(context, ref, backupNeeded),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: TransactionList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, WidgetRef ref, bool backupNeeded) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (backupNeeded)
            _buildBackupButton(context)
          else
            Padding(
              padding: EdgeInsets.only(left: 8.0.sp),
              child: Text(
                'Transactions'.i18n,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          _buildBuyButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildBackupButton(BuildContext context) {
    return CustomButton(
      icon: Icons.warning_amber_rounded,
      label: 'Backup Wallet'.i18n,
      iconColor: Colors.red,
      textColor: Colors.white,
      backgroundColor: const Color(0xFF333333).withOpacity(0.4),
      onPressed: () => context.push('/seed_words'),
    );
  }

  Widget _buildBuyButton(BuildContext context, WidgetRef ref) {
    return CustomButton(
      icon: Icons.add,
      label: 'Add money'.i18n,
      iconColor: Colors.black,
      textColor: Colors.black,
      backgroundColor: Colors.white.withOpacity(0.9),
      onPressed: () => ref.read(navigationProvider.notifier).state = 3,
    );
  }
}

/// A reusable custom button widget.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.fontSize,
    this.iconWeight,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? fontSize;
  final double? iconWeight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFF212121),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Allows the button to shrink to its content size
          children: <Widget>[
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor ?? textColor ?? Colors.white,
                size: 20.sp,
                weight: iconWeight,
              ),
              SizedBox(width: 10.w),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: fontSize ?? 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 250.h,
        ),
        child: const BalanceCard(),
      ),
    );
  }
}