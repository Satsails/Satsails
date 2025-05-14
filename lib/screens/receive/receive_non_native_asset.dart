import 'package:Satsails/models/sideshift_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/providers/sideshift_provider.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:Satsails/translations/translations.dart';

class ReceiveNonNativeAsset extends ConsumerWidget {
  const ReceiveNonNativeAsset({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftPair = ref.watch(selectedShiftPairProvider);

    if (shiftPair == null) {
      return const Center(child: Text('No ShiftPair selected', style: TextStyle(color: Colors.white)));
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
              data: (shift) => Column(
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
                  _buildSection('Fees'.i18n, [
                    {'label': 'Network fee'.i18n, 'value': '${formatAmount(shift.settleCoinNetworkFee, shift.settleCoin)} ${shift.settleCoin} (~${formatAmount(shift.networkFeeUsd, 'USD')} USD)'},
                    {'label': 'Service fee'.i18n, 'value': '1%'},
                  ]),
                  _buildWarning(
                    'Warning: Sending from any other network might result in loss of funds.'.i18n
                  ),
                ],
              ),
              loading: () => Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                  size: 70.w,
                  color: Colors.orange,
                ),
              ),
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

  Widget _buildSection(String title, List<Map<String, String>> details) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Color(0x333333).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          ...details.map(
                (detail) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    detail['label']!,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.sp,
                    ),
                  ),
                  Text(
                    detail['value']!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
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
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          ),
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