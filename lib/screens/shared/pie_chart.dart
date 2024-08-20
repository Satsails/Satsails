import 'package:Satsails/assets/lbtc_icon.dart';
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

Widget buildDiagram(BuildContext context, Percentage percentage) {
  const double minPercentageForIcon = 1.0;
  const double radius = 10.0;

  double totalValue = percentage.btcPercentage +
      percentage.liquidPercentage +
      percentage.brlPercentage +
      percentage.eurPercentage +
      percentage.usdPercentage;

  double btcPercentage = (percentage.btcPercentage / totalValue) * 100;
  double liquidPercentage = (percentage.liquidPercentage / totalValue) * 100;
  double brlPercentage = (percentage.brlPercentage / totalValue) * 100;
  double eurPercentage = (percentage.eurPercentage / totalValue) * 100;
  double usdPercentage = (percentage.usdPercentage / totalValue) * 100;

  Widget? getBadgeWidget(double value, Widget badge) {
    return value > minPercentageForIcon ? badge : null;
  }

  List<Widget> buildLegend() {
    return [
      if (btcPercentage > minPercentageForIcon)
        buildLegendItem(
          const Icon(Icons.currency_bitcoin, color: Colors.orange),
          'BTC',
          btcPercentage,
        ),
      if (liquidPercentage > minPercentageForIcon)
        buildLegendItem(
          const Icon(Lbtc_icon.lbtc_icon, color: Colors.blue),
          'Liquid',
          liquidPercentage,
        ),
      if (brlPercentage > minPercentageForIcon)
        buildLegendItem(
          Image.asset('lib/assets/depix.png', width: 25, height: 25),
          'BRL',
          brlPercentage,
        ),
      if (eurPercentage > minPercentageForIcon)
        buildLegendItem(
          Image.asset('lib/assets/eurx.png', width: 25, height: 25),
          'EUR',
          eurPercentage,
        ),
      if (usdPercentage > minPercentageForIcon)
        buildLegendItem(
          Image.asset('lib/assets/tether.png', width: 25, height: 25),
          'USD',
          usdPercentage,
        ),
    ];
  }

  return totalValue == 0
      ? PieChart(PieChartData(
    sections: [
      PieChartSectionData(
        value: 1,
        title: '',
        radius: radius,
        color: Colors.grey,
      ),
    ],
    borderData: FlBorderData(show: false),
  ))
      : Row(
    children: [
      Expanded(
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: btcPercentage,
                title: '',
                radius: radius,
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
                radius: radius,
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
                radius: radius,
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
                radius: radius,
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
                radius: radius,
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
          ),
        ),
      ),
      const SizedBox(width: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: buildLegend(),
      ),
    ],
  );
}
