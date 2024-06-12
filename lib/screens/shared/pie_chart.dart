import 'package:Satsails/assets/lbtc_icon.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Satsails/models/balance_model.dart';

Widget buildDiagram(BuildContext context, Percentage percentage) {
  return percentage.total == 0
      ? PieChart(PieChartData(
    sections: [
      PieChartSectionData(value: 1, title: '', radius: 20, color: Colors.grey)
    ],
    borderData: FlBorderData(show: false),
  ))
      : PieChart(PieChartData(
    sections: [
      PieChartSectionData(
        value: percentage.btcPercentage,
        title: '',
        radius: 20,
        badgeWidget: const Icon(Icons.currency_bitcoin, color: Colors.white),
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      PieChartSectionData(
        value: percentage.liquidPercentage,
        title: '',
        radius: 20,
        badgeWidget: const Icon(Lbtc_icon.lbtc_icon, color: Colors.white),
        color: Colors.blueAccent,
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      PieChartSectionData(
        value: percentage.brlPercentage,
        title: '',
        radius: 20,
        badgeWidget: Flag(Flags.brazil, size: 25),
        color: Color(0xFF009B3A), // Brazilian flag green
      ),
      PieChartSectionData(
        value: percentage.eurPercentage,
        title: '',
        radius: 20,
        badgeWidget: Flag(Flags.european_union, size: 25),
        color: Color(0xFF003399), // European Union blue
      ),
      PieChartSectionData(
        value: percentage.usdPercentage,
        title: '',
        radius: 20,
        badgeWidget: Flag(Flags.united_states_of_america, size: 25),
        color: Color(0xFF008000), // US dollar green
      ),
    ],
    borderData: FlBorderData(show: false),
  ));
}
