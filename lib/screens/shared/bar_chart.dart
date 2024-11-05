import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:Satsails/models/balance_model.dart';
import '../../providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

double adjustedPercentage(double percentage, double totalValue) {
  if (percentage.isInfinite || totalValue == 0) {
    return 100.0;
  } else {
    return (percentage / totalValue) * 100;
  }
}

Widget buildBarChart(BuildContext context, Percentage percentage, WalletBalance balance, WidgetRef ref) {
  double totalValue = percentage.btcPercentage +
      percentage.lightningPercentage +
      percentage.liquidPercentage +
      percentage.brlPercentage +
      percentage.eurPercentage +
      percentage.usdPercentage;

  // Adjust totalValue if it's zero to avoid division by zero
  if (totalValue == 0) {
    totalValue = 1.0;
  }

  List<BarChartGroupData> barGroups = [];

  // BTC
  double btcAdjustedPercentage = adjustedPercentage(percentage.btcPercentage, totalValue);
  if (btcAdjustedPercentage >= 0.1 && balance.btcBalance > 0) {
    barGroups.add(
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: btcAdjustedPercentage,
            color: Colors.orange,
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  // Lightning
  double lightningAdjustedPercentage = adjustedPercentage(percentage.lightningPercentage, totalValue);
  if (lightningAdjustedPercentage >= 0.1 && balance.lightningBalance! > 0) {
    barGroups.add(
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: lightningAdjustedPercentage,
            color: Color(0xFFF7931A),
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  // Liquid
  double liquidAdjustedPercentage = adjustedPercentage(percentage.liquidPercentage, totalValue);
  if (liquidAdjustedPercentage >= 0.1 && balance.liquidBalance > 0) {
    barGroups.add(
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: liquidAdjustedPercentage,
            color: Colors.blue,
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  // BRL
  double brlAdjustedPercentage = adjustedPercentage(percentage.brlPercentage, totalValue);
  if (brlAdjustedPercentage >= 0.1 && balance.brlBalance > 10000000) {
    barGroups.add(
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(
            toY: brlAdjustedPercentage,
            color: const Color(0xFF009B3A),
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  // EUR
  double eurAdjustedPercentage = adjustedPercentage(percentage.eurPercentage, totalValue);
  if (eurAdjustedPercentage >= 0.1 && balance.eurBalance > 10000000) {
    barGroups.add(
      BarChartGroupData(
        x: 4,
        barRods: [
          BarChartRodData(
            toY: eurAdjustedPercentage,
            color: const Color(0xFF003399),
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  // USD
  double usdAdjustedPercentage = adjustedPercentage(percentage.usdPercentage, totalValue);
  if (usdAdjustedPercentage >= 0.1 && balance.usdBalance > 10000000) {
    barGroups.add(
      BarChartGroupData(
        x: 5,
        barRods: [
          BarChartRodData(
            toY: usdAdjustedPercentage,
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
                  return Text('Lightning', style: TextStyle(color: Colors.white));
                case 2:
                  return Text('Liquid', style: TextStyle(color: Colors.white));
                case 3:
                  return Text('Depix', style: TextStyle(color: Colors.white));
                case 4:
                  return Text('EURx', style: TextStyle(color: Colors.white));
                case 5:
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
            String assetBalance = '';
            String denomination = ref.watch(settingsProvider).btcFormat;

            // Map the group index to the corresponding asset and balance, calculating percentage
            switch (group.x) {
              case 0:
                assetBalance = btcInDenominationFormatted(balance.btcBalance, denomination) +
                    ' (' + btcAdjustedPercentage.toStringAsFixed(2) + '%)';
                break;
              case 1:
                assetBalance = btcInDenominationFormatted(balance.lightningBalance!, denomination) +
                    ' (' + lightningAdjustedPercentage.toStringAsFixed(2) + '%)';
                break;
              case 2:
                assetBalance = btcInDenominationFormatted(balance.liquidBalance, denomination) +
                    ' (' + liquidAdjustedPercentage.toStringAsFixed(2) + '%)';
                break;
              case 3:
                assetBalance = btcInDenominationFormatted(balance.brlBalance, denomination, false) +
                    ' (' + brlAdjustedPercentage.toStringAsFixed(2) + '%)';
                break;
              case 4:
                assetBalance = btcInDenominationFormatted(balance.eurBalance, denomination, false) +
                    ' (' + eurAdjustedPercentage.toStringAsFixed(2) + '%)';
                break;
              case 5:
                assetBalance = btcInDenominationFormatted(balance.usdBalance, denomination, false) +
                    ' (' + usdAdjustedPercentage.toStringAsFixed(2) + '%)';
                break;
              default:
                assetBalance = '';
                break;
            }

            // Tooltip to display the balance and percentage in parentheses
            return BarTooltipItem(
              assetBalance,
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
    ),
  );
}
