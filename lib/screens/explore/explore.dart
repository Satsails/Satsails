import 'dart:io';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/shared/custom_bottom_navigation_bar.dart';
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

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: ref.watch(navigationProvider),
          onTap: (int index) {
            ref.read(navigationProvider.notifier).state = index;
          },
        ),
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Text(
            'Explore',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
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
                      vertical: 8.h,
                    ),
                    child: _BalanceDisplay(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 19.w),
                    child: _ActionCards(), // Two separate types of cards
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

    final depixBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).brlBalance);
    final usdBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).usdBalance);
    final euroBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).eurBalance);

    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Text(
              'Your Balances'.i18n,
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.h),

            // Bitcoin Balance Row
            _buildBalanceRow(
              imagePath: 'lib/assets/bitcoin-logo.png',
              color: const Color(0xFFFF9800), // Bitcoin orange
              label: 'Bitcoin'.i18n,
              balance: totalBtcBalance,
              fiatValue: currencyFormat(double.parse(totalBalanceInCurrency), currency),
            ),
            SizedBox(height: 12.h),
            _buildBalanceRow(
              imagePath: 'lib/assets/depix.png',
              color: const Color(0xFF009C3B), // Depix green
              label: 'Depix'.i18n,
              balance: depixBalance.toString(),
              fiatValue: '',
            ),
            SizedBox(height: 12.h),
            _buildBalanceRow(
              imagePath: 'lib/assets/eurx.png',
              color: const Color(0xFF003399), // Euro blue
              label: 'EURx'.i18n,
              balance: euroBalance.toString(),
              fiatValue: '',
            ),
            SizedBox(height: 12.h),
            _buildBalanceRow(
              imagePath: 'lib/assets/tether.png',
              color: const Color(0xFF008001), // USDT green (adjusted to match branding)
              label: 'USDT'.i18n,
              balance: usdBalance.toString(),
              fiatValue: '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceRow({
    required String imagePath,
    required Color color,
    required String label,
    required String balance,
    required String fiatValue,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          child: ClipOval(
            child: Image.asset(
              imagePath,
              width: 24.sp,
              height: 24.sp,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                balance,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (fiatValue.isNotEmpty)
                Text(
                  fiatValue,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionCards extends ConsumerWidget {
  const _ActionCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentId = ref.watch(userProvider).paymentId;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.green,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _handleOnPress(ref, context, paymentId, true),
                  child: Container(
                    height: 80.h,
                    alignment: Alignment.center,
                    child: Text(
                      'Buy'.i18n,
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.red,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    showMessageSnackBar(
                      message: "Coming soon".i18n,
                      context: context,
                      error: true,
                    );
                  },
                  child: Container(
                    height: 80.h,
                    alignment: Alignment.center,
                    child: Text(
                      'Sell'.i18n,
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.grey.shade900,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    showMessageSnackBar(
                      message: "Coming soon".i18n,
                      context: context,
                      error: true,
                    );
                  },
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lightbulb, color: Colors.white, size: 20),
                          SizedBox(width: 8.w),
                          Text(
                            'Services'.i18n,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.grey.shade900,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    showMessageSnackBar(
                      message: "Coming soon".i18n,
                      context: context,
                      error: true,
                    );
                  },
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart,color: Colors.white, size: 20),
                          SizedBox(width: 8.w),
                          Text(
                            'Store'.i18n,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> _handleOnPress(
    WidgetRef ref,
    BuildContext context,
    String paymentId,
    bool buy
    ) async {
  final insertedAffiliateCode = ref.watch(userProvider).affiliateCode ?? '';
  final hasUploadedAffiliateCode = ref.watch(userProvider).hasUploadedAffiliateCode ?? false;
  final recoveryCode = ref.watch(userProvider).recoveryCode;

  ref.read(isLoadingProvider.notifier).state = true;

  try {
    // For new users (no paymentId)
    if (paymentId.isEmpty) {
      await ref.watch(createUserProvider.future);

      await _requestNotificationPermissions();
    } else {
      // For existing users, consider migrating first if recoveryCode is present.
      if (recoveryCode != null && recoveryCode.isNotEmpty) {
        await ref.read(migrateUserToJwtProvider.future);
      }

      // Then update affiliate code if needed.
      if (insertedAffiliateCode.isNotEmpty && !hasUploadedAffiliateCode) {
        await ref.read(addAffiliateCodeProvider(insertedAffiliateCode).future);
      }
    }

    if (buy) {
      context.push('/home/explore/deposit_type');
    } else {
      context.push('/home/explore/sell_type');
    }
  } catch (e) {
    showMessageSnackBar(
      message: e.toString(),
      context: context,
      error: true,
    );
  } finally {
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

