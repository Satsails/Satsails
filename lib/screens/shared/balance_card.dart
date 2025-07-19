import 'dart:ui';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/formatters.dart';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final isBalanceVisible = ref.watch(settingsProvider).balanceVisible;
    final textColor = network == 'Spark Network' ? Colors.white : Colors.black;
    final assetNameColor = network == 'Spark Network'
        ? Colors.grey[400]!
        : network == 'Liquid Network'
        ? Colors.grey[600]!
        : textColor;

    return Row(
      children: [
        if (iconPath.endsWith('.svg'))
          SvgPicture.asset(
            iconPath,
            width: selectedAsset == 'Liquid Bitcoin' ? 40.w : 24.w,
            height: selectedAsset == 'Liquid Bitcoin' ? 40.w : 24.w,
            colorFilter: network == 'Spark Network'
                ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                : null,
          )
        else
          Image.asset(iconPath, width: 100.sp),
        SizedBox(width: 8.w),
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
          onPressed: () => ref.read(settingsProvider.notifier).setBalanceVisible(!isBalanceVisible),
          icon: Icon(
            isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: textColor,
            size: 24.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceDisplay(String nativeBalance, String equivalentBalance, bool isSmallScreen) {
    final textColor = network == 'Spark Network' ? Colors.white : Colors.black;
    final primaryBalanceSize = isSmallScreen ? 28.sp : 36.sp;
    final secondaryBalanceSize = isSmallScreen ? 15.sp : 18.sp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nativeBalance,
          style: TextStyle(
            fontSize: primaryBalanceSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 2.h),
        if (['Bitcoin (Mainnet)', 'Lightning Bitcoin', 'Liquid Bitcoin'].contains(selectedAsset))
          Text(
            equivalentBalance,
            style: TextStyle(
              fontSize: secondaryBalanceSize,
              color: textColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, bool isSmallScreen) {
    final textColor = network == 'Spark Network' ? Colors.white : Colors.black;
    final isBalanceVisible = ref.watch(settingsProvider).balanceVisible;
    final buttonFontSize = isSmallScreen ? 12.sp : 13.sp;

    return Row(
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
              textColor: textColor,
              fontSize: buttonFontSize,
            ),
            SizedBox(width: 8.w),
            _buildActionButton(
              icon: Icons.arrow_upward,
              label: 'Send'.i18n,
              onPressed: () {
                ref.read(sendTxProvider.notifier).resetToDefault();
                ref.read(sendBlocksProvider.notifier).state = 1;
                _handleSendNavigation(context, ref);
              },
              textColor: textColor,
              fontSize: buttonFontSize,
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
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color textColor,
    required double fontSize,
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
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: fontSize),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSendNavigation(BuildContext context, WidgetRef ref) {
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
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenheight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenheight < 850;

    final settings = ref.watch(settingsProvider);
    final btcFormat = settings.btcFormat;
    final currency = settings.currency;
    final isBalanceVisible = settings.balanceVisible;
    final textColor = network == 'Spark Network' ? Colors.white : Colors.black;

    final balanceProvider = ref.watch(balanceNotifierProvider);
    final currencyRate = ref.watch(selectedCurrencyProvider(currency));

    String nativeBalance;
    String equivalentBalance = '';

    // Determine the native balance string first.
    switch (selectedAsset) {
      case 'Bitcoin (Mainnet)':
        nativeBalance = isBalanceVisible ? btcInDenominationFormatted(balanceProvider.onChainBtcBalance, btcFormat) : '****';
        break;
      case 'Lightning Bitcoin':
        nativeBalance = isBalanceVisible ? btcInDenominationFormatted(balanceProvider.sparkBitcoinbalance ?? 0, btcFormat) : '****';
        break;
      case 'Liquid Bitcoin':
        nativeBalance = isBalanceVisible ? btcInDenominationFormatted(balanceProvider.liquidBtcBalance, btcFormat) : '****';
        break;
      case 'USDT':
        nativeBalance = isBalanceVisible ? fiatInDenominationFormatted(balanceProvider.liquidUsdtBalance) : '****';
        break;
      case 'EURx':
        nativeBalance = isBalanceVisible ? fiatInDenominationFormatted(balanceProvider.liquidEuroxBalance) : '****';
        break;
      case 'Depix':
        nativeBalance = isBalanceVisible ? fiatInDenominationFormatted(balanceProvider.liquidDepixBalance) : '****';
        break;
      default:
        nativeBalance = '****';
    }

    // If visible and a Bitcoin asset, calculate the fiat equivalent precisely.
    if (isBalanceVisible && ['Bitcoin (Mainnet)', 'Lightning Bitcoin', 'Liquid Bitcoin'].contains(selectedAsset)) {
      int satsBalance;
      switch (selectedAsset) {
        case 'Lightning Bitcoin':
          satsBalance = balanceProvider.sparkBitcoinbalance ?? 0;
          break;
        case 'Liquid Bitcoin':
          satsBalance = balanceProvider.liquidBtcBalance;
          break;
        default: // 'Bitcoin (Mainnet)'
          satsBalance = balanceProvider.onChainBtcBalance;
          break;
      }

      final satsDecimal = Decimal.fromInt(satsBalance);
      final rateDecimal = Decimal.parse(currencyRate.toString());
      final btcDecimal = (satsDecimal / Decimal.fromInt(100000000)).toDecimal(scaleOnInfinitePrecision: 8);
      final fiatValueDecimal = btcDecimal * rateDecimal;

      equivalentBalance = currencyFormat(fiatValueDecimal, currency);
    } else if (!isBalanceVisible) {
      equivalentBalance = '****';
    }

    return Container(
      height: isSmallScreen ? 210.h : 260.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref),
            SizedBox(height: isSmallScreen ? 2.h : 4.h),
            _buildBalanceDisplay(nativeBalance, equivalentBalance, isSmallScreen),
            if (!isSmallScreen)
              Expanded(
                child: Opacity(
                  opacity: isBalanceVisible ? 1.0 : 0.0,
                  child: MiniExpensesGraph(
                    selectedAsset: selectedAsset,
                    textColor: textColor,
                  ),
                ),
              )
            else
              const Spacer(),
            SizedBox(height: 8.h),
            _buildActionButtons(context, ref, isSmallScreen),
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