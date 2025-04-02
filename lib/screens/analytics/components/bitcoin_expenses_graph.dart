import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates and numbers
import 'package:Satsails/providers/settings_provider.dart'; // Assuming BtcFormat enum is here or accessible

// Helper extension for date formatting
extension DateTimeExtension on DateTime {
  String formatMD() => DateFormat('MM/dd').format(this);
  String formatYMD() => DateFormat('yyyy/MM/dd').format(this);
  DateTime dateOnly() => DateTime(year, month, day);
}

class ProfessionalLineChart extends StatelessWidget {
  final List<DateTime> selectedDays;
  final Map<DateTime, num> feeData;
  final Map<DateTime, num> incomeData;
  final Map<DateTime, num> spendingData;
  final Map<DateTime, num>? mainData; // Can be BTC or Currency balance
  final Map<DateTime, num> bitcoinBalanceByDayUnformatted; // For tooltips if needed
  final Map<DateTime, num> dollarBalanceByDay; // For tooltips if needed
  final String selectedCurrency;
  final bool isShowingMainData;
  final bool isCurrency; // True if mainData represents currency balance
  final String btcFormat; // Pass the BTC format for display

  const ProfessionalLineChart({
    super.key,
    required this.selectedDays,
    required this.feeData,
    required this.incomeData,
    required this.spendingData,
    this.mainData,
    required this.bitcoinBalanceByDayUnformatted,
    required this.dollarBalanceByDay,
    required this.selectedCurrency,
    required this.isShowingMainData,
    required this.isCurrency,
    required this.btcFormat, // Add btcFormat here
  });

  @override
  Widget build(BuildContext context) {
    if (selectedDays.isEmpty) {
      return const Center(
        child: Text('Select a date range to view chart data.', style: TextStyle(color: Colors.white70)),
      );
    }

    // Ensure days are sorted for correct X-axis mapping
    final sortedDays = List<DateTime>.from(selectedDays)..sort((a, b) => a.compareTo(b));

    final List<LineChartBarData> lineBarsData = [];
    final List<Map<DateTime, num>> activeDataSets = [];

    // --- 1. Determine which lines to show ---
    if (isShowingMainData && mainData != null) {
      lineBarsData.add(_createLineBarData(
        data: mainData!,
        sortedDays: sortedDays,
        color: Colors.orangeAccent, // Main balance line
        barWidth: 3,
      ));
      activeDataSets.add(mainData!);
    } else {
      // Statistics view
      lineBarsData.add(_createLineBarData(
        data: incomeData,
        sortedDays: sortedDays,
        color: Colors.green, // Income line
        barWidth: 2,
      ));
      lineBarsData.add(_createLineBarData(
        data: spendingData,
        sortedDays: sortedDays,
        color: Colors.red, // Spending line
        barWidth: 2,
      ));
      lineBarsData.add(_createLineBarData(
        data: feeData,
        sortedDays: sortedDays,
        color: Colors.grey, // Fee line
        barWidth: 2,
      ));
      activeDataSets.addAll([incomeData, spendingData, feeData]);
    }

    // --- 2. Calculate Axis Bounds ---
    final bounds = _calculateAxisBounds(activeDataSets, sortedDays);

    // --- 3. Build the Chart ---
    return Padding(
      padding: const EdgeInsets.only(right: 18.0, left: 8.0, top: 24, bottom: 12),
      child: LineChart(
        LineChartData(
          // --- Interaction ---
          lineTouchData: _buildLineTouchData(context, sortedDays),

          // --- Grid and Borders ---
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            horizontalInterval: bounds.horizontalInterval,
            verticalInterval: 1, // We draw horizontal lines based on titles
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Colors.white10,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return const FlLine(
                color: Colors.white10,
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white24, width: 1),
          ),

          // --- Axis Titles ---
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: _calculateDateInterval(sortedDays.length),
                getTitlesWidget: (value, meta) => _bottomTitleWidgets(value, meta, sortedDays),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 55, // Increased size for potentially longer numbers/symbols
                getTitlesWidget: (value, meta) => _leftTitleWidgets(value, meta, bounds.maxY),
                interval: bounds.horizontalInterval,
              ),
            ),
          ),

          // --- Data and Bounds ---
          minX: 0,
          maxX: (sortedDays.length - 1).toDouble(),
          minY: bounds.minY,
          maxY: bounds.maxY,
          lineBarsData: lineBarsData,

