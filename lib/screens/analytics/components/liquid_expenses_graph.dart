import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChartSample extends StatelessWidget {
  final List<DateTime> selectedDays;
  final Map<DateTime, num> feeData;
  final Map<DateTime, num> incomeData;
  final Map<DateTime, num> spendingData;
  final Map<DateTime, num>? balanceData;
  final Map<DateTime, num> balanceInCurrency;
  final String selectedCurrency;
  final bool showFeeLine;

  const LineChartSample({
    super.key,
    required this.selectedDays,
    required this.feeData,
    required this.incomeData,
    required this.spendingData,
    this.balanceData,
    required this.balanceInCurrency,
    required this.selectedCurrency,
    required this.showFeeLine,
  });

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.days,
        dateFormat: DateFormat('dd/MM'),
        interval: selectedDays.length > 20 ? 5 : 1,
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.compact(),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: _chartSeries(),
    );
  }

  List<LineSeries<MapEntry<DateTime, num>, DateTime>> _chartSeries() {
    final seriesList = <LineSeries<MapEntry<DateTime, num>, DateTime>>[];

    if (balanceData != null) {
      seriesList.add(LineSeries<MapEntry<DateTime, num>, DateTime>(
        name: 'Balance',
        dataSource: balanceData!.entries.toList(),
        xValueMapper: (MapEntry<DateTime, num> entry, _) => entry.key,
        yValueMapper: (MapEntry<DateTime, num> entry, _) => entry.value.toDouble(),
        color: Colors.orangeAccent,
        markerSettings: MarkerSettings(isVisible: true),
      ));
    } else {
      seriesList.add(LineSeries<MapEntry<DateTime, num>, DateTime>(
        name: 'Spending',
        dataSource: spendingData.entries.toList(),
        xValueMapper: (MapEntry<DateTime, num> entry, _) => entry.key,
        yValueMapper: (MapEntry<DateTime, num> entry, _) => entry.value.toDouble(),
        color: Colors.blueAccent,
        markerSettings: MarkerSettings(isVisible: true),
      ));
      seriesList.add(LineSeries<MapEntry<DateTime, num>, DateTime>(
        name: 'Income',
        dataSource: incomeData.entries.toList(),
        xValueMapper: (MapEntry<DateTime, num> entry, _) => entry.key,
        yValueMapper: (MapEntry<DateTime, num> entry, _) => entry.value.toDouble(),
        color: Colors.greenAccent,
        markerSettings: MarkerSettings(isVisible: true),
      ));
      if (showFeeLine) {
        seriesList.add(LineSeries<MapEntry<DateTime, num>, DateTime>(
          name: 'Fee',
          dataSource: feeData.entries.toList(),
          xValueMapper: (MapEntry<DateTime, num> entry, _) => entry.key,
          yValueMapper: (MapEntry<DateTime, num> entry, _) => entry.value.toDouble(),
          color: Colors.orangeAccent,
          markerSettings: MarkerSettings(isVisible: true),
        ));
      }
    }

    return seriesList;
  }
}

class ExpensesGraph extends ConsumerStatefulWidget {
  final String assetId;

  const ExpensesGraph({super.key, required this.assetId});

  @override
  _ExpensesGraphState createState() => _ExpensesGraphState();
}

class _ExpensesGraphState extends ConsumerState<ExpensesGraph> {
  bool isShowingBalanceData = false;

  @override
  Widget build(BuildContext context) {
    final selectedDays = ref.watch(selectedDaysDateArrayProvider);
    final feeData = ref.watch(liquidFeePerDayProvider(widget.assetId));
    final incomeData = ref.watch(liquidIncomePerDayProvider(widget.assetId));
    final spendingData = ref.watch(liquidSpentPerDayProvider(widget.assetId));
    final balanceData = ref.watch(liquidBalanceOverPeriodByDayProvider(widget.assetId));

    final selectedCurrency = ref.watch(settingsProvider).currency;
    final currencyRate = ref.watch(selectedCurrencyProvider(selectedCurrency));
    final balanceInCurrency = calculateBalanceInCurrency(balanceData, currencyRate);

    final screenHeight = MediaQuery.of(context).size.height;

    final bool showFeeLine = widget.assetId == AssetMapper.reverseMapTicker(AssetId.LBTC);

    return Column(
      children: <Widget>[
        Container(
          height: screenHeight * 0.18,
          padding: const EdgeInsets.only(right: 16, left: 6, top: 34),
          child: LineChartSample(
            selectedDays: selectedDays,
            feeData: feeData,
            incomeData: incomeData,
            spendingData: spendingData,
            balanceData: !isShowingBalanceData ? balanceData : null,
            balanceInCurrency: balanceInCurrency,
            selectedCurrency: selectedCurrency,
            showFeeLine: showFeeLine,
          ),
        ),
        Center(
          child: TextButton(
            child: Text(
              !isShowingBalanceData ? 'Show Statistics over period'.i18n(ref) : 'Show Balance'.i18n(ref),
              style: const TextStyle(color: Colors.grey),
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
          children: !isShowingBalanceData
              ? [_buildLegend('Balance Over Time', Colors.orangeAccent)]
              : [
            _buildLegend('Spending', Colors.blueAccent),
            _buildLegend('Income', Colors.greenAccent),
            if (showFeeLine) _buildLegend('Fee', Colors.orangeAccent),
          ],
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
        Text(label),
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
