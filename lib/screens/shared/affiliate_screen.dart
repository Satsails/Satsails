import 'package:Satsails/models/user_model.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/creation/components/logo.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/screens/shared/transaction_modal.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

enum AffiliateStatus { codeApplied, alreadyExists, noCodeFound }

class AffiliateScreen extends ConsumerWidget {
  final String? affiliateCode;
  const AffiliateScreen({super.key, this.affiliateCode});

  Future<void> _handleAffiliateCodeLogic(WidgetRef ref, User loadedUser) async {
    final existingCode = loadedUser.affiliateCode;
    final newCode = affiliateCode;

    if (newCode != null && newCode.isNotEmpty) {
      if (existingCode == null || existingCode.isEmpty) {
        final upperCaseCode = newCode.toUpperCase();
        final box = await Hive.openBox('user');
        await box.put('affiliateCode', upperCaseCode);
        ref.read(userProvider.notifier).setAffiliateCode(upperCaseCode);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialUserAsync = ref.watch(initializeUserProvider);

    ref.listen<AsyncValue<User>>(initializeUserProvider, (previous, next) {
      if (next.hasValue && previous?.hasValue != true) {
        _handleAffiliateCodeLogic(ref, next.value!);
        ref.read(sendTxProvider.notifier).resetToDefault();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: initialUserAsync.when(
            loading: () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 20.h),
                Text('Loading user data...'.i18n,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16.sp)),
                const Spacer(),
              ],
            ),
            error: (err, stack) => Center(
                child: Text('Error loading user data: $err',
                    style: const TextStyle(color: Colors.red))),
            data: (_) {
              return _AffiliateView(routeAffiliateCode: affiliateCode);
            },
          ),
        ),
      ),
    );
  }
}

class _AffiliateView extends ConsumerWidget {
  final String? routeAffiliateCode;
  const _AffiliateView({this.routeAffiliateCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final userAffiliateCode = user.affiliateCode;

    AffiliateStatus status;
    String displayedCode;

    final newCode = routeAffiliateCode;

    // We then check if `newCode` is valid *once*.
    if (newCode != null && newCode.isNotEmpty) {
      if (userAffiliateCode != null &&
          userAffiliateCode.isNotEmpty &&
          userAffiliateCode.toUpperCase() != newCode.toUpperCase()) {
        status = AffiliateStatus.alreadyExists;
        displayedCode = userAffiliateCode;
      } else {
        status = AffiliateStatus.codeApplied;
        displayedCode = newCode.toUpperCase();
      }
    } else {
      status = AffiliateStatus.noCodeFound;
      displayedCode = '';
    }

    Widget statusContent;
    switch (status) {
      case AffiliateStatus.codeApplied:
        statusContent = Column(
          children: [
            AnimatedSlideFade(
              delay: 100,
              child: Icon(Icons.check_circle_outline_rounded,
                  color: const Color(0xFF4CAF50), size: 80.w),
            ),
            SizedBox(height: 20.h),
            AnimatedSlideFade(
              delay: 200,
              child: Text('Affiliate Program'.i18n,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 12.h),
            AnimatedSlideFade(
              delay: 300,
              child: Text(displayedCode,
                  style: TextStyle(
                      fontSize: 42.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            SizedBox(height: 8.h),
            AnimatedSlideFade(
              delay: 400,
              child: Text('Code applied successfully!'.i18n,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7), fontSize: 16.sp)),
            ),
          ],
        );
        break;
      case AffiliateStatus.alreadyExists:
        statusContent = Column(
          children: [
            AnimatedSlideFade(
              delay: 100,
              child: Icon(Icons.info_outline_rounded,
                  color: Colors.orangeAccent, size: 80.w),
            ),
            SizedBox(height: 20.h),
            AnimatedSlideFade(
              delay: 200,
              child: Text('Affiliate Code'.i18n,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 12.h),
            AnimatedSlideFade(
              delay: 300,
              child: Text(displayedCode,
                  style: TextStyle(
                      fontSize: 42.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            SizedBox(height: 8.h),
            AnimatedSlideFade(
              delay: 400,
              child: Text(
                  'You already have this affiliate code applied. It cannot be changed.'
                      .i18n,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16.sp,
                      height: 1.5)),
            ),
          ],
        );
        break;
      case AffiliateStatus.noCodeFound:
        statusContent = Column(
          children: [
            AnimatedSlideFade(
              delay: 100,
              child: Icon(Icons.info_outline_rounded,
                  color: Colors.orangeAccent, size: 80.w),
            ),
            SizedBox(height: 20.h),
            AnimatedSlideFade(
              delay: 200,
              child: Text('Affiliate Program'.i18n,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 12.h),
            AnimatedSlideFade(
              delay: 300,
              child: Container(
                padding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                    'No new affiliate code was found. You can add one later in your settings.'
                        .i18n,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16.sp,
                        height: 1.5)),
              ),
            ),
          ],
        );
        break;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        statusContent,
        const Spacer(),
        const BrandingFooter(delay: 500),
        SizedBox(height: 20.h),
        AnimatedSlideFade(
          delay: 600,
          child: CustomButton(
            text: 'Continue'.i18n,
            onPressed: () async {
              final authModel = ref.read(authModelProvider);
              final user = ref.read(userProvider);
              final insertedAffiliateCode = user.affiliateCode ?? '';
              final hasUploadedAffiliateCode =
                  user.hasUploadedAffiliateCode ?? false;
              final mnemonic = await authModel.getMnemonic();

              if (mnemonic != null && mnemonic.isNotEmpty) {
                if (insertedAffiliateCode.isNotEmpty &&
                    !hasUploadedAffiliateCode) {
                  try {
                    await ref.read(
                        addAffiliateCodeProvider(insertedAffiliateCode).future);
                    if (!context.mounted) return;
                    showMessageSnackBar(
                        message:
                        'Affiliate code synced with your account'.i18n,
                        error: false,
                        context: context,
                        top: true);
                  } catch (e) {
                    if (!context.mounted) return;
                    showMessageSnackBar(
                        message: 'Error syncing affiliate code'.i18n,
                        error: true,
                        context: context,
                        top: true);
                  }
                }
                if (context.mounted) context.pushReplacement('/open_pin');
              } else {
                if (context.mounted) context.pushReplacement('/start');
              }
            },
            primaryColor: const Color(0xFF2E2E2E),
            secondaryColor: const Color(0xFF1E1E1E),
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }
}