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
import 'package:Satsails/translations/localizations.dart';

// This provider holds the state for the selected asset.
final selectedAssetProvider = StateProvider<String>((ref) => 'Bitcoin');

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.read(settingsProvider).language;
    final dialogStyle = Platform.isIOS ? UpgradeDialogStyle.cupertino : UpgradeDialogStyle.material;
    final backupNeeded = !ref.watch(settingsProvider).backup;
    final accountString = 'Account'.i18n;

    const scaffoldBackgroundColor = Colors.black;

    return UpgradeAlert(
      dialogStyle: dialogStyle,
      upgrader: Upgrader(
        languageCode: language,
        durationUntilAlertAgain: const Duration(days: 3),
      ),
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: scaffoldBackgroundColor,
          appBar: AppBar(
            toolbarHeight: 35.sp, // Adjusted height for better spacing
            backgroundColor: scaffoldBackgroundColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Padding(
              padding: EdgeInsets.only(left: 20.sp, right: 10.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14.sp,
                        backgroundColor: Colors.white24,
                        child: Text(
                          accountString.substring(0, 1),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        accountString,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined, // Using outlined icon for a modern feel
                      color: Colors.white.withOpacity(0.8),
                      size: 25.sp,
                    ),
                    onPressed: () => context.push('/settings'),
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BalanceScreen(),
                // Conditionally display a prominent backup warning banner
                if (backupNeeded) _buildBackupWarning(context),
                _buildTransactionsHeader(context, ref),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
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

  /// A dedicated header for the transactions list.
  Widget _buildTransactionsHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 15.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Transactions'.i18n,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          HomeCustomButton(
            label: 'Purchase'.i18n, // More standard fintech term
            textColor: Colors.black,
            backgroundColor: Colors.white,
            onPressed: () => context.push('/home/explore/deposit_type'),
          ),
        ],
      ),
    );
  }

  /// A visually distinct banner to alert the user about wallet backup.
  Widget _buildBackupWarning(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/seed_words'),
      child: Container(
        margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFC84141), // A slightly desaturated red
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Backup Wallet'.i18n,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.sp),
          ],
        ),
      ),
    );
  }
}


/// A reusable custom button widget for the Home screen.
class HomeCustomButton extends StatelessWidget {
  const HomeCustomButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFF212121),
          borderRadius: BorderRadius.circular(12.r), // Softer corners
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor ?? textColor ?? Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: 15.sp,
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
      padding: EdgeInsets.fromLTRB(16, 8.h, 16, 8.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 250.h,
        ),
        child: const BalanceCard(),
      ),
    );
  }
}