import 'package:Satsails/assets/lbtc_icon.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:Satsails/models/balance_model.dart';

Widget buildDiagram(BuildContext context, Percentage percentage) {
  const double minPercentageForIcon = 1.0; // Set the minimum percentage threshold

  // Calculate total value
  double totalValue = percentage.btcPercentage +
      percentage.liquidPercentage +
      percentage.brlPercentage +
      percentage.eurPercentage +
      percentage.usdPercentage;

  // Calculate percentages
  double btcPercentage = (percentage.btcPercentage / totalValue) * 100;
  double liquidPercentage = (percentage.liquidPercentage / totalValue) * 100;
  double brlPercentage = (percentage.brlPercentage / totalValue) * 100;
  double eurPercentage = (percentage.eurPercentage / totalValue) * 100;
  double usdPercentage = (percentage.usdPercentage / totalValue) * 100;

  Widget? getBadgeWidget(double value, Widget badge) {
    return value > minPercentageForIcon ? badge : null;
  }

  return totalValue == 0
      ? PieChart(PieChartData(
    sections: [
      PieChartSectionData(
        value: 1,
        title: '',
        radius: 20,
        color: Colors.grey,
      ),
    ],
    borderData: FlBorderData(show: false),
  ))
      : PieChart(PieChartData(
    sections: [
      PieChartSectionData(
        value: btcPercentage,
        title: '',
        radius: 20,
        badgeWidget: getBadgeWidget(
          btcPercentage,
          const Icon(Icons.currency_bitcoin, color: Colors.white),
        ),
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      PieChartSectionData(
        value: liquidPercentage,
        title: '',
        radius: 20,
        badgeWidget: getBadgeWidget(
          liquidPercentage,
          const Icon(Lbtc_icon.lbtc_icon, color: Colors.white),
        ),
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      PieChartSectionData(
        value: brlPercentage,
        title: '',
        radius: 20,
        badgeWidget: getBadgeWidget(
          brlPercentage,
          Image.asset(
            'lib/assets/depix.png',
            width: 25,
            height: 25,
          ),
        ),
        color: Color(0xFF009B3A), // Brazilian flag green
      ),
      PieChartSectionData(
        value: eurPercentage,
        title: '',
        radius: 20,
        badgeWidget: getBadgeWidget(
          eurPercentage,
          Image.asset(
            'lib/assets/eurx.png',
            width: 25,
            height: 25,
          ),
        ),
        color: Color(0xFF003399), // European Union blue
      ),
      PieChartSectionData(
        value: usdPercentage,
        title: '',
        radius: 20,
        badgeWidget: getBadgeWidget(
          usdPercentage,
          Image.asset(
            'lib/assets/tether.png',
            width: 25,
            height: 25,
          ),
        ),
        color: Color(0xFF008000), // US dollar green
      ),
    ],
    borderData: FlBorderData(show: false),
  ));
}
