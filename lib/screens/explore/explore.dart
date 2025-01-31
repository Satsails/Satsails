import 'dart:io';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final isLoadingProvider = StateProvider<bool>((ref) => false);

class Explore extends ConsumerWidget {
  const Explore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Explore',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: _BalanceDisplay(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 19.w),
                  child: _ActionGrid(),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
          if (isLoading)
            Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                size: 80.h,
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }
}

class _BalanceDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final denomination = ref.watch(settingsProvider).btcFormat;
    final currency = ref.watch(settingsProvider).currency;
    final totalBtcBalance = ref.watch(totalBalanceInDenominationProvider(denomination));
    final totalBalanceInCurrency = ref.watch(totalBalanceInFiatProvider(currency));

    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          children: [
            Text(
              'Bitcoin balance'.i18n(ref),
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              totalBtcBalance,
              style: TextStyle(
                fontSize: 25.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              currencyFormat(double.parse(totalBalanceInCurrency), currency),
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentId = ref.watch(userProvider).paymentId;

    return Column(
      children: [
        GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 3,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _ActionButton(
              title: 'Buy'.i18n(ref),
              color: Colors.green,
              fontSize: 18,
              onTap: () => _handleOnPress(ref, context, paymentId),
            ),
            _ActionButton(
              title: 'Sell'.i18n(ref),
              color: Colors.red,
              fontSize: 18,
              onTap: () {
                showMessageSnackBar(
                  message: "Coming soon".i18n(ref),
                  context: context,
                  error: true,
                );
              },
            ),
          ],
        ),
        SizedBox(height: 16.h),
        GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.2,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _ActionButton(
              title: 'Services'.i18n(ref),
              color: Colors.grey.shade900,
              fontSize: 16,
              onTap: () {
                showMessageSnackBar(
                  message: "Coming soon".i18n(ref),
                  context: context,
                  error: true,
                );
              },
              icon: Icons.lightbulb,
            ),
            _ActionButton(
              title: 'Store'.i18n(ref),
              color: Colors.grey.shade900,
              fontSize: 16,
              onTap: () {
                showMessageSnackBar(
                  message: "Coming soon".i18n(ref),
                  context: context,
                  error: true,
                );
              },
              icon: Icons.shopping_cart,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;
  final double fontSize;

  const _ActionButton({
    required this.title,
    required this.color,
    required this.onTap,
    this.icon,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, color: Colors.white, size: 20),
              if (icon != null) const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _handleOnPress(
    WidgetRef ref,
    BuildContext context,
    String paymentId,
    ) async {
  final insertedAffiliateCode = ref.watch(userProvider).affiliateCode ?? '';
  final hasUploadedAffiliateCode = ref.watch(userProvider).hasUploadedAffiliateCode ?? false;
  final recoveryCode = ref.watch(userProvider).recoveryCode;

  ref.read(isLoadingProvider.notifier).state = true;

  try {
    // If the user doesn't have a paymentId, we assume they're new and need to be created
    if (paymentId.isEmpty) {
      await ref.watch(createUserProvider.future);

      if (insertedAffiliateCode.isNotEmpty && !hasUploadedAffiliateCode) {
        await ref.read(addAffiliateCodeProvider(insertedAffiliateCode).future);
      }

      // Request notification permissions (Android/iOS)
      await _requestNotificationPermissions();
    } else {
      if (insertedAffiliateCode.isNotEmpty && !hasUploadedAffiliateCode) {
        await ref.read(addAffiliateCodeProvider(insertedAffiliateCode).future);
      }
      // If the user has a recovery code, we migrate them to JWT-based auth
       if (recoveryCode != null && recoveryCode.isNotEmpty) {
        await ref.read(migrateUserToJwtProvider.future);
      }
    }

    context.push('/home/explore/deposit_type');
  } catch (e) {
    // Show any errors in a snack bar
    showMessageSnackBar(
      message: e.toString(),
      context: context,
      error: true,
    );
  } finally {
    // Ensure loading state is turned off, regardless of success or failure
    ref.read(isLoadingProvider.notifier).state = false;
  }
}

Future<void> _requestNotificationPermissions() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  if (Platform.isAndroid) {
    final androidPlugin =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // On some newer Android versions you might still need user permission
    // to display notifications, so we request it if the plugin supports it
    await androidPlugin?.requestNotificationsPermission();
  } else if (Platform.isIOS) {
    final iosPlugin =
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }
}

