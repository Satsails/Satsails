import 'dart:io';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
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

class _CashbackDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBalanceVisible = ref.watch(settingsProvider).balanceVisible;
    final denomination = ref.watch(settingsProvider).btcFormat;
    final transaction = ref.watch(transactionNotifierProvider);
    final cashbackToReceive = isBalanceVisible
        ? btcInDenominationFormatted(
      transaction.unpaidCashback * 100000000,
      denomination,
    )
        : '***';

    return Card(
      color: Color(0x333333).withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Cashback to receive'.i18n,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              cashbackToReceive,
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Explore extends ConsumerWidget {
  const Explore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    final isBalanceVisible = ref.watch(settingsProvider).balanceVisible;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider);
      final paymentId = user.paymentId;
      final hasUploadedLiquidAddress = user.hasUploadedLiquidAddress ?? false;

      if (paymentId.isNotEmpty && !hasUploadedLiquidAddress) {
        ref.read(addCashbackProvider.future).then((_) {
          // Successfully added cashback address
        }).catchError((error) {
          showMessageSnackBar(
            message: "Failed to add cashback address: $error".i18n,
            context: context,
            error: true,
          );
        });
      }
    });

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: false, // Align title to the left
          automaticallyImplyLeading: false,
          title: Text(
            'Explore'.i18n,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                ref.read(settingsProvider.notifier).setBalanceVisible(!isBalanceVisible);
              },
              icon: Icon(
                isBalanceVisible ? Icons.remove_red_eye : Icons.visibility_off,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.sp,
                        vertical: 8.h,
                      ),
                      child: _BalanceDisplay(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.sp,
                        vertical: 8.h,
                      ),
                      child: _CashbackDisplay(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.sp,
                        vertical: 8.h,
                      ),
                      child: const _ActionCards(),
                    ),
                    SizedBox(height: 50.sp),
                  ],
                ),
              ),
              if (isLoading)
                Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: Colors.orangeAccent,
                    size: 40.sp,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBalanceVisible = ref.watch(settingsProvider).balanceVisible;
    final denomination = ref.watch(settingsProvider).btcFormat;

    final depixBalance = isBalanceVisible
        ? fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).brlBalance)
        : '***';
    final usdBalance = isBalanceVisible
        ? fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).usdBalance)
        : '***';
    final euroBalance = isBalanceVisible
        ? fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).eurBalance)
        : '***';
    final btcBalance = isBalanceVisible
        ? btcInDenominationFormatted(ref.watch(balanceNotifierProvider).btcBalance, denomination)
        : '***';
    final liquidBalance = isBalanceVisible
        ? btcInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidBalance, denomination)
        : '***';
    final lightningBalance = isBalanceVisible
        ? btcInDenominationFormatted(ref.watch(balanceNotifierProvider).lightningBalance ?? 0, denomination)
        : '***';

    return Card(
      color: Color(0x333333).withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Your Balances'.i18n,
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _buildBalanceRow(
                  imagePath: 'lib/assets/bitcoin-logo.png',
                  color: const Color(0xFFFF9800),
                  label: 'Bitcoin'.i18n,
                  balance: btcBalance,
                ),
                _buildBalanceRow(
                  imagePath: 'lib/assets/Bitcoin_lightning_logo.png',
                  color: const Color(0xFFFF9800),
                  label: 'Lightning'.i18n,
                  balance: lightningBalance,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildBalanceRow(
                  imagePath: 'lib/assets/l-btc.png',
                  color: const Color(0xFFFF9800),
                  label: 'Liquid'.i18n,
                  balance: liquidBalance,
                ),
                _buildBalanceRow(
                  imagePath: 'lib/assets/eurx.png',
                  color: const Color(0xFF003399),
                  label: 'EURx'.i18n,
                  balance: euroBalance,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildBalanceRow(
                  imagePath: 'lib/assets/depix.png',
                  color: const Color(0xFF009C3B),
                  label: 'Depix'.i18n,
                  balance: depixBalance,
                ),
                _buildBalanceRow(
                  imagePath: 'lib/assets/tether.png',
                  color: const Color(0xFF008001),
                  label: 'USDT'.i18n,
                  balance: usdBalance,
                ),
              ],
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
  }) {
    return Expanded(
      child: Row(
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
          SizedBox(width: 5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  balance,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCards extends ConsumerWidget {
  const _ActionCards();

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
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.w),
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
                        color: Colors.black,
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
                color: Color(0x333333).withOpacity(0.4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    context.push('/services');
                  },
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'lib/assets/Ice-Logo.png',
                            width: 90.sp,
                            height: 90.sp,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 8.w),
                          Text(
                            'Market data'.i18n,
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
            SizedBox(width: 2.w),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Color(0x333333).withOpacity(0.4),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'lib/assets/bitrefill.png',
                            width: 90.sp,
                            height: 90.sp,
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8.w),
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
        SizedBox(height: 100.sp),
      ],
    );
  }
}

Future<void> _handleOnPress(
    WidgetRef ref,
    BuildContext context,
    String paymentId,
    bool buy,
    ) async {
  final insertedAffiliateCode = ref.watch(userProvider).affiliateCode ?? '';
  final hasUploadedAffiliateCode = ref.watch(userProvider).hasUploadedAffiliateCode ?? false;
  final recoveryCode = ref.watch(userProvider).recoveryCode;

  ref.read(isLoadingProvider.notifier).state = true;

  try {
    if (paymentId.isEmpty) {
      await ref.watch(createUserProvider.future);
      await _requestNotificationPermissions();
    } else {
      if (recoveryCode != null && recoveryCode.isNotEmpty) {
        await ref.read(migrateUserToJwtProvider.future);
      }
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
    final androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  } else if (Platform.isIOS) {
    final iosPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }
}