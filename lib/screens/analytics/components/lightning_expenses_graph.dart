import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/analytics/components/calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LightningLineChartSample extends StatelessWidget {
  final List<DateTime> selectedDays;
  final Map<DateTime, num>? mainData;
  final Map<DateTime, num> balanceInCurrency;
  final String selectedCurrency;

  const LightningLineChartSample({
    super.key,
    required this.selectedDays,
    this.mainData,
    required this.balanceInCurrency,
    required this.selectedCurrency,
  });

  @override
  Widget build(BuildContext context) {
    List<FlSpot> mainDataSpots = [];

    if (mainData != null) {
      mainDataSpots = mainData!.entries.map((entry) {
        // Ensure the balance is converted to the correct unit (e.g., BTC)
        final balance = entry.value / 100000000; // Assuming the balance is in satoshis
        return FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), balance.toDouble());
      }).toList();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          clipData: const FlClipData.all(),
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
              fitInsideVertically: true,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot spot) {
                  final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                  final formattedDate = DateFormat('dd MMM, yyyy').format(date);
                  final lightningValue = spot.y.toStringAsFixed(8); // Show up to 8 decimal places
                  final currencyValue = balanceInCurrency[date]?.toStringAsFixed(2) ?? '0.00';

                  final displayString = '$formattedDate\n $lightningValue\n$selectedCurrency: $currencyValue';

                  return LineTooltipItem(
                    displayString,
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
          gridData: const FlGridData(
            show: false,
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                getTitlesWidget: bottomTitleWidgets,
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                getTitlesWidget: leftTitleWidgets,
                reservedSize: 70,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
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
                dotData: const FlDotData(show: false),
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

class LightningExpensesGraph extends ConsumerStatefulWidget {
  const LightningExpensesGraph({super.key});

  @override
  _LightningExpensesGraphState createState() => _LightningExpensesGraphState();
}

class _LightningExpensesGraphState extends ConsumerState<LightningExpensesGraph> {
  @override
  Widget build(BuildContext context) {
    final selectedDays = ref.watch(selectedDaysDateArrayProvider);

    final coinosBalance = ref.watch(balanceNotifierProvider).lightningBalance;

    final lightningBalanceByDayUnformattedAsync = ref.watch(lightningBalanceOverPeriodByDayProvider);
    final selectedCurrency = ref.watch(settingsProvider).currency;
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final currencyRate = ref.watch(selectedCurrencyProvider(selectedCurrency));

    final formattedCoinosBalance = btcInDenominationFormatted(coinosBalance!, btcFormat);

    return lightningBalanceByDayUnformattedAsync.when(
      data: (lightningBalanceByDayUnformatted) {
        final balanceInCurrency = calculateBalanceInCurrency(
          lightningBalanceByDayUnformatted,
          currencyRate,
        );

        return Column(
          children: <Widget>[
            Text(
              '$formattedCoinosBalance $btcFormat',
              style: TextStyle(
                fontSize: screenWidth / 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Calendar(),
            Expanded(
              child: LightningLineChartSample(
                selectedDays: selectedDays,
                mainData: lightningBalanceByDayUnformatted,
                balanceInCurrency: balanceInCurrency,
                selectedCurrency: selectedCurrency,
              ),
            ),
          ],
        );
      },
      loading: () => LoadingAnimationWidget.fourRotatingDots(
        color: Colors.orangeAccent,
        size: screenHeight * 0.08,
      ),
      error: (error, stack) => LoadingAnimationWidget.fourRotatingDots(
        color: Colors.orangeAccent,
        size: screenHeight * 0.08,
      ),
    );
  }

  Map<DateTime, num> calculateBalanceInCurrency(
      Map<DateTime, num> balanceByDay, num currencyRate) {
    final Map<DateTime, num> balanceInCurrency = {};
    balanceByDay.forEach((day, balance) {
      final balanceInBtc = balance / 100000000; // Convert satoshis to BTC
      balanceInCurrency[day] = balanceInBtc * currencyRate;
    });
    return balanceInCurrency;
  }
}
