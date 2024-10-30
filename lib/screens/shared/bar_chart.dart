import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:Satsails/models/balance_model.dart';
import '../../providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget buildBarChart(BuildContext context, Percentage percentage, WalletBalance balance, WidgetRef ref) {
  double totalValue = percentage.btcPercentage +
      percentage.lightningPercentage +
      percentage.liquidPercentage +
      percentage.brlPercentage +
      percentage.eurPercentage +
      percentage.usdPercentage;

  List<BarChartGroupData> barGroups = [];

  // BTC
  if ((percentage.btcPercentage / totalValue) * 100 >= 0.1 && balance.btcBalance > 0) {
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

  // Lightning
  if ((percentage.lightningPercentage / totalValue) * 100 >= 0.1 && balance.lightningBalance! > 0) {
    barGroups.add(
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: (percentage.lightningPercentage / totalValue) * 100,
            color: Color(0xFFF7931A),
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  // Liquid
  if ((percentage.liquidPercentage / totalValue) * 100 >= 0.1 && balance.liquidBalance > 0) {
    barGroups.add(
      BarChartGroupData(
        x: 2,
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

  // BRL
  if ((percentage.brlPercentage / totalValue) * 100 >= 0.1 && balance.brlBalance > 10000000) {
    barGroups.add(
      BarChartGroupData(
        x: 3,
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

  // EUR
  if ((percentage.eurPercentage / totalValue) * 100 >= 0.1 && balance.eurBalance > 10000000) {
    barGroups.add(
      BarChartGroupData(
        x: 4,
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

  // USD
  if ((percentage.usdPercentage / totalValue) * 100 >= 0.1 && balance.usdBalance > 10000000) {
    barGroups.add(
      BarChartGroupData(
        x: 5,
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
                    ' (' + ((percentage.btcPercentage / totalValue) * 100).toStringAsFixed(2) + '%)';
                break;
              case 1:
                assetBalance = btcInDenominationFormatted(balance.lightningBalance!, denomination) +
                    ' (' + ((percentage.lightningPercentage / totalValue) * 100).toStringAsFixed(2) + '%)';
                break;
              case 2:
                assetBalance = btcInDenominationFormatted(balance.liquidBalance, denomination) +
                    ' (' + ((percentage.liquidPercentage / totalValue) * 100).toStringAsFixed(2) + '%)';
                break;
              case 3:
                assetBalance = btcInDenominationFormatted(balance.brlBalance, denomination, false) +
                    ' (' + ((percentage.brlPercentage / totalValue) * 100).toStringAsFixed(2) + '%)';
                break;
              case 4:
                assetBalance = btcInDenominationFormatted(balance.eurBalance, denomination, false) +
                    ' (' + ((percentage.eurPercentage / totalValue) * 100).toStringAsFixed(2) + '%)';
                break;
              case 5:
                assetBalance = btcInDenominationFormatted(balance.usdBalance, denomination, false) +
                    ' (' + ((percentage.usdPercentage / totalValue) * 100).toStringAsFixed(2) + '%)';
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
