import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/providers/sideshift_provider.dart';
import 'package:Satsails/screens/shared/copy_text.dart';
import 'package:Satsails/screens/shared/qr_code.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ReceiveNonNativeAsset extends ConsumerWidget {
  const ReceiveNonNativeAsset({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftPair = ref.watch(selectedShiftPairProvider);

    if (shiftPair == null) {
      return const Center(child: Text('No ShiftPair selected', style: TextStyle(color: Colors.white)));
    }

    final shiftAsync = ref.watch(createSideShiftShiftForPairProvider(shiftPair));
    final assetPair = ref.watch(sideshiftAssetPairProvider(shiftPair));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 24.h),
        Text(
          _getShiftPairDisplayName(shiftPair),
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
        SizedBox(height: 16.h),
        shiftAsync.when(
          data: (shift) => Column(
            children: [
              buildQrCode(shift.depositAddress, context),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.all(16.h),
                child: buildAddressText(shift.depositAddress, context, ref),
              ),
              if (shift.depositMemo != null) ...[
                SizedBox(height: 8.h),
                Text('Memo: ${shift.depositMemo}', style: const TextStyle(color: Colors.white)),
              ],
              SizedBox(height: 16.h),
              _buildInfoSection('Deposit Limits', [
                'Min: ${formatAmount(shift.depositMin, shift.depositCoin)} ${shift.depositCoin}',
                'Max: ${formatAmount(shift.depositMax, shift.depositCoin)} ${shift.depositCoin}',
              ]),
              _buildInfoSection('Expected Settlement', [
                '${formatAmount(shift.settleAmount, shift.settleCoin)} ${shift.settleCoin}',
              ]),
              _buildInfoSection('Fees', [
                'Network fee: ${formatAmount(shift.settleCoinNetworkFee, shift.settleCoin)} ${shift.settleCoin} (~${formatAmount(shift.networkFeeUsd, 'USD')} USD)',
              ]),
              _buildInfoSection('Expiration', [
                formatExpiresAt(shift.expiresAt),
              ]),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.h),
                color: Colors.blueGrey[800],
                child: Text(
                  'Send ${shift.depositCoin} from your ${shift.depositNetwork} wallet to the address above${shift.depositMemo != null ? ' with the memo: ${shift.depositMemo}' : ''} to receive ${shift.settleCoin} on Liquid.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
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
    );
  }

  Widget _buildInfoSection(String title, List<String> details) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          ...details.map((detail) => Padding(
            padding: EdgeInsets.only(left: 16.w, top: 4.h),
            child: Text(detail, style: const TextStyle(color: Colors.white)),
          )),
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

  String formatExpiresAt(String expiresAt) {
    DateTime expireTime = DateTime.parse(expiresAt);
    Duration remaining = expireTime.difference(DateTime.now());
    if (remaining.isNegative) {
      return 'Expired';
    } else {
      return 'Expires in ${_formatDuration(remaining)}';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} days';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutes';
    } else {
      return '${duration.inSeconds} seconds';
    }
  }

  String _getShiftPairDisplayName(ShiftPair pair) {
    switch (pair) {
      case ShiftPair.usdtTronToLiquidUsdt:
        return 'Receive Liquid USDT from USDT on Tron';
      case ShiftPair.usdtBscToLiquidUsdt:
        return 'Receive Liquid USDT from USDT on BSC';
      case ShiftPair.usdtEthToLiquidUsdt:
        return 'Receive Liquid USDT from USDT on Ethereum';
      case ShiftPair.usdtSolToLiquidUsdt:
        return 'Receive Liquid USDT from USDT on Solana';
      case ShiftPair.usdtPolygonToLiquidUsdt:
        return 'Receive Liquid USDT from USDT on Polygon';
      case ShiftPair.usdcEthToLiquidUsdt:
        return 'Receive Liquid USDT from USDC on Ethereum';
      case ShiftPair.usdcTronToLiquidUsdt:
        return 'Receive Liquid USDT from USDC on Tron';
      case ShiftPair.usdcBscToLiquidUsdt:
        return 'Receive Liquid USDT from USDC on BSC';
      case ShiftPair.usdcSolToLiquidUsdt:
        return 'Receive Liquid USDT from USDC on Solana';
      case ShiftPair.usdcPolygonToLiquidUsdt:
        return 'Receive Liquid USDT from USDC on Polygon';
      case ShiftPair.ethToLiquidBtc:
        return 'Receive Liquid BTC from ETH';
      case ShiftPair.trxToLiquidBtc:
        return 'Receive Liquid BTC from TRX';
      case ShiftPair.bnbToLiquidBtc:
        return 'Receive Liquid BTC from BNB';
      case ShiftPair.solToLiquidBtc:
        return 'Receive Liquid BTC from SOL';
      default:
        return 'Receive ${pair.toString().split('.').last}';
    }
  }
}