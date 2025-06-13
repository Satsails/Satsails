import 'dart:ui';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/providers/analytics_provider.dart';
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
import 'package:Satsails/translations/translations.dart';
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
    final screenheight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenheight < 650;

    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final currency = ref.watch(settingsProvider).currency;
    final isBalanceVisible = ref.watch(settingsProvider).balanceVisible;

    final textColor = network == 'Spark Network' ? Colors.white : Colors.black;
    final assetNameColor = network == 'Spark Network'
        ? Colors.grey[400]!
        : network == 'Liquid Network'
        ? Colors.grey[600]!
        : textColor;

    final depixBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidDepixBalance);
    final liquidUsdtBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidUsdtBalance);
    final euroBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidEuroxBalance);
    final onChainBtcBalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).onChainBtcBalance, btcFormat);
    final liquidBtcBalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidBtcBalance, btcFormat);
    final sparkBitcoinbalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).sparkBitcoinbalance ?? 0, btcFormat);

    String nativeBalance;
    String equivalentBalance = '';

    switch (selectedAsset) {
      case 'Bitcoin (Mainnet)':
        nativeBalance = isBalanceVisible ? onChainBtcBalance : '****';
        equivalentBalance = isBalanceVisible
            ? currencyFormat(
            ref.watch(balanceNotifierProvider).onChainBtcBalance / 100000000 * ref.watch(selectedCurrencyProvider(currency)), currency)
            : '****';
        break;
      case 'Lightning Bitcoin':
        nativeBalance = isBalanceVisible ? sparkBitcoinbalance : '****';
        equivalentBalance = isBalanceVisible
            ? currencyFormat(
            (ref.watch(balanceNotifierProvider).sparkBitcoinbalance ?? 0) /
                100000000 *
                ref.watch(selectedCurrencyProvider(currency)),
            currency)
            : '****';
        break;
      case 'Liquid Bitcoin':
        nativeBalance = isBalanceVisible ? liquidBtcBalance : '****';
        equivalentBalance = isBalanceVisible
            ? currencyFormat(
            ref.watch(balanceNotifierProvider).liquidBtcBalance / 100000000 * ref.watch(selectedCurrencyProvider(currency)), currency)
            : '****';
        break;
      case 'USDT':
        nativeBalance = isBalanceVisible ? liquidUsdtBalance : '****';
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

    Widget _buildActionButton({
      required IconData icon,
      required String label,
      required VoidCallback onPressed,
    }) {
      return GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 16.w, weight: 700),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: isSmallScreen ? 200.h : 260.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
        child: Column(
          children: [
            Row(
              children: [
                if (iconPath.endsWith('.svg'))
                  SvgPicture.asset(
                    iconPath,
                    width: selectedAsset == 'Liquid Bitcoin' ? 50.w : 24.w,
                    height: selectedAsset == 'Liquid Bitcoin' ? 50.w : 24.w,
                    colorFilter: network == 'Spark Network' ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null,
                  )
                else
                  Image.asset(iconPath, width: 100.sp),
                SizedBox(width: isSmallScreen ? 4.w : 8.w),
                if (network == 'Spark Network' || network == 'Liquid Network')
                  Text(
                    selectedAsset == 'Lightning Bitcoin'
                        ? 'Lightning'
                        : selectedAsset == 'Liquid Bitcoin'
                        ? 'L-BTC'
                        : selectedAsset,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: assetNameColor,
                    ),
                  ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    ref.read(settingsProvider.notifier).setBalanceVisible(!isBalanceVisible);
                  },
                  icon: Icon(
                    isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: textColor,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 4.h : 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nativeBalance,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    if (['Bitcoin (Mainnet)', 'Lightning Bitcoin', 'Liquid Bitcoin'].contains(selectedAsset))
                      Text(
                        equivalentBalance,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: Opacity(
                opacity: isBalanceVisible ? 1.0 : 0.0,
                child: MiniExpensesGraph(
                  selectedAsset: selectedAsset,
                  textColor: textColor,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.arrow_downward,
                      label: 'Receive'.i18n,
                      onPressed: () {
                        ref.read(selectedNetworkTypeProvider.notifier).state = network;
                        context.push('/home/receive');
                      },
                    ),
                    SizedBox(width: 8.w),
                    _buildActionButton(
                      icon: Icons.arrow_upward,
                      label: 'Send'.i18n,
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
                    ),
                  ],
                ),
                if (isBalanceVisible)
                  GestureDetector(
                    onTap: () {
                      ref.read(selectedAssetProvider.notifier).state = selectedAsset;
                      context.pushNamed('analytics');
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: textColor.withOpacity(0.5), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bar_chart_outlined, size: 16.w, color: textColor),
                          SizedBox(width: 6.w),
                          Text(
                            'Analytics'.i18n,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
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
        asyncData = const AsyncValue.data({});
    }

    return asyncData.when(
      data: (data) => Padding(
        padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
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
      error: (err, stack) => const Center(child: Text('Error')),
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
    List<FlSpot> spots = dataToDisplay.entries.map((entry) {
      return FlSpot(
        entry.key.millisecondsSinceEpoch.toDouble(),
        entry.value.toDouble(),
      );
    }).toList();

    double minY, maxY;

    if (spots.isEmpty) {
      final now = DateTime.now().millisecondsSinceEpoch.toDouble();
      spots = [
        FlSpot(now - const Duration(days: 7).inMilliseconds.toDouble(), 0),
        FlSpot(now, 0),
      ];
      minY = 0;
      maxY = 1;
    } else {
      minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
      maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      double padding = (maxY - minY) * 0.2;
      if (padding == 0) padding = 1;
      minY -= padding;
      maxY += padding;
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: graphColor.withOpacity(0.9),
            barWidth: 2.5,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  graphColor.withOpacity(0.2),
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
                    radius: 3.5,
                    color: graphColor,
                    strokeWidth: 1.5,
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