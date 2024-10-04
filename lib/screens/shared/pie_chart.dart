import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:Satsails/models/balance_model.dart';

Widget buildLegendItem(Widget icon, String label, double percentage) {
  return Row(
    children: [
      icon,
      const SizedBox(width: 8),
      Text('$label: ${percentage.toStringAsFixed(2)}%', style: const TextStyle(color: Colors.white)),
    ],
  );
}

Widget buildBarChart(BuildContext context, Percentage percentage) {
  double totalValue = percentage.btcPercentage +
      percentage.liquidPercentage +
      percentage.brlPercentage +
      percentage.eurPercentage +
      percentage.usdPercentage;

  List<BarChartGroupData> barGroups = [];

  if ((percentage.btcPercentage / totalValue) * 100 >= 0.1) {
    barGroups.add(
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: (percentage.btcPercentage / totalValue) * 100,
            color: Colors.orange,
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
  if ((percentage.liquidPercentage / totalValue) * 100 >= 0.1) {
    barGroups.add(
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: (percentage.liquidPercentage / totalValue) * 100,
            color: Colors.blue,
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
  if ((percentage.brlPercentage / totalValue) * 100 >= 0.1) {
    barGroups.add(
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: (percentage.brlPercentage / totalValue) * 100,
            color: const Color(0xFF009B3A),
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
  if ((percentage.eurPercentage / totalValue) * 100 >= 0.1) {
    barGroups.add(
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: (percentage.eurPercentage / totalValue) * 100,
            color: const Color(0xFF003399),
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
  if ((percentage.usdPercentage / totalValue) * 100 >= 0.1) {
    barGroups.add(
      BarChartGroupData(
        x: 4,
        barRods: [
          BarChartRodData(
            toY: (percentage.usdPercentage / totalValue) * 100,
            color: const Color(0xFF008000),
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  return BarChart(
    BarChartData(
      barGroups: barGroups,
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              switch (value.toInt()) {
                case 0:
                  return Text('BTC', style: TextStyle(color: Colors.white));
                case 1:
                  return Text('Liquid', style: TextStyle(color: Colors.white));
                case 2:
                  return Text('Depix', style: TextStyle(color: Colors.white));
                case 3:
                  return Text('EURx', style: TextStyle(color: Colors.white));
                case 4:
                  return Text('USDT', style: TextStyle(color: Colors.white));
                default:
                  return Text('', style: TextStyle(color: Colors.white));
              }
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      gridData: FlGridData(show: false),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipHorizontalAlignment: FLHorizontalAlignment.center,
            fitInsideVertically: true,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              '${rod.toY.toStringAsFixed(2)}%',
              TextStyle(color: Colors.white),
            );
          },
        ),
      ),
    ),
  );
}