import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/providers/sideshift_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:shimmer/shimmer.dart';

class ReceiveNonNativeAsset extends ConsumerWidget {
  const ReceiveNonNativeAsset({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftPair = ref.watch(selectedShiftPairProvider);

    if (shiftPair == null) {
      return Center(child: Text('No ShiftPair selected'.i18n, style: const TextStyle(color: Colors.white)));
    }

    final shiftAsync = ref.watch(createReceiveSideShiftShiftProvider(shiftPair));

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.h),
            shiftAsync.when(
              data: (shift) {
                final networkFee = double.tryParse(shift.settleCoinNetworkFee) ?? 0;
                final hasNetworkFee = networkFee > 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: buildQrCode(shift.depositAddress, context)),
                    SizedBox(height: 16.h),
                    Center(child: buildAddressText(shift.depositAddress, context, ref)),
                    if (shift.depositMemo != null) ...[
                      SizedBox(height: 8.h),
                      Center(
                        child: Text(
                          'Memo: ${shift.depositMemo}',
                          style: TextStyle(color: Colors.white, fontSize: 16.sp),
                        ),
                      ),
                    ],
                    SizedBox(height: 16.h),
                    _buildSection('Deposit Limits'.i18n, [
                      {'label': 'Min'.i18n, 'value': '${formatAmount(shift.depositMin, shift.depositCoin)} ${shift.depositCoin}'},
                      {'label': 'Max'.i18n, 'value': '${formatAmount(shift.depositMax, shift.depositCoin)} ${shift.depositCoin}'},
                    ]),
                    _RateDisplay(shiftPair: shiftPair, amount: shift.depositMin),
                    if (hasNetworkFee)
                      _buildSection('Fees'.i18n, [
                        {'label': 'Network fee'.i18n, 'value': '${formatAmount(shift.settleCoinNetworkFee, shift.settleCoin)} ${shift.settleCoin} (~${formatAmount(shift.networkFeeUsd, 'USD')} USD)'},
                      ]),
                    _buildWarning(
                        'Warning: Sending from any other network might result in loss of funds.'.i18n
                    ),
                  ],
                );
              },
              loading: () => _buildShimmerPlaceholder(),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    final baseColor = Colors.grey[850]!;
    final highlightColor = Colors.grey[700]!;

    Widget shimmerBox({double? width, required double height, double radius = 8.0}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(radius.r),
        ),
      );
    }

    Widget shimmerSection({int lines = 1}) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            shimmerBox(width: 150.w, height: 20.h), // Title placeholder
            SizedBox(height: 12.h),
            for (var i = 0; i < lines; i++)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    shimmerBox(width: 80.w, height: 16.h), // Label placeholder
                    shimmerBox(width: 120.w, height: 16.h), // Value placeholder
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: shimmerBox(width: 250.w, height: 250.w, radius: 16)),
          SizedBox(height: 16.h),
          shimmerBox(width: double.infinity, height: 20.h),
          SizedBox(height: 24.h),
          shimmerSection(lines: 2), // Deposit Limits
          shimmerSection(lines: 1), // Rate Display
          shimmerSection(lines: 1), // Fees
          // Warning Section
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                shimmerBox(width: 24.w, height: 24.h, radius: 24),
                SizedBox(width: 8.w),
                Expanded(child: shimmerBox(height: 32.h)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, String>> details) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0x00333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          ...details.map(
                (detail) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(detail['label']!, style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
                  Text(detail['value']!, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarning(String message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red[900],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.white, size: 24.sp),
          SizedBox(width: 8.w),
          Expanded(child: Text(message, style: TextStyle(color: Colors.white, fontSize: 16.sp))),
        ],
      ),
    );
  }

  String formatAmount(String amount, String coin) {
    double value = double.tryParse(amount) ?? 0;
    int decimals = _isFiat(coin) ? 2 : 8;
    return value.toStringAsFixed(decimals);
  }

  bool _isFiat(String coin) {
    return ['USD', 'EUR', 'BRL'].contains(coin.toUpperCase());
  }
}

class _RateDisplay extends ConsumerWidget {
  final ShiftPair shiftPair;
  final String amount;

  const _RateDisplay({
    required this.shiftPair,
    required this.amount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(sideShiftQuoteProvider((shiftPair, amount, true)));

    return quoteAsync.when(
      data: (quote) {
        final rate = double.tryParse(quote.rate) ?? 0;
        final isFiat = ['USD', 'EUR', 'BRL'].contains(quote.settleCoin.toUpperCase());
        final formattedRate = rate.toStringAsFixed(isFiat ? 2 : 8);

        return Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0x00333333).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Conversion Rate'.i18n, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rate'.i18n, style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
                  Text('1 ${quote.depositCoin.toUpperCase()} = $formattedRate ${quote.settleCoin.toUpperCase()}', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Center(child: LoadingAnimationWidget.fourRotatingDots(size: 20.w, color: Colors.white)),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}