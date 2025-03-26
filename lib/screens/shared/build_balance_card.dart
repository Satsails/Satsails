import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class BalanceCard extends ConsumerWidget {
  final String assetName;
  final Color color;
  final String networkFilter;

  const BalanceCard({
    required this.assetName,
    required this.color,
    required this.networkFilter,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final currency = ref.watch(settingsProvider).currency;

    final Map<String, String> _networkImages = {
      'Bitcoin network': 'lib/assets/bitcoin-logo.png',
      'Liquid network': 'lib/assets/l-btc.png',
      'Lightning network': 'lib/assets/Bitcoin_lightning_logo.png',
    };

    final networkShortNames = {
      'Bitcoin network': 'Mainnet',
      'Liquid network': 'Liquid',
      'Lightning network': 'Lightning',
    };

    final depixBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).brlBalance);
    final usdBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).usdBalance);
    final euroBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).eurBalance);
    final btcBalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).btcBalance, btcFormat);
    final liquidBalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidBalance, btcFormat);
    final lightningBalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).lightningBalance ?? 0, btcFormat);

    String nativeBalance;
    String equivalentBalance = '';
    if (assetName == 'Bitcoin') {
      switch (networkFilter) {
        case 'Bitcoin network':
          nativeBalance = btcBalance;
          equivalentBalance = currencyFormat(ref.watch(balanceNotifierProvider).btcBalance / 100000000 * ref.watch(selectedCurrencyProvider(currency)), currency);
          break;
        case 'Liquid network':
          nativeBalance = liquidBalance;
          equivalentBalance = currencyFormat(ref.watch(balanceNotifierProvider).liquidBalance / 100000000 * ref.watch(selectedCurrencyProvider(currency)), currency);
          break;
        case 'Lightning network':
          nativeBalance = lightningBalance;
          equivalentBalance = currencyFormat((ref.watch(balanceNotifierProvider).lightningBalance ?? 0) / 100000000 * ref.watch(selectedCurrencyProvider(currency)), currency);
          break;
        default:
          nativeBalance = '';
          equivalentBalance = '';
      }
    } else {
      switch (assetName) {
        case 'Depix':
          nativeBalance = depixBalance;
          break;
        case 'USDT':
          nativeBalance = usdBalance;
          break;
        case 'EURx':
          nativeBalance = euroBalance;
          break;
        default:
          nativeBalance = '0';
          equivalentBalance = '0 USD';
      }
    }

    final bottomButtons = Container(
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              // TODO: Implement send functionality
            },
            icon: Icon(Icons.arrow_upward, color: Colors.white, size: 24.w),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement receive functionality
            },
            icon: Icon(Icons.arrow_downward, color: Colors.white, size: 24.w),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          ),
          IconButton(
            onPressed: () {
              ref.read(navigationProvider.notifier).state = 4;
            },
            icon: Icon(Icons.shopping_cart, color: Colors.white, size: 24.w),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          ),
          IconButton(
            onPressed: () {
              context.pushNamed('analytics');
            },
            icon: Icon(Icons.analytics_outlined, color: Colors.white, size: 24.w),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8.w,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      clipBehavior: Clip.none,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        _networkImages[networkFilter] ?? 'lib/assets/default.png',
                        width: 24.w,
                        height: 24.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        assetName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        ' (${networkShortNames[networkFilter] ?? networkFilter})',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    nativeBalance,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    equivalentBalance,
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -20.h,
            child: bottomButtons,
          ),
        ],
      ),
    );
  }
}