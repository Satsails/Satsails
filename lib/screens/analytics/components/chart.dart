import 'dart:math';
import 'package:Satsails/translations/localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String formatMD() => DateFormat('dd/MM').format(this);
  String formatYMD() => DateFormat('dd/MM/yyyy').format(this);
  DateTime dateOnly() => DateTime(year, month, day);
}

class Chart extends StatefulWidget {
  final List<DateTime> selectedDays;
  final Map<DateTime, num> mainData;
  final Map<DateTime, num> bitcoinBalanceByDayformatted;
  final Map<DateTime, num> dollarBalanceByDay;
  final Map<DateTime, num> priceByDay;
  final String selectedCurrency;
  final bool isShowingMainData;
  final bool isCurrency;
  final String btcFormat;
  final bool isBitcoinAsset;
  // FIX: Added to identify the asset and display its correct ticker in the tooltip.
  final String selectedAsset;

  const Chart({
    super.key,
    required this.selectedDays,
    required this.mainData,
    required this.bitcoinBalanceByDayformatted,
    required this.dollarBalanceByDay,
    required this.priceByDay,
    required this.selectedCurrency,
    required this.isShowingMainData,
    required this.isCurrency,
    required this.btcFormat,
    required this.isBitcoinAsset,
    required this.selectedAsset, // FIX: Added to constructor.
  });

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> with TickerProviderStateMixin {
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

    _animationController.forward();
    _fadeController.forward();
  }

  @override
  void didUpdateWidget(Chart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mainData != oldWidget.mainData) {
      _animationController.forward(from: 0.0);
      _fadeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedDays.isEmpty) {
      return Center(child: Text('Select a date range.'.i18n, style: TextStyle(color: Colors.white70, fontSize: 16.sp)));
    }

    final sortedDays = List<DateTime>.from(widget.selectedDays)..sort((a, b) => a.compareTo(b));
    final bounds = _calculateAxisBounds(widget.mainData, sortedDays);

