import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/analytics/components/chart.dart';
import 'package:Satsails/screens/shared/message_display.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';

// Providers
final isLoadingProvider = StateProvider<bool>((ref) => false);

// Main Explore Widget
class Explore extends ConsumerWidget {
  const Explore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    final isBalanceVisible = ref.watch(settingsProvider).balanceVisible;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Text('Explore'.i18n, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              onPressed: () => ref.read(settingsProvider.notifier).setBalanceVisible(!isBalanceVisible),
              icon: Icon(isBalanceVisible ? Icons.remove_red_eye : Icons.visibility_off, color: Colors.white),
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(decoration: BoxDecoration(color: Colors.black)),
              ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 2.sp),
                      child: const _BalanceDisplay(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 2.sp),
                      child: const _ActionCards(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 2.sp),
                      child: const _BitcoinPriceChart(),
                    ),
                    SizedBox(height: 130.sp),
                  ],
                ),
              ),
              if (isLoading)
                Center(
                  child: LoadingAnimationWidget.fourRotatingDots(color: Colors.orangeAccent, size: 40.sp),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceDisplay extends ConsumerStatefulWidget {
  const _BalanceDisplay();
  @override
  ConsumerState<_BalanceDisplay> createState() => _BalanceDisplayState();
}

class _BalanceDisplayState extends ConsumerState<_BalanceDisplay> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isBalanceVisible = settings.balanceVisible;
    final denomination = settings.btcFormat;

    final balanceProvider = ref.watch(balanceNotifierProvider);
    final depixBalance = isBalanceVisible ? fiatInDenominationFormatted(balanceProvider.liquidDepixBalance) : '***';
    final liquidUsdtBalance = isBalanceVisible ? fiatInDenominationFormatted(balanceProvider.liquidUsdtBalance) : '***';
    final euroBalance = isBalanceVisible ? fiatInDenominationFormatted(balanceProvider.liquidEuroxBalance) : '***';
    final onChainBtcBalance = isBalanceVisible ? btcInDenominationFormatted(balanceProvider.onChainBtcBalance, denomination) : '***';
    final liquidBtcBalance = isBalanceVisible ? btcInDenominationFormatted(balanceProvider.liquidBtcBalance, denomination) : '***';

    return Card(
      color: const Color(0xFF333333).withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          children: [
            Row(children: [_buildBalanceRow(imagePath: 'lib/assets/bitcoin-logo.png', label: 'Bitcoin'.i18n, balance: onChainBtcBalance), _buildBalanceRow(imagePath: 'lib/assets/l-btc.png', label: 'Liquid Bitcoin', balance: liquidBtcBalance)]),
            SizedBox(height: 12.h),
            Row(children: [_buildBalanceRow(imagePath: 'lib/assets/eurx.png', label: 'Liquid EURx', balance: euroBalance), _buildBalanceRow(imagePath: 'lib/assets/tether.png', label: 'Liquid USDT', balance: liquidUsdtBalance)]),
            SizedBox(height: 12.h),
            Row(children: [_buildBalanceRow(imagePath: 'lib/assets/depix.png', label: 'Liquid Depix', balance: depixBalance), Expanded(child: Container())]),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceRow({required String imagePath, required String label, required String balance}) {
    return Expanded(
      child: Row(
        children: [
          Image.asset(imagePath, width: 24.sp, height: 24.sp, fit: BoxFit.contain),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                SizedBox(height: 2.h),
                Text(balance, style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
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
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: const Color(0xFF333333).withOpacity(0.4),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => showMessageSnackBar(message: "Coming soon".i18n, context: context, error: true),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.sp),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'lib/assets/bitrefill.png',
                          height: 30.sp,
                          fit: BoxFit.contain,
                          color: Colors.white,
                        ),
                        SizedBox(height: 2.sp),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                          child: Text('Shop With Bitcoin'.i18n, style: TextStyle(fontSize: 16.sp, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.orange,
                    size: 30.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 2.sp),
        Row(
          children: [
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: Colors.green.withOpacity(0.8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  // REFACTORED: The onTap now simply navigates. All logic is moved.
                  onTap: () => context.push('/home/explore/deposit_type'),
                  child: Container(
                    height: 70.h,
                    alignment: Alignment.center,
                    child: Text('Buy'.i18n, style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: Colors.red.withOpacity(0.8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => context.push('/home/explore/sell_type'),
                  child: Container(
                    height: 70.h,
                    alignment: Alignment.center,
                    child: Text('Sell'.i18n, style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold)),
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

// Static 1-Month Bitcoin Price Chart
class _BitcoinPriceChart extends ConsumerWidget {
  const _BitcoinPriceChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketDataAsync = ref.watch(bitcoinMarketDataProvider);

    return marketDataAsync.when(
      data: (marketData) {
        if (marketData.isEmpty) {
          return SizedBox(
            height: 200.h,
            child: Card(
              color: const Color(0xFF333333).withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              child: Center(child: Text('No price data available.'.i18n, style: TextStyle(color: Colors.white70))),
            ),
          );
        }

        const int days = 30;
        final now = DateTime.now().dateOnly();
        final start = now.subtract(const Duration(days: days - 1));
        final selectedDays = <DateTime>[];
        for (var i = 0; i < days; i++) {
          selectedDays.add(start.add(Duration(days: i)));
        }

        final settings = ref.watch(settingsProvider);
        final Map<DateTime, num> priceByDay = {for (var dp in marketData) dp.date.toLocal().dateOnly(): dp.price ?? 0};
        final lastPrice = marketData.last.price ?? 0;
        final startPriceThisMonth = marketData.firstWhere((dp) => dp.date.toLocal().dateOnly() == start, orElse: () => marketData.first).price ?? 0;
        final percentageChange = startPriceThisMonth != 0 ? ((lastPrice - startPriceThisMonth) / startPriceThisMonth * 100) : 0;
        final currencyFormatter = NumberFormat.simpleCurrency(name: settings.currency, decimalDigits: 2);

        return Card(
          color: const Color(0xFF333333).withOpacity(0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Bitcoin Price (1 Month)'.i18n, style: TextStyle(fontSize: 16.sp, color: Colors.grey, fontWeight: FontWeight.w500)), Text('${percentageChange >= 0 ? '+' : ''}${percentageChange.toStringAsFixed(2)}%', style: TextStyle(fontSize: 16.sp, color: percentageChange >= 0 ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.w600))],
                ),
                SizedBox(height: 4.h),
                Text(currencyFormatter.format(lastPrice), style: TextStyle(fontSize: 20.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 12.h),
                AspectRatio(
                  aspectRatio: 2.5,
                  child: _PriceSparklineChart(priceData: priceByDay, sortedDays: selectedDays, formatter: currencyFormatter),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => SizedBox(
        height: 200.h,
        child: Shimmer.fromColors(
          baseColor: const Color(0xFF333333),
          highlightColor: const Color(0xFF444444),
          child: Card(
            color: const Color(0xFF333333).withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
          ),
        ),
      ),
      error: (e, s) => SizedBox(
        height: 200.h,
        child: Center(child: Text('Could not load price data'.i18n, style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }
}

// Interactive Sparkline Chart (No Scale)
class _PriceSparklineChart extends StatelessWidget {
  final Map<DateTime, num> priceData;
  final List<DateTime> sortedDays;
  final NumberFormat formatter;

  const _PriceSparklineChart({required this.priceData, required this.sortedDays, required this.formatter});

  @override
  Widget build(BuildContext context) {
    if (sortedDays.isEmpty) return Container();
    final bounds = _calculateAxisBounds(priceData, sortedDays);
    return LineChart(
      LineChartData(
        lineTouchData: _buildLineTouchData(context, sortedDays),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (sortedDays.length - 1).toDouble(),
        minY: bounds.minY,
        maxY: bounds.maxY,
        lineBarsData: [_buildLineBarData()],
      ),
    );
  }

  LineTouchData _buildLineTouchData(BuildContext context, List<DateTime> sortedDays) {
    return LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => const Color(0xFF2C2C2E),
        tooltipBorder: BorderSide(color: Colors.orangeAccent.withOpacity(0.5)),
        getTooltipItems: (touchedSpots) {
          if (touchedSpots.isEmpty) return [];
          final spot = touchedSpots.first;
          final index = spot.x.toInt();
          if (index < 0 || index >= sortedDays.length) return [];

          final date = sortedDays[index];
          final price = spot.y;

          return [
            LineTooltipItem(
              '${date.formatYMD()}\n',
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
              children: [
                TextSpan(
                  text: formatter.format(price),
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
              ],
              textAlign: TextAlign.start,
            )
          ];
        },
      ),
      getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes
          .map((index) => TouchedSpotIndicatorData(
        FlLine(color: Colors.orange.withOpacity(0.7), strokeWidth: 1.5, dashArray: [4, 4]),
        FlDotData(getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 6, color: Colors.orange, strokeColor: Colors.black, strokeWidth: 2)),
      ))
          .toList(),
    );
  }

  LineChartBarData _buildLineBarData() {
    return LineChartBarData(spots: _createSpots(priceData, sortedDays), isCurved: true, gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.orange]), barWidth: 2.5, isStrokeCapRound: true, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.orange.withOpacity(0.3), Colors.orange.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)));
  }

  List<FlSpot> _createSpots(Map<DateTime, num> data, List<DateTime> days) {
    List<FlSpot> spots = [];
    if (data.isEmpty) return spots;
    num lastValue = data.values.firstWhere((v) => v > 0, orElse: () => 0.0);
    final normalizedData = {for (var entry in data.entries) entry.key.dateOnly(): entry.value};
    for (int i = 0; i < days.length; i++) {
      final day = days[i].dateOnly();
      if (normalizedData.containsKey(day) && normalizedData[day]! > 0) {
        lastValue = normalizedData[day]!;
      }
      spots.add(FlSpot(i.toDouble(), lastValue.toDouble()));
    }
    return spots;
  }

  ({double minY, double maxY}) _calculateAxisBounds(Map<DateTime, num> data, List<DateTime> days) {
    if (data.isEmpty) return (minY: 0, maxY: 1);
    final spots = _createSpots(data, days);
    if (spots.isEmpty) return (minY: 0, maxY: 1);
    double minY = double.maxFinite;
    double maxY = double.negativeInfinity;
    for (var spot in spots) {
      if (spot.y < minY) minY = spot.y;
      if (spot.y > maxY) maxY = spot.y;
    }

    final padding = (maxY - minY) * 0.1;
    minY -= padding;
    maxY += padding;
    if (minY < 0) minY = 0;

    return (minY: minY, maxY: maxY);
  }
}