          // Optional: Chart background color
          // backgroundColor: Colors.grey[850],
        ),
        duration: const Duration(milliseconds: 250), // Optional animation
      ),
    );
  }

  // --- Helper Methods ---

  /// Creates FlSpot list for a given data map and sorted days
  List<FlSpot> _createSpots(Map<DateTime, num> data, List<DateTime> sortedDays) {
    List<FlSpot> spots = [];
    for (int i = 0; i < sortedDays.length; i++) {
      final day = sortedDays[i];
      final value = data[day] ?? 0; // Default to 0 if day not in map
      spots.add(FlSpot(i.toDouble(), value.toDouble()));
    }
    // Handle case where the map might be empty but days aren't
    if (spots.isEmpty && sortedDays.isNotEmpty) {
      spots = List.generate(sortedDays.length, (index) => FlSpot(index.toDouble(), 0.0));
    }
    return spots;
  }

  /// Creates a LineChartBarData configuration
  LineChartBarData _createLineBarData({
    required Map<DateTime, num> data,
    required List<DateTime> sortedDays,
    required Color color,
    required double barWidth,
    List<int>? dashArray,
  }) {
    return LineChartBarData(
      spots: _createSpots(data, sortedDays),
      isCurved: true,
      color: color,
      barWidth: barWidth,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false), // Hide dots on the line
      belowBarData: BarAreaData(show: false), // Don't fill below line
      dashArray: dashArray,
    );
  }

  /// Calculates appropriate interval for bottom axis date labels
  double _calculateDateInterval(int numberOfDays) {
    if (numberOfDays <= 7) return 1; // Show every day for a week or less
    if (numberOfDays <= 14) return 2; // Show every 2 days for up to two weeks
    if (numberOfDays <= 31) return 4; // Show every 4 days for up to a month
    if (numberOfDays <= 90) return 10; // Approx every 10 days for 3 months
    if (numberOfDays <= 180) return 20; // Approx every 20 days for 6 months
    return 30; // Approx every 30 days for longer periods
  }

  /// Builds the widget for bottom axis titles (Dates)
  Widget _bottomTitleWidgets(double value, TitleMeta meta, List<DateTime> sortedDays) {
    const style = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    Widget text;
    final index = value.toInt();

    // Ensure index is within bounds
    if (index >= 0 && index < sortedDays.length) {
      // Use shorter format for brevity on axis
      text = Text(sortedDays[index].formatMD(), style: style);
    } else {
      text = const Text('', style: style); // Empty text if out of bounds
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0, // Space between chart and title
      child: text,
    );
  }

  /// Builds the widget for left axis titles (Values)
  Widget _leftTitleWidgets(double value, TitleMeta meta, double maxValue) {
    // Don't show 0 label if it overlaps with min value display
    if (value == meta.min) return Container();
    // Don't draw labels too close to the max value if they would overlap
    if (value > maxValue * 0.95 && value != maxValue) return Container();

    const style = TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    String text;

    // Format number concisely
    if (isCurrency) {
      text = NumberFormat.compactSimpleCurrency(name: selectedCurrency).format(value);
    } else {
      // Simple compact format for BTC/Sats, adjust precision as needed
      if (value.abs() > 10000) {
        text = NumberFormat.compact().format(value);
      } else if (value.abs() >= 1) {
        text = value.toStringAsFixed(0); // No decimals for whole numbers >= 1
      } else {
        text = value.toStringAsFixed(value == 0 ? 0 : 4); // More precision for small fractions
      }
      // Optionally add BTC/Sats suffix if not showing main balance
      // text += ' ${btcFormat.name}'; // Or just leave as number if clear from context
    }


    return Text(text, style: style, textAlign: TextAlign.left);
  }

  /// Configures the tooltips on touch
  LineTouchData _buildLineTouchData(BuildContext context, List<DateTime> sortedDays) {
    return LineTouchData(
      handleBuiltInTouches: true, // Enable standard touch interactions
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        tooltipRoundedRadius: 8,
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          // Sort spots by line index if needed, or handle multiple lines
          return touchedBarSpots.map((barSpot) {
            final flSpot = barSpot;
            final index = flSpot.x.toInt();

            // Ensure index is valid
            if (index < 0 || index >= sortedDays.length) {
              return null; // Skip if index is out of bounds
            }

            final date = sortedDays[index];
            String text = '';

            // Determine which line this spot belongs to
            final lineIndex = barSpot.barIndex;
            String lineName = '';
            num value = flSpot.y; // The value from the specific line touched
            String formattedValue = '';

            if (isShowingMainData) {
              lineName = isCurrency ? '$selectedCurrency Balance' : '$btcFormat Balance';
              formattedValue = isCurrency
                  ? NumberFormat.currency(symbol: selectedCurrency == 'USD' ? '\$' : selectedCurrency, decimalDigits: 2).format(value)
                  : '${value.toStringAsFixed(btcFormat == 'BTC' ? 8 : 0)} ${btcFormat}'; // Adjust precision based on format
            } else {
              // Statistics view
              if (lineIndex == 0) { // Income
                lineName = 'Income';
              } else if (lineIndex == 1) { // Spending
                lineName = 'Spending';
              } else if (lineIndex == 2) { // Fees
                lineName = 'Fees';
              }
              // Statistics are always in BTC format from providers
              formattedValue = '${value.toStringAsFixed(btcFormat == 'BTC' ? 8 : 0)} ${btcFormat}';
            }


            text = '${date.formatYMD()}\n$lineName: $formattedValue';

            return LineTooltipItem(
              text,
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          }).toList().where((item) => item != null).cast<LineTooltipItem>().toList(); // Filter out nulls
        },
      ),
      getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
        // Customize the indicator shown on the line when touched
        return spotIndexes.map((index) {
          return TouchedSpotIndicatorData(
            const FlLine(color: Colors.orange, strokeWidth: 2), // Vertical line
            FlDotData(
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: barData.color ?? Colors.orange, // Use line color
                );
              },
            ),
          );
        }).toList();
      },
    );
  }


  /// Calculates min/max Y values and horizontal interval for the grid/labels
  ({double minY, double maxY, double horizontalInterval}) _calculateAxisBounds(
      List<Map<DateTime, num>> activeDataSets, List<DateTime> sortedDays) {
    if (activeDataSets.isEmpty || sortedDays.isEmpty) {
      return (minY: 0, maxY: 10, horizontalInterval: 2); // Default bounds
    }

    double minY = double.maxFinite;
    double maxY = double.negativeInfinity;

    for (var dataSet in activeDataSets) {
      for (var day in sortedDays) {
        final value = (dataSet[day] ?? 0).toDouble();
        if (value < minY) minY = value;
        if (value > maxY) maxY = value;
      }
    }

    // Handle cases where min/max are the same or data is flat
    if (minY == double.maxFinite || maxY == double.negativeInfinity) {
      minY = 0;
      maxY = 10; // Default range if no data found
    } else if (minY == maxY) {
      minY = minY - (minY.abs() * 0.5).clamp(5, double.infinity) ; // Adjust range if flat
      maxY = maxY + (maxY.abs() * 0.5).clamp(5, double.infinity);
    } else {
      // Add padding
      final range = maxY - minY;
      final padding = range * 0.15; // 15% padding
      maxY += padding;
      // Ensure minY doesn't go above 0 unless all values are positive
      if (minY > 0) {
        minY = 0; // Start axis at 0 if all values are positive
      } else {
        minY -= padding;
      }
    }

    // Ensure minY is never positive if maxY is positive (axis should start at or below 0)
    if (maxY > 0 && minY > 0) {
      minY = 0;
    }
    // Ensure maxY is never negative if minY is negative (axis should end at or above 0)
    if (minY < 0 && maxY < 0) {
      maxY = 0;
    }

    // Calculate a reasonable interval for horizontal lines/labels
    final range = maxY - minY;
    double interval = 1; // Default
    if (range > 0) {
      // Aim for roughly 5-7 horizontal lines/labels
      interval = (range / 6).ceilToDouble();
      // Make interval a 'nice' number if possible (e.g., multiples of 1, 2, 5, 10)
      if (interval > 10) interval = ((interval / 10).ceil() * 10).toDouble();
      else if (interval > 5) interval = ((interval / 5).ceil() * 5).toDouble();
      else if (interval > 2) interval = ((interval / 2).ceil() * 2).toDouble();
      else interval = interval.ceil().toDouble();
    }

    // Prevent interval from being zero
    if (interval <= 0) interval = 1;


    return (minY: minY, maxY: maxY, horizontalInterval: interval);
  }
}