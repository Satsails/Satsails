// screens/analytics/components/flows_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  DateTime dateOnly() => DateTime(year, month, day);
}

class FlowsChart extends StatelessWidget {
  final Map<DateTime, num> inflows;
  final Map<DateTime, num> outflows;
  final List<DateTime> selectedDays;

  const FlowsChart({
    super.key,
    required this.inflows,
    required this.outflows,
    required this.selectedDays,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedDays.isEmpty) {
      return Center(child: Text('No data for this period'.i18n, style: TextStyle(color: Colors.white70)));
    }

    final sortedDays = List<DateTime>.from(selectedDays)..sort((a, b) => a.compareTo(b));

    return Padding(
      padding: EdgeInsets.only(right: 18.w, left: 8.w, top: 12.h, bottom: 12.h),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: _buildBarTouchData(),
          titlesData: _buildTitlesData(sortedDays),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade800,
              strokeWidth: 0.8,
              dashArray: [4, 4],
            ),
          ),
          barGroups: sortedDays.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final inflow = inflows[day.dateOnly()] ?? 0;
            final outflow = outflows[day.dateOnly()] ?? 0;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(toY: inflow.toDouble(), color: Colors.greenAccent.withOpacity(0.8), width: 8.w, borderRadius: BorderRadius.circular(4)),
                BarChartRodData(toY: outflow.toDouble(), color: Colors.redAccent.withOpacity(0.8), width: 8.w, borderRadius: BorderRadius.circular(4)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => Colors.black.withOpacity(0.8),
        tooltipPadding: const EdgeInsets.all(10),
        tooltipMargin: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          String title = rodIndex == 0 ? 'In'.i18n : 'Out'.i18n;
          Color color = rodIndex == 0 ? Colors.greenAccent : Colors.redAccent;

          return BarTooltipItem(
            '$title: ${NumberFormat.compact().format(rod.toY)}',
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14.sp),
          );
        },
      ),
    );
  }

  FlTitlesData _buildTitlesData(List<DateTime> sortedDays) {
    return FlTitlesData(
      show: true,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 45.w,
          getTitlesWidget: (value, meta) {
            if (value == 0 && meta.max > 0) return const SizedBox.shrink();
            return Text(
              NumberFormat.compact().format(value),
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp, fontWeight: FontWeight.w500),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30.h,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= sortedDays.length) return const SizedBox.shrink();
            if (sortedDays.length > 14 && index % (sortedDays.length / 7).round() != 0) return const SizedBox.shrink();

            return SideTitleWidget(
              meta: meta,
              child: Text(
                DateFormat('dd/MM').format(sortedDays[index]),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp, fontWeight: FontWeight.w500),
              ),
            );
          },
        ),
      ),
    );
  }
}