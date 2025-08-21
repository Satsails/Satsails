// lib/screens/analytics/components/bitcoin_price_chart.dart

import 'dart:math';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/models/transactions_model.dart';
import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/screens/analytics/components/chart.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class BitcoinPriceChart extends ConsumerStatefulWidget {
  final String selectedAsset;
  const BitcoinPriceChart({super.key, required this.selectedAsset});

  @override
  ConsumerState<BitcoinPriceChart> createState() => _BitcoinPriceChartState();
}

class _BitcoinPriceChartState extends ConsumerState<BitcoinPriceChart> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic);

    _fadeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marketDataAsync = ref.watch(filteredBitcoinMarketDataProvider);
    final allTxs = ref.watch(transactionNotifierProvider).allTransactions;

    return marketDataAsync.when(
      data: (marketData) {
        if (marketData.isEmpty) {
          return Center(child: Text("No price data for this range".i18n, style: TextStyle(color: Colors.white70, fontSize: 16.sp)));
        }

        _animationController.forward(from: 0.0);
        _fadeController.forward(from: 0.0);

        final priceByDay = {for (var dp in marketData) dp.date.toLocal().dateOnly(): dp.price ?? 0};
        final sortedDays = priceByDay.keys.toList()..sort((a, b) => a.compareTo(b));
        final bounds = _calculateAxisBounds(priceByDay, sortedDays);

        // --- Transaction Processing ---
        final Map<DateTime, double> inAmountByDay = {};
        final Map<DateTime, double> outAmountByDay = {};
        final Map<DateTime, double> netAmountByDay = {};

        final filteredTxs = allTxs.where((tx) => tx.asset == widget.selectedAsset);

        for (var tx in filteredTxs) {
          final txDay = tx.timestamp.dateOnly();
          if (priceByDay.containsKey(txDay)) {
            final amountInSats = tx.amount.toDouble();
            if (tx.type == TransactionType.received) {
              inAmountByDay.update(txDay, (value) => value + amountInSats, ifAbsent: () => amountInSats);
              netAmountByDay.update(txDay, (value) => value + amountInSats, ifAbsent: () => amountInSats);
            } else {
              outAmountByDay.update(txDay, (value) => value + amountInSats, ifAbsent: () => amountInSats);
              netAmountByDay.update(txDay, (value) => value - amountInSats, ifAbsent: () => -amountInSats);
            }
          }
        }

        final transactionDays = inAmountByDay.keys.toSet().union(outAmountByDay.keys.toSet());
        final transactionSpots = transactionDays.map((day) {
          final index = sortedDays.indexWhere((d) => d.isAtSameMomentAs(day));
          return index != -1 ? FlSpot(index.toDouble(), priceByDay[day]!.toDouble()) : null;
        }).whereType<FlSpot>().toList();
        // --- End of Transaction Processing ---

        return Padding(
          padding: EdgeInsets.only(right: 18.w, left: 8.w, top: 12.h, bottom: 12.h),
          child: AnimatedBuilder(
            animation: Listenable.merge([_animation, _fadeAnimation]),
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: LineChart(
                  LineChartData(
                    lineTouchData: _buildLineTouchData(context, sortedDays, priceByDay, inAmountByDay, outAmountByDay),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: bounds.horizontalInterval,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade800,
                        strokeWidth: 0.8,
                        dashArray: [4, 4],
                      ),
                    ),
                    titlesData: _buildTitlesData(sortedDays, bounds),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: (sortedDays.length - 1).toDouble().clamp(0, double.infinity),
                    minY: bounds.minY,
                    maxY: bounds.maxY,
                    lineBarsData: [
                      _buildPriceLineBarData(priceByDay, sortedDays, _animation.value),
                      _buildTransactionDotsBarData(transactionSpots, netAmountByDay, sortedDays),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error loading price data".i18n)),
    );
  }

  LineChartBarData _buildPriceLineBarData(Map<DateTime, num> priceByDay, List<DateTime> sortedDays, double animationValue) {
    final spots = _createSpots(priceByDay, sortedDays);
    final animatedSpots = spots.sublist(0, (spots.length * animationValue).ceil());

    return LineChartBarData(
      spots: animatedSpots,
      isCurved: true,
      curveSmoothness: 0.6,
      preventCurveOverShooting: true,
      color: Colors.white,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      shadow: Shadow(
        color: Colors.black.withOpacity(0.4),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    );
  }

  LineChartBarData _buildTransactionDotsBarData(List<FlSpot> spots, Map<DateTime, double> netAmountByDay, List<DateTime> sortedDays) {
    return LineChartBarData(
      spots: spots,
      show: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final int spotIndex = spot.x.toInt();
          if (spotIndex < 0 || spotIndex >= sortedDays.length) {
            return FlDotCirclePainter(radius: 0, color: Colors.transparent, strokeWidth: 0);
          }

          final date = sortedDays[spotIndex];
          final netAmount = netAmountByDay[date] ?? 0;
          final color = netAmount >= 0 ? Colors.greenAccent : Colors.redAccent;
          return FlDotCirclePainter(
              radius: 5,
              color: color,
              strokeColor: Colors.black.withOpacity(0.6),
              strokeWidth: 2);
        },
      ),
      barWidth: 0,
    );
  }

  FlTitlesData _buildTitlesData(List<DateTime> sortedDays, ({double minY, double maxY, double horizontalInterval}) bounds) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30.h,
          interval: _calculateDateInterval(sortedDays.length),
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= sortedDays.length) return const SizedBox.shrink();
            return SideTitleWidget(meta: meta, child: Text(sortedDays[index].formatMD(), style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp, fontWeight: FontWeight.w500)));
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 80.w,
          interval: bounds.horizontalInterval,
          getTitlesWidget: (value, meta) {
            final text = NumberFormat.compactSimpleCurrency().format(value);
            return SideTitleWidget(meta: meta, child: Text(text, style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp, fontWeight: FontWeight.w500)));
          },
        ),
      ),
    );
  }

  LineTouchData _buildLineTouchData(BuildContext context, List<DateTime> sortedDays, Map<DateTime, num> priceByDay, Map<DateTime, double> inAmountByDay, Map<DateTime, double> outAmountByDay) {
    final assetTicker = widget.selectedAsset == 'lbtc' ? 'L-BTC' : 'BTC';

    return LineTouchData(
      handleBuiltInTouches: true,
      touchSpotThreshold: 20,
      touchCallback: (event, response) {
        if (event is FlTapUpEvent && response != null && response.lineBarSpots != null && response.lineBarSpots!.isNotEmpty) {
          final spot = response.lineBarSpots!.first;
          if (spot.barIndex == 1 || spot.barIndex == 2) {
            HapticFeedback.lightImpact();
          }
        }
      },
      touchTooltipData: LineTouchTooltipData(
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipColor: (_) => const Color(0xFF1C1C1E),
        tooltipBorder: BorderSide(color: Colors.white.withOpacity(0.2)),
        tooltipPadding: const EdgeInsets.all(12),
        tooltipBorderRadius: BorderRadius.circular(12.r),
        getTooltipItems: (touchedSpots) {
          if (touchedSpots.isEmpty) {
            return [];
          }

          final settings = ref.read(settingsProvider);
          final btcFormat = settings.btcFormat;

          return touchedSpots.map((spot) {
            if (spot.barIndex != 0) {
              return LineTooltipItem('', const TextStyle());
            }

            final index = spot.x.toInt();
            if (index < 0 || index >= sortedDays.length) {
              return LineTooltipItem('', const TextStyle());
            }

            final date = sortedDays[index];
            final price = priceByDay[date];
            final received = inAmountByDay[date];
            final sent = outAmountByDay[date];

            List<TextSpan> children = [];

            // Always show the date at the top
            children.add(
                TextSpan(
                  text: '${date.formatYMD()}\n',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp, height: 1.5),
                )
            );

            // Add price if present
            if (price != null) {
              final formattedPrice = NumberFormat.simpleCurrency(decimalDigits: 2).format(price);
              children.addAll([
                TextSpan(
                  text: "Price".i18n + ': ',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                ),
                TextSpan(
                  text: formattedPrice + '\n',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              ]);
            }

            // Add received amount if present
            if (received != null && received > 0) {
              final formattedAmount = btcInDenominationFormatted(received, btcFormat);
              final unit = btcFormat == 'sats' ? 'sats' : assetTicker;
              children.addAll([
                TextSpan(
                  text: "Received".i18n + ': ',
                  style: TextStyle(color: Colors.greenAccent, fontSize: 14.sp),
                ),
                TextSpan(
                  text: '$formattedAmount $unit\n',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              ]);
            }

            // Add sent amount if present
            if (sent != null && sent > 0) {
              final formattedAmount = btcInDenominationFormatted(sent, btcFormat);
              final unit = btcFormat == 'sats' ? 'sats' : assetTicker;
              children.addAll([
                TextSpan(
                  text: "Sent".i18n + ': ',
                  style: TextStyle(color: Colors.redAccent, fontSize: 14.sp),
                ),
                TextSpan(
                  text: '$formattedAmount $unit\n',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              ]);
            }

            return LineTooltipItem(
                '',
                const TextStyle(),
                children: children,
                textAlign: TextAlign.start
            );
          }).toList();
        },
      ),
      getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes.map((index) {
        return TouchedSpotIndicatorData(
          FlLine(color: Colors.white.withOpacity(0.7), strokeWidth: 2),
          FlDotData(getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 8, color: Colors.white, strokeColor: Colors.black, strokeWidth: 4)),
        );
      }).toList(),
    );
  }

  List<FlSpot> _createSpots(Map<DateTime, num> data, List<DateTime> sortedDays) {
    return sortedDays.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      final value = data[day] ?? 0;
      return FlSpot(index.toDouble(), max(0, value.toDouble()));
    }).toList();
  }

  double _calculateDateInterval(int days) {
    if (days <= 1) return 1; if (days <= 14) return 2; if (days <= 35) return 5;
    if (days <= 90) return 15; if (days <= 180) return 30;
    return (days / 7).ceilToDouble();
  }

  ({double minY, double maxY, double horizontalInterval}) _calculateAxisBounds(Map<DateTime, num> dataSet, List<DateTime> sortedDays) {
    if (dataSet.isEmpty || sortedDays.isEmpty) return (minY: 0, maxY: 1, horizontalInterval: 0.2);
    final values = sortedDays.map((day) => dataSet[day]?.toDouble() ?? 0.0).toList();
    double minY = values.reduce(min);
    double maxY = values.reduce(max);
    if (minY == maxY) {
      minY = max(0, minY - minY * 0.1);
      maxY = maxY + maxY * 0.1;
    }
    if (maxY == 0) maxY = 1;
    final padding = (maxY - minY) * 0.1;
    minY = max(0, minY - padding);
    maxY = maxY + padding;
    final range = maxY - minY;
    return (minY: minY, maxY: maxY, horizontalInterval: range > 0 ? range / 4 : 1);
  }
}