import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/analytics/components/calendar.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class LineChartSample extends StatelessWidget {
  final List<DateTime> selectedDays;
  final Map<DateTime, num> feeData;
  final Map<DateTime, num> incomeData;
  final Map<DateTime, num> spendingData;
  final Map<DateTime, num>? mainData;
  final Map<DateTime, num> balanceInCurrency;
  final String selectedCurrency;
  final bool isShowingMainData;

  const LineChartSample({
    super.key,
    required this.selectedDays,
    required this.feeData,
    required this.incomeData,
    required this.spendingData,
    this.mainData,
    required this.balanceInCurrency,
    required this.selectedCurrency,
    required this.isShowingMainData,
  });

  @override
  Widget build(BuildContext context) {
    List<FlSpot> mainDataSpots = [];
    List<FlSpot> spendingDataSpots = [];
    List<FlSpot> incomeDataSpots = [];
    List<FlSpot> feeDataSpots = [];

    if (mainData != null && isShowingMainData) {
      mainDataSpots = mainData!.entries.map((entry) {
        return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value.toDouble());
      }).toList();
    } else {
      spendingDataSpots = spendingData.entries.map((entry) {
        return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value.toDouble());
      }).toList();

      incomeDataSpots = incomeData.entries.map((entry) {
        return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value.toDouble());
      }).toList();

      feeDataSpots = feeData.entries.map((entry) {
        return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value.toDouble());
      }).toList();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          clipData: FlClipData.all(), // Ensures lines do not exit the chart area
          backgroundColor: Colors.transparent,
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.black87,
              tooltipRoundedRadius: 12,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tooltipMargin: 10,
              fitInsideHorizontally: true,
              fitInsideVertically: true, // Ensures tooltip stays within vertical bounds
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot spot) {
                  final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                  final formattedDate = DateFormat('dd MMM, yyyy').format(date);
                  final bitcoinValue = spot.y.toStringAsFixed(spot.y == spot.y.roundToDouble() ? 0 : 8);
                  final currencyValue = balanceInCurrency[date]?.toStringAsFixed(
                      balanceInCurrency[date] == balanceInCurrency[date]?.roundToDouble() ? 0 : 2) ?? '0.00';

                  // Display format for main data and other data
                  final displayString = '$formattedDate\n $bitcoinValue\n$selectedCurrency: $currencyValue';
                  final displayStringIfNotMainData = '$bitcoinValue';

                  return LineTooltipItem(
                    isShowingMainData ? displayString : displayStringIfNotMainData,
                    const TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ),
            gridData: FlGridData(
            show: false,
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false, // Hiding titles for cleaner look
                getTitlesWidget: bottomTitleWidgets,
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false, // Hiding titles for cleaner look
                getTitlesWidget: leftTitleWidgets,
                reservedSize: 70,
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            if (mainDataSpots.isNotEmpty)
              LineChartBarData(
                spots: mainDataSpots,
                isCurved: false,
                color: Colors.orangeAccent,
                barWidth: 3,
                gradient: const LinearGradient(
                  colors: [Colors.orangeAccent, Colors.deepOrange],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.orangeAccent.withOpacity(0.3),
                      Colors.deepOrange.withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            if (spendingDataSpots.isNotEmpty)
              LineChartBarData(
                spots: spendingDataSpots,
                isCurved: false,
                color: Colors.blueAccent,
                barWidth: 3,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueAccent.withOpacity(0.3),
                      Colors.blueAccent.withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            if (incomeDataSpots.isNotEmpty)
              LineChartBarData(
                spots: incomeDataSpots,
                isCurved: false,
                color: Colors.greenAccent,
                barWidth: 3,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.greenAccent.withOpacity(0.3),
                      Colors.greenAccent.withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            if (feeDataSpots.isNotEmpty)
              LineChartBarData(
                spots: feeDataSpots,
                isCurved: false,
                color: Colors.orangeAccent,
                barWidth: 3,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.orangeAccent.withOpacity(0.3),
                      Colors.orangeAccent.withOpacity(0.1),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    String formattedDate = DateFormat('dd/MM').format(date);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        formattedDate,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    int decimalPlaces = decimalPlacesBtcFormat(value);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        value.toStringAsFixed(decimalPlaces),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  int decimalPlacesBtcFormat(num value) {
    if (value == value.roundToDouble()) return 0;
    final String valueString = value.toString();
    final int decimalPlaces = valueString.split('.').last.length;
    return decimalPlaces;
  }
}

class ExpensesGraph extends ConsumerStatefulWidget {
  const ExpensesGraph({super.key});

  @override
  _ExpensesGraphState createState() => _ExpensesGraphState();
}

class _ExpensesGraphState extends ConsumerState<ExpensesGraph> {
  bool isShowingMainData = true;

  @override
  Widget build(BuildContext context) {
    final selectedDays = ref.watch(selectedDaysDateArrayProvider);
    final feeData = ref.watch(bitcoinFeeSpentPerDayProvider);
    final incomeData = ref.watch(bitcoinIncomePerDayProvider);
    final spendingData = ref.watch(bitcoinSpentPerDayProvider);
    final bitcoinBalanceByDay = ref.watch(bitcoinBalanceInFormatByDayProvider);
    final bitcoinBalanceByDayUnformatted = ref.watch(bitcoinBalanceInBtcByDayProvider);
    final selectedCurrency = ref.watch(settingsProvider).currency;
    final currencyRate = ref.watch(selectedCurrencyProvider(selectedCurrency));

    return Column(
      children: <Widget>[
        Center(
          child: TextButton(
            child: Text(
              !isShowingMainData ? 'Show Balance'.i18n : 'Show Statistics over period'.i18n,
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () {
              setState(() {
                isShowingMainData = !isShowingMainData;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: isShowingMainData
              ? [
            _buildLegend('Balance'.i18n, Colors.orangeAccent),
          ]
              : [
            _buildLegend('Spending'.i18n, Colors.blueAccent),
            _buildLegend('Income'.i18n, Colors.greenAccent),
            _buildLegend('Fee'.i18n, Colors.orangeAccent),
          ],
        ),
        const Calendar(),
        Expanded(
          child: LineChartSample(
            selectedDays: selectedDays,
            feeData: feeData,
            incomeData: incomeData,
            spendingData: spendingData,
            mainData: isShowingMainData ? bitcoinBalanceByDay : null,
            balanceInCurrency: calculateBalanceInCurrency(bitcoinBalanceByDayUnformatted, currencyRate),
            selectedCurrency: selectedCurrency,
            isShowingMainData: isShowingMainData,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Map<DateTime, num> calculateBalanceInCurrency(Map<DateTime, num> balanceByDay, num currencyRate) {
    final Map<DateTime, num> balanceInCurrency = {};
    balanceByDay.forEach((day, balance) {
      balanceInCurrency[day] = (balance * currencyRate).toDouble();
    });
    return balanceInCurrency;
  }
}