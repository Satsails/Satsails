import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

final selectedNetworkTypeProvider = StateProvider<String>((ref) => "Bitcoin network");
final selectedAssetProvider = StateProvider<String>((ref) => 'Bitcoin');

class BalanceCard extends ConsumerWidget {
  final String network;
  final String selectedAsset;
  final String iconPath;
  final Color color;

  const BalanceCard({
    required this.network,
    required this.selectedAsset,
    required this.iconPath,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final currency = ref.watch(settingsProvider).currency;
    final isBalanceVisible = ref.watch(settingsProvider).balanceVisible;

    final textColor = network == 'Spark Network' ? Colors.white : Colors.black;
    final assetNameColor = network == 'Spark Network'
        ? Colors.grey[400]!
        : network == 'Liquid Network'
        ? Colors.grey[600]!
        : textColor;

    final depixBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).brlBalance);
    final usdBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).usdBalance);
    final euroBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).eurBalance);
    final btcBalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).btcBalance, btcFormat);
    final liquidBalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidBalance, btcFormat);
    final lightningBalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).lightningBalance ?? 0, btcFormat);

    String nativeBalance;
    String equivalentBalance = '';

    switch (selectedAsset) {
      case 'Bitcoin (Mainnet)':
        nativeBalance = isBalanceVisible ? btcBalance : '****';
        equivalentBalance = isBalanceVisible
            ? currencyFormat(ref.watch(balanceNotifierProvider).btcBalance / 100000000 * ref.watch(selectedCurrencyProvider(currency)), currency)
            : '****';
        break;
      case 'Lightning Bitcoin':
        nativeBalance = isBalanceVisible ? lightningBalance : '****';
        equivalentBalance = isBalanceVisible
            ? currencyFormat((ref.watch(balanceNotifierProvider).lightningBalance ?? 0) / 100000000 * ref.watch(selectedCurrencyProvider(currency)), currency)
            : '****';
        break;
      case 'Liquid Bitcoin':
        nativeBalance = isBalanceVisible ? liquidBalance : '****';
        equivalentBalance = isBalanceVisible
            ? currencyFormat(ref.watch(balanceNotifierProvider).liquidBalance / 100000000 * ref.watch(selectedCurrencyProvider(currency)), currency)
            : '****';
        break;
      case 'USDT':
        nativeBalance = isBalanceVisible ? usdBalance : '****';
        break;
      case 'EURx':
        nativeBalance = isBalanceVisible ? euroBalance : '****';
        break;
      case 'Depix':
        nativeBalance = isBalanceVisible ? depixBalance : '****';
        break;
      default:
        nativeBalance = '****';
        equivalentBalance = '****';
    }

    final bottomButtons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            ref.read(sendTxProvider.notifier).resetToDefault();
            ref.read(sendBlocksProvider.notifier).state = 1;

            switch (selectedAsset) {
              case 'Bitcoin (Mainnet)':
                context.push('/home/pay', extra: 'bitcoin');
                break;
              case 'Lightning Bitcoin':
                context.push('/home/pay', extra: 'lightning');
                break;
              case 'Liquid Bitcoin':
                ref.read(sendTxProvider.notifier).updateAssetId(AssetMapper.reverseMapTicker(AssetId.LBTC));
                context.push('/home/pay', extra: 'liquid');
                break;
              default:
                String assetId;
                switch (selectedAsset) {
                  case 'USDT':
                    assetId = AssetMapper.reverseMapTicker(AssetId.USD);
                    break;
                  case 'EURx':
                    assetId = AssetMapper.reverseMapTicker(AssetId.EUR);
                    break;
                  case 'Depix':
                    assetId = AssetMapper.reverseMapTicker(AssetId.BRL);
                    break;
                  default:
                    assetId = '';
                }
                ref.read(sendTxProvider.notifier).updateAssetId(assetId);
                context.push('/home/pay', extra: 'liquid_asset');
            }
          },
          icon: Icon(Icons.arrow_upward, color: textColor, size: 28.w, weight: 700),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        ),
        IconButton(
          onPressed: () {
            ref.read(selectedNetworkTypeProvider.notifier).state = network;
            context.push('/home/receive');
          },
          icon: Icon(Icons.arrow_downward, color: textColor, size: 28.w, weight: 700),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
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
              padding: EdgeInsets.symmetric(vertical: 8.sp, horizontal: 16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (iconPath.endsWith('.svg'))
                        SvgPicture.asset(
                          iconPath,
                          width: selectedAsset == 'Liquid Bitcoin' ? 50.w : 24.w,
                          height: selectedAsset == 'Liquid Bitcoin' ? 50.w : 24.w,
                          color: network == 'Spark Network' ? Colors.white : null,
                        )
                      else
                        Image.asset(
                          iconPath,
                          width: 100.sp,
                        ),
                      SizedBox(width: isSmallScreen ? 4.w : 8.w),
                      if (network == 'Spark Network' || network == 'Liquid Network')
                        Text(
                          selectedAsset,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: assetNameColor,
                          ),
                        ),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          ref.read(settingsProvider.notifier).setBalanceVisible(!isBalanceVisible);
                        },
                        icon: Icon(
                          isBalanceVisible ? Icons.remove_red_eye : Icons.visibility_off,
                          color: textColor,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 8.h : 16.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              nativeBalance,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            if (['Bitcoin (Mainnet)', 'Lightning Bitcoin', 'Liquid Bitcoin'].contains(selectedAsset)) ...[
                              SizedBox(height: 4.h),
                              Text(
                                equivalentBalance,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: textColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!isSmallScreen)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            MiniExpensesGraph(
                              selectedAsset: selectedAsset,
                              textColor: textColor,
                            ),
                            if (['Bitcoin (Mainnet)', 'Lightning Bitcoin', 'Liquid Bitcoin'].contains(selectedAsset)) ...[
                              SizedBox(height: 8.h),
                              _buildPricePercentageChangeTicker(context, ref, textColor),
                            ],
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 2.h,
            right: 16.w,
            child: TextButton(
              onPressed: () {
                ref.read(selectedAssetProvider.notifier).state = selectedAsset;
                context.pushNamed('analytics');
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  side: BorderSide(color: textColor.withOpacity(0.6), width: 1.5),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
                elevation: 0,
              ),
              child: Text(
                'Analytics',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 2.h,
            left: 16.w,
            child: bottomButtons,
          ),
        ],
      ),
    );
  }

  Widget _buildPricePercentageChangeTicker(BuildContext context, WidgetRef ref, Color textColor) {
    final currency = ref.watch(settingsProvider).currency;
    final coinGeckoData = ref.watch(coinGeckoBitcoinChange(currency.toLowerCase()));
    final currentPrice = ref.watch(selectedCurrencyProvider(currency)) * 1;

    return coinGeckoData.when(
      data: (data) {
        IconData? icon;
        String displayText = '${data.abs().toStringAsFixed(2)}%';

        if (displayText == '-0.00%' || displayText == '0.00%') {
          displayText = '0%';
          icon = null;
        } else if (data > 0) {
          icon = Icons.arrow_upward;
        } else if (data < 0) {
          icon = Icons.arrow_downward;
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentPrice.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(width: 8.w),
              if (icon != null) Icon(icon, size: 16.sp, color: textColor, weight: 700),
              SizedBox(width: icon != null ? 4.0 : 0),
              Text(
                displayText,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => LoadingAnimationWidget.progressiveDots(
        size: 16.sp,
        color: textColor,
      ),
      error: (error, stack) => Text(
        'Error',
        style: TextStyle(fontSize: 16.sp, color: textColor),
      ),
    );
  }
}

class MiniExpensesGraph extends ConsumerWidget {
  final String selectedAsset;
  final Color textColor;

  const MiniExpensesGraph({
    required this.selectedAsset,
    required this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late final AsyncValue<Map<DateTime, num>> asyncData;

    switch (selectedAsset) {
      case 'Bitcoin (Mainnet)':
        asyncData = AsyncValue.data(ref.watch(bitcoinBalanceInFormatByDayProvider));
        break;
      case 'Lightning Bitcoin':
        asyncData = AsyncValue.data(ref.watch(bitcoinBalanceInFormatByDayProvider));
        break;
      case 'Liquid Bitcoin':
        final assetId = AssetMapper.reverseMapTicker(AssetId.LBTC);
        asyncData = AsyncValue.data(ref.watch(liquidBalancePerDayInFormatProvider(assetId)));
        break;
      case 'USDT':
        final assetId = AssetMapper.reverseMapTicker(AssetId.USD);
        asyncData = AsyncValue.data(ref.watch(liquidBalancePerDayInFormatProvider(assetId)));
        break;
      case 'EURx':
        final assetId = AssetMapper.reverseMapTicker(AssetId.EUR);
        asyncData = AsyncValue.data(ref.watch(liquidBalancePerDayInFormatProvider(assetId)));
        break;
      case 'Depix':
        final assetId = AssetMapper.reverseMapTicker(AssetId.BRL);
        asyncData = AsyncValue.data(ref.watch(liquidBalancePerDayInFormatProvider(assetId)));
        break;
      default:
        asyncData = AsyncValue.data({});
    }

    return Container(
      width: 170.w,
      height: 50.h,
      child: asyncData.when(
        data: (data) => Padding(
          padding: EdgeInsets.all(4.0.sp),
          child: SimplifiedExpensesGraph(
            dataToDisplay: data,
            graphColor: textColor,
          ),
        ),
        loading: () => Center(
          child: LoadingAnimationWidget.fourRotatingDots(
            color: textColor,
            size: 20,
          ),
        ),
        error: (err, stack) => Center(child: Text('Error')),
      ),
    );
  }
}

class SimplifiedExpensesGraph extends StatelessWidget {
  final Map<DateTime, num> dataToDisplay;
  final Color graphColor;

  const SimplifiedExpensesGraph({
    required this.dataToDisplay,
    required this.graphColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final spots = dataToDisplay.entries.map((entry) {
      return FlSpot(
        entry.key.millisecondsSinceEpoch.toDouble(),
        entry.value.toDouble(),
      );
    }).toList();

    final minY = spots.isNotEmpty ? spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) : 0.0;
    final maxY = spots.isNotEmpty ? spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) : 1.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: false),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: graphColor,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  graphColor.withOpacity(0.4),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                if (index == barData.spots.length - 1) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: graphColor,
                    strokeWidth: 1,
                    strokeColor: graphColor,
                  );
                }
                return FlDotCirclePainter(radius: 0);
              },
            ),
          ),
        ],
      ),
    );
  }
}