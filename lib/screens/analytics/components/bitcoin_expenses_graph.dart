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
  final Map<DateTime, num> feeData;
  final Map<DateTime, num> incomeData;
  final Map<DateTime, num> spendingData;
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
    required this.feeData,
    required this.incomeData,
    required this.spendingData,
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
    // Line animation (runs once on load)
    _lineController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _lineAnimation = CurvedAnimation(parent: _lineController, curve: Curves.easeOut);
    _lineController.forward();

    // Background animation (loops continuously)
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
      color: Colors.black, // Set background to black
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
                    widget.isShowingMainData && widget.mainData != null
                        ? [widget.mainData!]
                        : [widget.incomeData, widget.spendingData, widget.feeData],
                    sortedDays,
                  );

                  return LineChart(
                    LineChartData(
                      lineTouchData: _buildLineTouchData(context, sortedDays),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: _calculateDateInterval(sortedDays.length),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 55,
                            interval: bounds.horizontalInterval,
                          ),
                        ),
                      ),
                      minX: 0,
                      maxX: (sortedDays.length - 1).toDouble().clamp(0, double.infinity),
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
    if (widget.isShowingMainData && widget.mainData != null) {
      lineBarsData.add(_createAnimatedLineBarData(
        data: widget.mainData!,
        sortedDays: sortedDays,
        color: Colors.orangeAccent,
        barWidth: 3,
        animationValue: animationValue,
        isMainData: true,
      ));
    } else {
      lineBarsData.add(_createAnimatedLineBarData(
        data: widget.incomeData,
        sortedDays: sortedDays,
        color: Colors.green,
        barWidth: 2,
        animationValue: animationValue,
      ));
      lineBarsData.add(_createAnimatedLineBarData(
        data: widget.spendingData,
        sortedDays: sortedDays,
        color: Colors.red,
        barWidth: 2,
        animationValue: animationValue,
      ));
      lineBarsData.add(_createAnimatedLineBarData(
        data: widget.feeData,
        sortedDays: sortedDays,
        color: Colors.grey,
        barWidth: 2,
        animationValue: animationValue,
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
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 3,
          color: color,
          strokeWidth: 1,
          strokeColor: Colors.white,
        ),
      ),
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
        tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        tooltipRoundedRadius: 12,
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          return touchedBarSpots.map((barSpot) {
            final flSpot = barSpot;
            final index = flSpot.x.toInt();
            if (index < 0 || index >= sortedDays.length) return null;
            final date = sortedDays[index];
            String text = '';
            final lineIndex = barSpot.barIndex;
            num value = flSpot.y;

            if (widget.isShowingMainData) {
              if (widget.isCurrency) {
                final formattedValuation = currencyFormat.format(value);
                final num btcBalance = widget.bitcoinBalanceByDayUnformatted[date] ?? 0;
                final formattedBtcBalance = btcAmountFormat.format(btcBalance);
                final num price = widget.priceByDay[date] ?? 0;
                final formattedPrice = priceCurrencyFormat.format(price);
                text = '${date.formatYMD()}\nValue: $formattedValuation\n($formattedBtcBalance BTC @ $formattedPrice/BTC)';
              } else {
                final formattedValue = '${value.toStringAsFixed(widget.btcFormat == 'BTC' ? 8 : 0)} ${widget.btcFormat}';
                text = '${date.formatYMD()}\n${widget.btcFormat}: $formattedValue';
              }
            } else {
              String lineName = '';
              if (lineIndex == 0) lineName = 'Income';
              else if (lineIndex == 1) lineName = 'Spending';
              else if (lineIndex == 2) lineName = 'Fees';
              final formattedValue = '${value.toStringAsFixed(widget.btcFormat == 'BTC' ? 8 : 0)} ${widget.btcFormat}';
              text = '${date.formatYMD()}\n$lineName: $formattedValue';
            }

            return LineTooltipItem(
              text,
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.left,
            );
          }).where((item) => item != null).cast<LineTooltipItem>().toList();
        },
      ),
      getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
        return spotIndexes.map((index) {
          return TouchedSpotIndicatorData(
            FlLine(color: barData.gradient?.colors.first ?? Colors.orange, strokeWidth: 2),
            FlDotData(
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 8,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: barData.gradient?.colors.first ?? Colors.orange,
              ),
            ),
          );
        }).toList();
      },
    );
  }

  ({double minY, double maxY, double horizontalInterval}) _calculateAxisBounds(
      List<Map<DateTime, num>> activeDataSets, List<DateTime> sortedDays) {
    if (activeDataSets.isEmpty || sortedDays.isEmpty) {
      return (minY: 0, maxY: 0.001, horizontalInterval: 0.0002); // Smaller defaults for tiny values
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
      maxY = 0.001; // Smaller default max for tiny values
    } else if (minY == maxY) {
      double padding = (maxY.abs() * 0.2).clamp(0.00001, double.infinity); // Reduced padding (20%) with tiny minimum
      if (maxY == 0) padding = 0.00001; // Minimum padding for zero
      minY = minY - padding;
      maxY = maxY + padding;
    } else {
      final range = maxY - minY;
      final padding = (range * 0.1).clamp(0.00001, double.infinity); // Reduced padding (10%) with tiny minimum
      maxY += padding;
      bool allNonNegative = allSpots.every((spots) => spots.every((spot) => spot.y >= 0));
      minY = allNonNegative ? 0 : minY - padding;
    }

    if (maxY > 0 && minY > 0) minY = 0;
    if (minY < 0 && maxY < 0) maxY = 0;

    final range = maxY - minY;
    double interval = range > 0 && range.isFinite ? (range / 8) : 0.0002; // Smaller steps (8 divisions) with tiny default
    double magnitude = pow(10, interval.abs().toStringAsFixed(8).split('.').last.indexOf(RegExp(r'[1-9]')) + 1).toDouble();

    double normalizedInterval = interval / magnitude;
    if (normalizedInterval >= 5) {
      interval = (interval / (magnitude * 5)).ceil() * magnitude * 5;
    } else if (normalizedInterval >= 2) {
      interval = (interval / (magnitude * 2)).ceil() * magnitude * 2;
    } else {
      interval = (interval / magnitude).ceil() * magnitude;
    }

    if (interval * 2 > range) {
      interval = range / 4; // Smaller steps (4 divisions) for tiny ranges
      magnitude = pow(10, interval.abs().toStringAsFixed(8).split('.').last.indexOf(RegExp(r'[1-9]')) + 1).toDouble();
      interval = (interval / magnitude).ceil() * magnitude;
    }

    if (interval <= 0 || !interval.isFinite) interval = (maxY - minY) / 5;
    if (interval <= 0 || !interval.isFinite) interval = 0.00001; // Tiny default interval

    minY = (minY / interval).floor() * interval;

    return (minY: minY, maxY: maxY, horizontalInterval: interval);
  }
}