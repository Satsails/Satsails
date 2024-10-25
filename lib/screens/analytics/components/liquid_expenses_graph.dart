import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/screens/analytics/components/calendar.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:intl/intl.dart';

class LiquidExpensesGraph extends StatelessWidget {
  final List<DateTime> selectedDays;
  final Map<DateTime, num> sentData;
  final Map<DateTime, num> receivedData;
  final Map<DateTime, num> feeData;
  final Map<DateTime, num>? mainData;
  final Map<DateTime, num> balanceInCurrency;
  final String selectedCurrency;
  final bool isShowingMainData;
  final bool isBtc;

  const LiquidExpensesGraph({
    super.key,
    required this.selectedDays,
    required this.sentData,
    required this.receivedData,
    required this.feeData,
    this.mainData,
    required this.balanceInCurrency,
    required this.selectedCurrency,
    required this.isShowingMainData,
    required this.isBtc,
  });

  @override
  Widget build(BuildContext context) {
    // Map data to FlSpot
    List<FlSpot> mainDataSpots = [];
    List<FlSpot> sentDataSpots = [];
    List<FlSpot> receivedDataSpots = [];
    List<FlSpot> feeDataSpots = [];

    if (mainData != null && isShowingMainData) {
      mainDataSpots = mainData!.entries.map((entry) {
        return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value.toDouble());
      }).toList();
    } else {
      sentDataSpots = sentData.entries.map((entry) {
        return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value.toDouble());
      }).toList();

