import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
  final Map<DateTime, num> bitcoinBalanceByDayUnformatted;
  final Map<DateTime, num> dollarBalanceByDay;
  final Map<DateTime, num> priceByDay;
  final String selectedCurrency;
  final bool isShowingMainData;
  final bool isCurrency;
  final String btcFormat;

  const Chart({
    super.key,
    required this.selectedDays,
    this.mainData,
    required this.bitcoinBalanceByDayUnformatted,
    required this.dollarBalanceByDay,
    required this.priceByDay,
    required this.selectedCurrency,
    required this.isShowingMainData,
    required this.isCurrency,
    required this.btcFormat,
  });

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> with TickerProviderStateMixin {
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;
  late AnimationController _backgroundController;
  late Animation<Color?> _bgColorAnimation1;
  late Animation<Color?> _bgColorAnimation2;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _lineAnimation = CurvedAnimation(parent: _lineController, curve: Curves.easeOut);
    _lineController.forward();

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    _bgColorAnimation1 = ColorTween(
      begin: Colors.blue.withOpacity(0.1),
      end: Colors.purple.withOpacity(0.1),
    ).animate(_backgroundController);
    _bgColorAnimation2 = ColorTween(
      begin: Colors.purple.withOpacity(0.1),
      end: Colors.blue.withOpacity(0.1),
    ).animate(_backgroundController);
  }

  @override
  void dispose() {
    _lineController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedDays.isEmpty) {
      return const Center(
        child: Text(
          'Select a date range to view chart data.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final sortedDays = List<DateTime>.from(widget.selectedDays)..sort((a, b) => a.compareTo(b));

    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.only(right: 18.0, left: 8.0, top: 24, bottom: 12),
        child: Column(
          children: [
            Expanded(
              child: AnimatedBuilder(
                animation: _lineAnimation,
                builder: (context, child) {
                  final animationValue = _lineAnimation.value;
                  final lineBarsData = _buildLineBarsData(animationValue, sortedDays);
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
                        drawVerticalLine: true,
                        horizontalInterval: bounds.horizontalInterval,
                        verticalInterval: _calculateDateInterval(sortedDays.length),
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white.withOpacity(0.2),
                          strokeWidth: 0.5,
                        ),
                        getDrawingVerticalLine: (value) => FlLine(
                          color: Colors.white.withOpacity(0.2),
                          strokeWidth: 0.5,
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
                            reservedSize: 30,
                            interval: _calculateDateInterval(sortedDays.length),
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= sortedDays.length) return const SizedBox.shrink();
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  sortedDays[index].formatMD(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 55,
                            interval: bounds.horizontalInterval,
                            getTitlesWidget: (value, meta) {
                              final decimals = widget.btcFormat == 'BTC' && !widget.isCurrency ? 8 : 2;
                              String formattedValue;
                              if (value.abs() < 1 && widget.btcFormat == 'BTC' && !widget.isCurrency) {
                                formattedValue = value.toStringAsFixed(8);
                              } else {
                                formattedValue = value.toStringAsFixed(decimals);
                              }
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  formattedValue,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
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

  List<LineChartBarData> _buildLineBarsData(double animationValue, List<DateTime> sortedDays) {
    final List<LineChartBarData> lineBarsData = [];
    if (widget.mainData != null) {
      lineBarsData.add(_createAnimatedLineBarData(
        data: widget.mainData!,
        sortedDays: sortedDays,
        color: Colors.orangeAccent,
        barWidth: 3,
        animationValue: animationValue,
        isMainData: true,
      ));
    }
    return lineBarsData;
  }

  LineChartBarData _createAnimatedLineBarData({
    required Map<DateTime, num> data,
    required List<DateTime> sortedDays,
    required Color color,
    required double barWidth,
    required double animationValue,
    bool isMainData = false,
  }) {
    final spots = _createSpots(data, sortedDays).map((spot) => FlSpot(spot.x, spot.y * animationValue)).toList();
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      preventCurveOverShooting: true,
      gradient: LinearGradient(
        colors: isMainData ? [Colors.orangeAccent, Colors.yellow] : [color.withOpacity(0.5), color],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      barWidth: barWidth,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: isMainData
          ? BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [Colors.orange.withOpacity(0.3), Colors.orange.withOpacity(0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      )
          : BarAreaData(show: false),
    );
  }

  List<FlSpot> _createSpots(Map<DateTime, num> data, List<DateTime> sortedDays) {
    List<FlSpot> spots = [];
    num lastValue = 0;
    for (int i = 0; i < sortedDays.length; i++) {
      final day = sortedDays[i];
      if (data.containsKey(day)) lastValue = data[day]!;
      spots.add(FlSpot(i.toDouble(), lastValue.toDouble()));
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
    final currencyFormat = NumberFormat.currency(symbol: widget.selectedCurrency == 'USD' ? '\$' : widget.selectedCurrency, decimalDigits: 2);
    final btcAmountFormat = NumberFormat("0.########", "en_US");
    final priceCurrencyFormat = NumberFormat.currency(symbol: widget.selectedCurrency == 'USD' ? '\$' : '', decimalDigits: 2);

    return LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.black.withOpacity(0.9),
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.all(12),
        maxContentWidth: 200,
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          if (touchedBarSpots.isEmpty) return [];
          final flSpot = touchedBarSpots.first;
          final index = flSpot.x.toInt();
          if (index < 0 || index >= sortedDays.length) return [];
          final date = sortedDays[index];

          List<TextSpan> children = [
            TextSpan(
              text: '${date.formatYMD()}\n',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ];

          if (widget.mainData != null) {
            final value = widget.mainData![date] ?? 0;
            if (widget.isCurrency) {
              final formattedValuation = currencyFormat.format(value);
              final btcBalance = widget.bitcoinBalanceByDayUnformatted[date] ?? 0;
              final formattedBtcBalance = btcAmountFormat.format(btcBalance);
              final price = widget.priceByDay[date] ?? 0;
              final formattedPrice = priceCurrencyFormat.format(price);
              children.addAll([
                TextSpan(
                  text: 'Total Value: $formattedValuation\n',
                  style: const TextStyle(color: Colors.orangeAccent, fontSize: 14),
                ),
                TextSpan(
                  text: 'BTC: $formattedBtcBalance\n',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                TextSpan(
                  text: 'Price: $formattedPrice/BTC',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ]);
            } else {
              final formattedValue = '${value.toStringAsFixed(widget.btcFormat == 'BTC' ? 8 : 0)} ${widget.btcFormat}';
              children.add(
                TextSpan(
                  text: 'Balance: $formattedValue',
                  style: const TextStyle(color: Colors.orangeAccent, fontSize: 14),
                ),
              );
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
              color: barData.gradient?.colors.first ?? Colors.orange,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
            FlDotData(show: false),
          );
        }).toList();
      },
    );
  }

  ({double minY, double maxY, double horizontalInterval}) _calculateAxisBounds(
      List<Map<DateTime, num>> activeDataSets, List<DateTime> sortedDays) {
    if (activeDataSets.isEmpty || sortedDays.isEmpty) {
      return (minY: 0, maxY: 0.00000001, horizontalInterval: 0.000000002); // Adjusted for BTC sensitivity
    }

    double minY = double.maxFinite;
    double maxY = double.negativeInfinity;
    List<List<FlSpot>> allSpots = activeDataSets.map((dataSet) => _createSpots(dataSet, sortedDays)).toList();

    for (var spots in allSpots) {
      for (var spot in spots) {
        if (spot.y < minY) minY = spot.y;
        if (spot.y > maxY) maxY = spot.y;
      }
    }

    if (minY == double.maxFinite || maxY == double.negativeInfinity || minY.isNaN || maxY.isNaN) {
      minY = 0;
      maxY = 0.00000001; // Small default max for BTC
    } else if (minY == maxY) {
      double padding = (maxY.abs() * 0.2).clamp(0.00000001, double.infinity); // Fine padding for BTC
      if (maxY == 0) padding = 0.00000001;
      minY = minY - padding;
      maxY = maxY + padding;
    } else {
      final range = maxY - minY;
      final padding = (range * 0.1).clamp(0.00000001, double.infinity); // Fine padding for BTC
      maxY += padding;
      bool allNonNegative = allSpots.every((spots) => spots.every((spot) => spot.y >= 0));
      minY = allNonNegative ? 0 : minY - padding;
    }

    if (maxY > 0 && minY > 0) minY = 0;
    if (minY < 0 && maxY < 0) maxY = 0;

    final range = maxY - minY;
    double interval = range > 0 && range.isFinite ? (range / 8) : 0.000000002; // Fine interval for BTC
    double magnitude = pow(10, interval.abs().toStringAsFixed(8).split('.').last.indexOf(RegExp(r'[1-9]')) - 1).toDouble();

    double normalizedInterval = interval / magnitude;
    if (normalizedInterval >= 5) {
      interval = (interval / (magnitude * 5)).ceil() * magnitude * 5;
    } else if (normalizedInterval >= 2) {
      interval = (interval / (magnitude * 2)).ceil() * magnitude * 2;
    } else {
      interval = (interval / magnitude).ceil() * magnitude;
    }

    if (interval * 2 > range) {
      interval = range / 4;
      magnitude = pow(10, interval.abs().toStringAsFixed(8).split('.').last.indexOf(RegExp(r'[1-9]')) - 1).toDouble();
      interval = (interval / magnitude).ceil() * magnitude;
    }

    if (interval <= 0 || !interval.isFinite) interval = (maxY - minY) / 5;
    if (interval <= 0 || !interval.isFinite) interval = 0.00000001; // Fine default interval for BTC

    minY = (minY / interval).floor() * interval;

    return (minY: minY, maxY: maxY, horizontalInterval: interval);
  }
}