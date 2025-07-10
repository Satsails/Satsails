import 'dart:math';
import 'package:Satsails/translations/translations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// The missing DateTime extension has been restored.
extension DateTimeExtension on DateTime {
  String formatMD() => DateFormat('MM/dd').format(this);
  String formatYMD() => DateFormat('yyyy/MM/dd').format(this);
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
  });

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> with TickerProviderStateMixin {
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();
    _lineController = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _lineAnimation = CurvedAnimation(parent: _lineController, curve: Curves.easeInOut);
    _lineController.forward();
  }

  @override
  void didUpdateWidget(Chart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mainData != oldWidget.mainData) {
      _lineController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _lineController.dispose();
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
        animation: _lineAnimation,
        builder: (context, child) => LineChart(
          LineChartData(
            lineTouchData: _buildLineTouchData(context, sortedDays),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: bounds.horizontalInterval,
              getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade800, strokeWidth: 1),
            ),
            titlesData: _buildTitlesData(sortedDays, bounds),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (sortedDays.length - 1).toDouble().clamp(0, double.infinity),
            minY: bounds.minY,
            maxY: bounds.maxY,
            lineBarsData: [_buildLineBarData(sortedDays, _lineAnimation.value)],
          ),
        ),
      ),
    );
  }

  LineChartBarData _buildLineBarData(List<DateTime> sortedDays, double animationValue) {
    final spots = _createSpots(widget.mainData, sortedDays).map((spot) => FlSpot(spot.x, spot.y * animationValue)).toList();
    return LineChartBarData(
      spots: spots, isCurved: true, preventCurveOverShooting: true,
      gradient: const LinearGradient(colors: [Colors.orangeAccent, Colors.orange]),
      barWidth: 3.5, isStrokeCapRound: true, dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(colors: [Colors.orange.withOpacity(0.3), Colors.orange.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
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
          showTitles: true, reservedSize: 30.h,
          interval: _calculateDateInterval(sortedDays.length),
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= sortedDays.length) return const SizedBox.shrink();
            return SideTitleWidget(meta: meta, child: Text(sortedDays[index].formatMD(), style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp)));
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true, reservedSize: 80.w,
          interval: bounds.horizontalInterval,
          getTitlesWidget: (value, meta) {
            final decimals = widget.isBitcoinAsset ? (widget.btcFormat == 'BTC' && !widget.isCurrency ? 8 : (widget.btcFormat == 'sats' && !widget.isCurrency ? 0 : 2)) : 2;
            return SideTitleWidget(meta: meta, child: Text(value.toStringAsFixed(decimals), style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp)));
          },
        ),
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

          final currencyFormatter = NumberFormat.simpleCurrency(name: widget.selectedCurrency);
          final value = _getValueForDate(widget.mainData, date);

          List<TextSpan> children = [
            TextSpan(text: '${date.formatYMD()}\n', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
          ];

          if (widget.isCurrency && widget.isBitcoinAsset) {
            final price = _getValueForDate(widget.priceByDay, date);
            final btcBalance = _getValueForDate(widget.bitcoinBalanceByDayformatted, date);
            children.addAll([
              TextSpan(text: 'Value: ${currencyFormatter.format(value)}\n', style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
              TextSpan(text: '${widget.btcFormat.toUpperCase()}: $btcBalance\n', style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp)),
              TextSpan(text: 'Price: ${currencyFormatter.format(price)}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp)),
            ]);
          } else {
            children.add(TextSpan(text: 'Balance: $value', style: TextStyle(color: Colors.white70, fontSize: 14.sp)));
          }

          return [LineTooltipItem('', const TextStyle(), children: children, textAlign: TextAlign.start)];
        },
      ),
      getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes.map((index) => TouchedSpotIndicatorData(
        FlLine(color: Colors.orange.withOpacity(0.7), strokeWidth: 1.5, dashArray: [4, 4]),
        FlDotData(getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 6, color: Colors.orange, strokeColor: Colors.black, strokeWidth: 2)),
      )).toList(),
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

  // =========================================================================
  // FIX: This method is now correctly implemented to be simple and type-safe.
  // =========================================================================
  num _getValueForDate(Map<DateTime, num> data, DateTime date) {
    final normalizedDate = date.dateOnly();
    // Provides the value for the key, or returns 0 if the key is not found.
    return data[normalizedDate] ?? 0;
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