      receivedDataSpots = receivedData.entries.map((entry) {
        return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value.toDouble());
      }).toList();

      if (isBtc) {
        feeDataSpots = feeData.entries.map((entry) {
          return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value.toDouble());
        }).toList();
      }
    }

    // Calculate maxY and minY for proper scaling and padding
    double maxY = 0;
    double minY = 0;

    List<FlSpot> allSpots = [
      ...mainDataSpots,
      ...sentDataSpots,
      ...receivedDataSpots,
      ...feeDataSpots,
    ];

    if (allSpots.isNotEmpty) {
      maxY = allSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
      minY = allSpots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);

      // Add padding to maxY and minY
      final double yRange = maxY - minY;
      maxY += yRange * 0.1; // 10% padding at the top
      minY -= yRange * 0.1; // Optional: 10% padding at the bottom
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
          minX: selectedDays.isNotEmpty
              ? selectedDays.first.millisecondsSinceEpoch.toDouble()
              : null,
          maxX: selectedDays.isNotEmpty
              ? selectedDays.last.millisecondsSinceEpoch.toDouble()
              : null,
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.orangeAccent,
              tooltipRoundedRadius: 8,
              fitInsideHorizontally: true,
              fitInsideVertically: true, // Ensures tooltip stays within vertical bounds
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot spot) {
                  final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                  final formattedDate = DateFormat('dd/MM/yyyy').format(date);
                  final value = spot.y;
                  final int decimalPlaces = isBtc ? _decimalPlacesBtcFormat(value) : 2;
                  final valueString = value.toStringAsFixed(decimalPlaces);
                  final currencyValue = balanceInCurrency[date]?.toStringAsFixed(
                      balanceInCurrency[date] == balanceInCurrency[date]?.roundToDouble()
                          ? 0
                          : 2) ??
                      '0.00';

                  String displayString;
                  if (isBtc && isShowingMainData) {
                    displayString = '$formattedDate\n$valueString\n$selectedCurrency: $currencyValue';
                  } else if (isBtc && isShowingMainData) {
                    displayString = '$formattedDate\n$valueString';
                  } else {
                    displayString = '$valueString';
                  }

                  return LineTooltipItem(
                    displayString,
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          lineBarsData: _lineBarsData(
            mainDataSpots,
            sentDataSpots,
            receivedDataSpots,
            feeDataSpots,
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> _lineBarsData(
      List<FlSpot> mainDataSpots,
      List<FlSpot> sentDataSpots,
      List<FlSpot> receivedDataSpots,
      List<FlSpot> feeDataSpots,
      ) {
    final List<LineChartBarData> lineBars = [];

    if (mainDataSpots.isNotEmpty && isShowingMainData) {
      lineBars.add(LineChartBarData(
        spots: mainDataSpots,
        isCurved: false, // Lines are direct, not rounded
        color: Colors.orangeAccent,
        gradient: const LinearGradient(
          colors: [Colors.orangeAccent, Colors.deepOrange],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        barWidth: 3,
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
      ));
    } else {
      if (sentDataSpots.isNotEmpty) {
        lineBars.add(LineChartBarData(
          spots: sentDataSpots,
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
        ));
      }
      if (receivedDataSpots.isNotEmpty) {
        lineBars.add(LineChartBarData(
          spots: receivedDataSpots,
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
        ));
      }
      if (feeDataSpots.isNotEmpty && isBtc) {
        lineBars.add(LineChartBarData(
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
        ));
      }
    }

    return lineBars;
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
    int decimalPlaces = isBtc ? _decimalPlacesBtcFormat(value) : 2;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        value.toStringAsFixed(decimalPlaces),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  int _decimalPlacesBtcFormat(num value) {
    if (value == value.roundToDouble()) return 0;
    final String valueString = value.toString();
    final int decimalPlaces = valueString.split('.').last.length;
    return decimalPlaces;
  }
}


class ExpensesGraph extends ConsumerStatefulWidget {
  final String assetId;

  const ExpensesGraph({super.key, required this.assetId});

  @override
  _ExpensesGraphState createState() => _ExpensesGraphState();
}

class _ExpensesGraphState extends ConsumerState<ExpensesGraph> {
  bool isShowingBalanceData = true;

  @override
  Widget build(BuildContext context) {
    final selectedDays = ref.watch(selectedDaysDateArrayProvider);
    final feeData = ref.watch(liquidFeePerDayProvider(widget.assetId));
    final incomeData = ref.watch(liquidIncomePerDayProvider(widget.assetId));
    final spendingData = ref.watch(liquidSpentPerDayProvider(widget.assetId));
    final formattedBalanceData = ref.watch(liquidBalancePerDayInFormatProvider(widget.assetId));
    final formattedBalanceDataInBtc = ref.watch(liquidBalancePerDayInBTCFormatProvider(widget.assetId));
    final selectedCurrency = ref.watch(settingsProvider).currency;
    final currencyRate = ref.watch(selectedCurrencyProvider(selectedCurrency));
    final balanceInCurrency = calculateBalanceInCurrency(formattedBalanceDataInBtc, currencyRate);
    final isBtc = AssetMapper.reverseMapTicker(AssetId.LBTC) == widget.assetId;

    return Column(
      children: <Widget>[
        Center(
          child: TextButton(
            child: Text(
              !isShowingBalanceData ? 'Show Balance'.i18n(ref) : 'Show Statistics over period'.i18n(ref),
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () {
              setState(() {
                isShowingBalanceData = !isShowingBalanceData;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: isShowingBalanceData
              ? [
            _buildLegend('Balance'.i18n(ref), Colors.orangeAccent),
          ]
              : [
            _buildLegend('Sent'.i18n(ref), Colors.blueAccent),
            _buildLegend('Received'.i18n(ref), Colors.greenAccent),
            if (isBtc) _buildLegend('Fee'.i18n(ref), Colors.orangeAccent),
          ],
        ),
        const Calendar(),
        Expanded(
          child: LiquidExpensesGraph(
            selectedDays: selectedDays,
            sentData: spendingData,
            receivedData: incomeData,
            feeData: feeData,
            mainData: isShowingBalanceData ? formattedBalanceData : null,
            balanceInCurrency: balanceInCurrency,
            selectedCurrency: selectedCurrency,
            isShowingMainData: isShowingBalanceData,
            isBtc: isBtc,
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

  Map<DateTime, num> calculateBalanceInCurrency(Map<DateTime, num>? balanceByDay, num currencyRate) {
    final Map<DateTime, num> balanceInCurrency = {};
    balanceByDay?.forEach((day, balance) {
      balanceInCurrency[day] = (balance * currencyRate).toDouble();
    });
    return balanceInCurrency;
  }
}

int decimalPlacesBtcFormat(num value) {
  if (value == value.roundToDouble()) return 0;
  final String valueString = value.toString();
  final int decimalPlaces = valueString.split('.').last.length;
  return decimalPlaces;
}
