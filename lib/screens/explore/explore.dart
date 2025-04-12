import 'dart:io';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/string_extension.dart';
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

class Explore extends ConsumerWidget {
  const Explore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);

    // Check conditions and call addCashbackProvider on page init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider);
      final paymentId = user.paymentId;
      final hasUploadedLiquidAddress = user.hasUploadedLiquidAddress ?? false;

      if (paymentId.isNotEmpty && !hasUploadedLiquidAddress) {
        ref.read(addCashbackProvider.future).then((_) {
          // Successfully added cashback address, no further action needed
        }).catchError((error) {
          showMessageSnackBar(
            message: "Failed to add cashback address: $error".i18n,
            context: context,
            error: true,
          );
        });
      }
    });

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
                  child: _ActionCards(),
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
    final transaction = ref.watch(transactionNotifierProvider); // Adjust provider name if needed
    final cashbackToReceive = btcInDenominationFormatted(transaction.unpaidCashback, denomination);

    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          children: [
            Text(
              'Bitcoin balance'.i18n,
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
            SizedBox(height: 16.h), // Space before cashback
            Text(
              'Cashback to receive'.i18n,
              style: TextStyle(
                fontSize: 16.sp, // Smaller than original balance title
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              cashbackToReceive,
              style: TextStyle(
                fontSize: 20.sp, // Smaller than main balance, matches fiat size
                color: Colors.white, // Matches main balance color
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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
                          Icon(Icons.shopping_cart, color: Colors.white, size: 20),
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
    WidgetRef ref, BuildContext context, String paymentId, bool buy) async {
  final insertedAffiliateCode = ref.watch(userProvider).affiliateCode ?? '';
  final hasUploadedAffiliateCode = ref.watch(userProvider).hasUploadedAffiliateCode ?? false;
  final recoveryCode = ref.watch(userProvider).recoveryCode;

  ref.read(isLoadingProvider.notifier).state = true;

  try {
    if (paymentId.isEmpty) {
      await ref.watch(createUserProvider.future);
      if (insertedAffiliateCode.isNotEmpty && !hasUploadedAffiliateCode) {
        await ref.read(addAffiliateCodeProvider(insertedAffiliateCode).future);
      }
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