import 'dart:math';
import 'package:Satsails/helpers/string_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:intl/intl.dart';

// Helper extension for date formatting
extension DateTimeExtension on DateTime {
  String formatMD() => DateFormat('MM/dd').format(this);
  String formatYMD() => DateFormat('yyyy/MM/dd').format(this);
  DateTime dateOnly() => DateTime(year, month, day);
}

class Chart extends StatefulWidget {
  final List<DateTime> selectedDays;
  final Map<DateTime, num>? mainData;
  final Map<DateTime, num> bitcoinBalanceByDayformatted;
  final Map<DateTime, num> dollarBalanceByDay;
  final Map<DateTime, num> priceByDay;
  final String selectedCurrency;
  final bool isShowingMainData;
  final bool isCurrency;
  final String btcFormat;
  final bool isBitcoinAsset;

  const Chart({
    super.key,
    required this.selectedDays,
    this.mainData,
    required this.bitcoinBalanceByDayformatted,
    required this.dollarBalanceByDay,
    required this.priceByDay,
    required this.selectedCurrency,
    required this.isShowingMainData,
    required this.isCurrency,
    required this.btcFormat,
    required this.isBitcoinAsset,
  });

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> with TickerProviderStateMixin {
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _lineAnimation = CurvedAnimation(parent: _lineController, curve: Curves.easeOutCubic);
    _lineController.forward();

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _lineController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedDays.isEmpty) {
      return Center(
        child: Text(
          'Select a date range to view chart data.'.i18n,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16.sp,
          ),
        ),
      );
    }

    final sortedDays = List<DateTime>.from(widget.selectedDays)..sort((a, b) => a.compareTo(b));

    return Container(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.only(
          right: 18.w,
          left: 8.w,
          top: 24.h,
          bottom: 12.h,
        ),
        child: Column(
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge([_lineAnimation, _glowAnimation]),
                builder: (context, child) {
                  final animationValue = _lineAnimation.value;
                  final glowValue = _glowAnimation.value;
                  final lineBarsData = _buildLineBarsData(animationValue, sortedDays, glowValue);
                  final bounds = _calculateAxisBounds(
                    widget.mainData != null ? [widget.mainData!] : [],
                    sortedDays,
                  );

                  return LineChart(
                    LineChartData(
                      lineTouchData: _buildLineTouchData(context, sortedDays),
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        drawVerticalLine: false,
                        horizontalInterval: bounds.horizontalInterval,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white.withOpacity(0.2),
                          strokeWidth: 0.5.w,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
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
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  sortedDays[index].formatMD(),
                                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 90.w,
                            interval: bounds.horizontalInterval,
                            getTitlesWidget: (value, meta) {
                              final decimals = widget.isBitcoinAsset
                                  ? (widget.btcFormat == 'BTC' && !widget.isCurrency ? 8 : (widget.btcFormat == 'sats' && !widget.isCurrency ? 0 : 2))
                                  : 2;
                              String formattedValue = value.toStringAsFixed(decimals);
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  formattedValue,
                                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      minX: 0,
                      maxX: (sortedDays.length - 1).toDouble().clamp(0, double.infinity),
                      minY: bounds.minY,
                      maxY: bounds.maxY,
                      lineBarsData: lineBarsData,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods ---

  List<LineChartBarData> _buildLineBarsData(double animationValue, List<DateTime> sortedDays, double glowValue) {
    final List<LineChartBarData> lineBarsData = [];
    if (widget.mainData != null) {
      lineBarsData.add(_createAnimatedLineBarData(
        data: widget.mainData!,
        sortedDays: sortedDays,
        barWidth: 3.5.w,
        animationValue: animationValue,
        glowValue: glowValue,
        isMainData: true,
      ));
    }
    return lineBarsData;
  }

  LineChartBarData _createAnimatedLineBarData({
    required Map<DateTime, num> data,
    required List<DateTime> sortedDays,
    required double barWidth,
    required double animationValue,
    required double glowValue,
    bool isMainData = false,
  }) {
    final spots = _createSpots(data, sortedDays).map((spot) => FlSpot(
      spot.x,
      spot.y * animationValue, // Use raw spot.y without scaling
    )).toList();
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      preventCurveOverShooting: true,
      gradient: LinearGradient(
        colors: [Colors.greenAccent, Colors.green],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      barWidth: barWidth,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            Colors.greenAccent.withOpacity(0.2 * glowValue),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      shadow: Shadow(
        color: Colors.greenAccent.withOpacity(0.3 * glowValue),
        blurRadius: 8,
      ),
    );
  }

  List<FlSpot> _createSpots(Map<DateTime, num> data, List<DateTime> sortedDays) {
    List<FlSpot> spots = [];
    num lastValue = 0;

    // Create a map with normalized keys (year, month, day only)
    final normalizedData = {
      for (var entry in data.entries)
        DateTime(entry.key.year, entry.key.month, entry.key.day): entry.value
    };

    for (int i = 0; i < sortedDays.length; i++) {
      final day = sortedDays[i];
      // Normalize day to year, month, day only (though sortedDays should already be at midnight)
      final normalizedDay = DateTime(day.year, day.month, day.day);

      if (normalizedData.containsKey(normalizedDay)) {
        lastValue = normalizedData[normalizedDay]!;
      }
      spots.add(FlSpot(i.toDouble(), max(0, lastValue.toDouble())));
    }

    return spots;
  }

  double _calculateDateInterval(int numberOfDays) {
    if (numberOfDays <= 1) return 1;
    if (numberOfDays <= 7) return 1;
    if (numberOfDays <= 14) return 2;
    if (numberOfDays <= 35) return 5;
    if (numberOfDays <= 90) return 10;
    if (numberOfDays <= 180) return 20;
    return (numberOfDays / 7).ceilToDouble();
  }

  LineTouchData _buildLineTouchData(BuildContext context, List<DateTime> sortedDays) {
    return LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.black.withOpacity(0.9),
        tooltipRoundedRadius: 8.r,
        tooltipPadding: EdgeInsets.all(12.w),
        maxContentWidth: 200.w,
        fitInsideHorizontally: true,
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          if (touchedBarSpots.isEmpty) return [];
          final flSpot = touchedBarSpots.first;
          final index = flSpot.x.toInt();
          if (index < 0 || index >= sortedDays.length) return [];
          final date = sortedDays[index];

          List<TextSpan> children = [
            TextSpan(
              text: '${date.formatYMD()}\n',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ];

          if (widget.mainData != null) {
            final value = _getValueForDate(widget.mainData!, date);
            if (widget.isCurrency && widget.isBitcoinAsset) {
              final price = _getValueForDate(widget.priceByDay, date);
              final formattedValuation = currencyFormat(value.toDouble(), widget.selectedCurrency);
              final formattedPrice = currencyFormat(price.toDouble(), widget.selectedCurrency);
              final btcBalance = _getValueForDate(widget.bitcoinBalanceByDayformatted, date);
              children.addAll([
                TextSpan(
                  text: 'Total Value: %s\n'.i18n.fill([formattedValuation]),
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
                TextSpan(
                  text: '%s: %s\n'.i18n.fill([
                    widget.btcFormat != 'sats' ? 'BTC' : 'Sats',
                    btcBalance,
                  ]),
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
                TextSpan(
                  text: 'Price: %s/BTC'.i18n.fill([formattedPrice]),
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
              ]);

            } else {
              if (widget.isBitcoinAsset) {
                children.add(
                  TextSpan(
                    text: 'Balance: %s'.i18n.fill([value]),
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                );
              } else {
                final amount = value;
                children.add(
                  TextSpan(
                    text: 'Balance: %s'.i18n.fill([amount]),
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                );
              }
            }
          }

          return [
            LineTooltipItem(
              '',
              const TextStyle(),
              children: children,
            ),
          ];
        },
      ),
      getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
        return spotIndexes.map((index) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: Colors.greenAccent.withOpacity(0.7),
              strokeWidth: 1.w,
              dashArray: [4, 4],
            ),
            FlDotData(show: true),
          );
        }).toList();
      },
    );
  }

  num _getValueForDate(Map<DateTime, num> data, DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return data.entries.firstWhere(
          (entry) => entry.key.year == normalizedDate.year &&
          entry.key.month == normalizedDate.month &&
          entry.key.day == normalizedDate.day,
      orElse: () => MapEntry(DateTime(0), 0),
    ).value;
  }

  ({double minY, double maxY, double horizontalInterval}) _calculateAxisBounds(
      List<Map<DateTime, num>> activeDataSets, List<DateTime> sortedDays) {
    if (activeDataSets.isEmpty || sortedDays.isEmpty) {
      return (minY: 0, maxY: 1, horizontalInterval: 0.2);
    }

    double minY = double.maxFinite;
    double maxY = double.negativeInfinity;
    List<List<FlSpot>> allSpots = activeDataSets.map((dataSet) => _createSpots(dataSet, sortedDays)).toList();

    for (var spots in allSpots) {
      for (var spot in spots) {
        double adjustedY = spot.y; // Use raw value directly
        if (adjustedY < minY) minY = adjustedY;
        if (adjustedY > maxY) maxY = adjustedY;
      }
    }

    // Handle edge cases
    if (minY == double.maxFinite || maxY == double.negativeInfinity || minY.isNaN || maxY.isNaN) {
      minY = 0;
      maxY = 1;
    } else if (minY == maxY) {
      minY -= 1; // Simple padding
      maxY += 1;
    }

    // Ensure minY is never below 0
    if (minY < 0) minY = 0;

    final range = maxY - minY;
    final horizontalInterval = range > 0 ? range / 5 : 0.2;

    return (minY: minY, maxY: maxY, horizontalInterval: horizontalInterval);
  }
}