    return Padding(
      padding: EdgeInsets.only(right: 18.w, left: 8.w, top: 12.h, bottom: 12.h),
      child: AnimatedBuilder(
        animation: Listenable.merge([_animation, _fadeAnimation]),
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: LineChart(
              LineChartData(
                lineTouchData: _buildLineTouchData(context, sortedDays),
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
                lineBarsData: [_buildLineBarData(sortedDays, _animation.value)],
              ),
            ),
          );
        },
      ),
    );
  }

  LineChartBarData _buildLineBarData(List<DateTime> sortedDays, double animationValue) {
    final spots = _createSpots(widget.mainData, sortedDays);
    final animatedSpots = spots.sublist(0, (spots.length * animationValue).ceil());

    // FIX: Adjust curve smoothness based on the number of days for a better look.
    final double smoothness;
    if (sortedDays.length > 90) {
      smoothness = 0.25; // Less curve for long, dense ranges.
    } else if (sortedDays.length > 30) {
      smoothness = 0.4;  // Medium curve.
    } else {
      smoothness = 0.6;  // More curve for short, sparse ranges.
    }

    return LineChartBarData(
      spots: animatedSpots,
      isCurved: true,
      curveSmoothness: smoothness,
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
            String text;
            if (widget.isCurrency) {
              text = NumberFormat.compactSimpleCurrency(name: '').format(value);
            } else if (widget.isBitcoinAsset && widget.btcFormat == 'sats') {
              text = NumberFormat.compact().format(value);
            } else if (widget.isBitcoinAsset && widget.btcFormat == 'BTC') {
              text = NumberFormat('0.########').format(value);
            }
            else {
              text = NumberFormat.compact().format(value);
            }
            return SideTitleWidget(meta: meta, child: Text(text, style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp, fontWeight: FontWeight.w500)));
          },
        ),
      ),
    );
  }

  LineTouchData _buildLineTouchData(BuildContext context, List<DateTime> sortedDays) {
    return LineTouchData(
      handleBuiltInTouches: true,
      touchSpotThreshold: 20,
      touchTooltipData: LineTouchTooltipData(
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipColor: (_) => const Color(0xFF1C1C1E),
        tooltipBorder: BorderSide(color: Colors.white.withOpacity(0.2)),
        tooltipPadding: const EdgeInsets.all(12),
        tooltipBorderRadius: BorderRadius.circular(12.r),
        getTooltipItems: (touchedSpots) {
          if (touchedSpots.isEmpty) return [];
          final spot = touchedSpots.first;
          final index = spot.x.toInt();
          if (index < 0 || index >= sortedDays.length) return [];
          final date = sortedDays[index];

          final headerStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp);
          List<TextSpan> children = [
            TextSpan(text: '${date.formatYMD()}\n', style: headerStyle),
          ];

          if (widget.isCurrency && widget.isBitcoinAsset) {
            final currencyFormatter = NumberFormat.simpleCurrency(name: widget.selectedCurrency, decimalDigits: 2);
            final totalValue = _getValueForDate(widget.mainData, date);
            final initialValue = _getValueForDate(widget.mainData, sortedDays.first);
            final price = _getValueForDate(widget.priceByDay, date);
            final btcBalance = _getValueForDate(widget.bitcoinBalanceByDayformatted, date);

            final formattedBtcBalance = widget.btcFormat == 'sats'
                ? NumberFormat.decimalPattern().format(btcBalance)
                : NumberFormat('0.########').format(btcBalance);

            // Calculate percentage change
            TextSpan? percentageChangeSpan;
            if (initialValue > 0) {
              final percentageChange = ((totalValue - initialValue) / initialValue) * 100;
              final formattedPercentage = NumberFormat('+0.00;-0.00').format(percentageChange);
              final color = percentageChange >= 0.01 ? Colors.greenAccent : (percentageChange <= -0.01 ? Colors.redAccent : Colors.grey.shade400);

              percentageChangeSpan = TextSpan(
                text: ' ($formattedPercentage%)',
                style: TextStyle(color: color, fontSize: 14.sp, fontWeight: FontWeight.bold),
              );
            }

            children.addAll([
              TextSpan(text: '${"Valuation".i18n}\n', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 14.sp, height: 1.5)),
              TextSpan(
                children: [
                  TextSpan(text: currencyFormatter.format(totalValue), style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                  if (percentageChangeSpan != null) percentageChangeSpan,
                  const TextSpan(text: '\n\n')
                ],
              ),
              TextSpan(text: '${widget.btcFormat.toUpperCase()}: $formattedBtcBalance\n', style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp, height: 1.4)),
              TextSpan(text: '${"Price".i18n}: ${currencyFormatter.format(price)}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp)),
            ]);

          } else {
            final value = _getValueForDate(widget.mainData, date);
            String formattedValue;
            String unit = '';

            if (widget.isBitcoinAsset) {
              unit = widget.btcFormat.toUpperCase();
              formattedValue = widget.btcFormat == 'sats'
                  ? NumberFormat.decimalPattern().format(value)
                  : NumberFormat('0.########').format(value);
            } else {
              // For non-bitcoin assets like Depix, USDT, etc.
              // FIX: Use the actual asset's name for the unit instead of the settings currency.
              unit = widget.selectedAsset.split(' ').last; // e.g., "Liquid Bitcoin" -> "Bitcoin"
              formattedValue = NumberFormat.currency(symbol: '', decimalDigits: 2).format(value);
            }

            children.addAll([
              TextSpan(text: '${"Balance".i18n}\n', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 14.sp, height: 1.5)),
              TextSpan(text: '$formattedValue $unit', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
            ]);
          }

          return [LineTooltipItem('', const TextStyle(), children: children, textAlign: TextAlign.start)];
        },
      ),
      getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes.map((index) {
        return TouchedSpotIndicatorData(
          FlLine(color: Colors.white.withOpacity(0.7), strokeWidth: 2),
          FlDotData(
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(radius: 8, color: Colors.white, strokeColor: Colors.black, strokeWidth: 4),
          ),
        );
      }).toList(),
    );
  }

  List<FlSpot> _createSpots(Map<DateTime, num> data, List<DateTime> sortedDays) {
    List<FlSpot> spots = [];
    num lastValue = 0;
    final normalizedData = { for (var entry in data.entries) entry.key.dateOnly(): entry.value };
    for (int i = 0; i < sortedDays.length; i++) {
      final day = sortedDays[i].dateOnly();
      if (normalizedData.containsKey(day)) {
        lastValue = normalizedData[day]!;
      }
      spots.add(FlSpot(i.toDouble(), max(0, lastValue.toDouble())));
    }
    return spots;
  }

  num _getValueForDate(Map<DateTime, num> data, DateTime date) {
    final normalizedDate = date.dateOnly();
    num lastValue = 0;
    final sortedDataKeys = data.keys.toList()..sort();

    if (sortedDataKeys.isNotEmpty && normalizedDate.isBefore(sortedDataKeys.first)) {
      return 0;
    }

    for (var d in sortedDataKeys) {
      if (d.isBefore(normalizedDate) || d.isAtSameMomentAs(normalizedDate)) {
        lastValue = data[d]!;
      } else {
        break;
      }
    }
    return lastValue;
  }

  double _calculateDateInterval(int days) {
    if (days <= 1) return 1; if (days <= 14) return 2; if (days <= 35) return 5;
    if (days <= 90) return 15; if (days <= 180) return 30;
    return (days / 7).ceilToDouble();
  }

  ({double minY, double maxY, double horizontalInterval}) _calculateAxisBounds(Map<DateTime, num> dataSet, List<DateTime> sortedDays) {
    if (dataSet.isEmpty || sortedDays.isEmpty) return (minY: 0, maxY: 1, horizontalInterval: 0.2);

    double minY = double.maxFinite, maxY = double.negativeInfinity;
    final spots = _createSpots(dataSet, sortedDays);
    if(spots.isEmpty) return (minY: 0, maxY: 1, horizontalInterval: 0.2);

    for (var spot in spots) {
      if (spot.y < minY) minY = spot.y;
      if (spot.y > maxY) maxY = spot.y;
    }
    if (!minY.isFinite || !maxY.isFinite || minY == maxY) {
      minY = (minY.isFinite ? minY : 0);
      maxY = (maxY.isFinite ? maxY : 1) + (minY == 0 ? 1 : minY * 0.2);
    }
    minY = 0;
    maxY = maxY + (maxY * 0.1);
    if (maxY == 0) maxY = 1;
    final range = maxY - minY;
    return (minY: minY, maxY: maxY, horizontalInterval: range > 0 ? range / 4 : 1);
  }
}