import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/screens/analytics/components/bitcoin_expenses_graph.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/expenses_model.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class LiquidExpensesGraph extends StatelessWidget {
  final List<DateTime> selectedDays;
  final Map<DateTime, num> sentData;
  final Map<DateTime, num> receivedData;
  final Map<DateTime, num>? mainData;
  final Map<DateTime, num> balanceInCurrency;
  final String selectedCurrency;
  final bool isShowingMainData;

  const LiquidExpensesGraph({
    super.key,
    required this.selectedDays,
    required this.sentData,
    required this.receivedData,
    this.mainData,
    required this.balanceInCurrency,
    required this.selectedCurrency,
    required this.isShowingMainData,
  });

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.days,
        dateFormat: DateFormat('dd/MM'),
        interval: selectedDays.length > 20 ? 5 : 1,
        majorGridLines: const MajorGridLines(width: 0),
        minorGridLines: const MinorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        isVisible: true,
        decimalPlaces: balanceInCurrency.values.isNotEmpty
            ? decimalPlacesBtcFormat(balanceInCurrency.values.reduce((value, element) => value > element ? value : element))
            : 0,
        majorGridLines: const MajorGridLines(width: 0),
        minorGridLines: const MinorGridLines(width: 0),
      ),
      plotAreaBorderWidth: 0,
      trackballBehavior: TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        lineType: TrackballLineType.vertical,
        tooltipSettings: const InteractiveTooltip(
          enable: true,
          color: Colors.orangeAccent,
          textStyle: TextStyle(color: Colors.grey),
          borderWidth: 0,
          decimalPlaces: 8,
        ),
        builder: (BuildContext context, TrackballDetails trackballDetails) {
          final DateFormat formatter = DateFormat('dd/MM');
          final DateTime date = trackballDetails.point!.x;
          final num? value = trackballDetails.point!.y;
          final String formattedDate = formatter.format(date);
          final String bitcoinValue = value!.toStringAsFixed(value == value.roundToDouble() ? 0 : 8);
          final String currencyValue = balanceInCurrency[date]?.toStringAsFixed(balanceInCurrency[date] == balanceInCurrency[date]!.roundToDouble() ? 0 : 2) ?? '0.00';
          final displayString = '$formattedDate\nBitcoin: $bitcoinValue\n$selectedCurrency: $currencyValue';
          final displayStringIfNotMainData = '$bitcoinValue';

          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              isShowingMainData ? displayString : displayStringIfNotMainData,
              style: const TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
      series: _chartSeries(),
    );
  }

  List<LineSeries<MapEntry<DateTime, num>, DateTime>> _chartSeries() {
    final seriesList = <LineSeries<MapEntry<DateTime, num>, DateTime>>[];

    if (mainData != null && isShowingMainData) {
      seriesList.add(LineSeries<MapEntry<DateTime, num>, DateTime>(
        name: 'Main Data',
        dataSource: mainData!.entries.toList(),
        xValueMapper: (MapEntry<DateTime, num> entry, _) => entry.key,
        yValueMapper: (MapEntry<DateTime, num> entry, _) => entry.value,
        color: Colors.orangeAccent,
        markerSettings: const MarkerSettings(isVisible: false),
        dashArray: _getDashArray(mainData!),
      ));
    } else {
      seriesList.add(LineSeries<MapEntry<DateTime, num>, DateTime>(
        name: 'Sent',
        dataSource: sentData.entries.toList(),
        xValueMapper: (MapEntry<DateTime, num> entry, _) => entry.key,
        yValueMapper: (MapEntry<DateTime, num> entry, _) => entry.value,
        color: Colors.blueAccent,
        markerSettings: const MarkerSettings(isVisible: false),
        dashArray: _getDashArray(sentData),
      ));
      seriesList.add(LineSeries<MapEntry<DateTime, num>, DateTime>(
        name: 'Received',
        dataSource: receivedData.entries.toList(),
        xValueMapper: (MapEntry<DateTime, num> entry, _) => entry.key,
        yValueMapper: (MapEntry<DateTime, num> entry, _) => entry.value,
        color: Colors.greenAccent,
        markerSettings: const MarkerSettings(isVisible: false),
        dashArray: _getDashArray(receivedData),
      ));
    }

    return seriesList;
  }

  List<double> _getDashArray(Map<DateTime, num> data) {
    final DateTime now = DateTime.now();
    final List<double> dashArray = data.keys.any((date) => date.isAfter(now)) ? [5, 5] : [];
    return dashArray;
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
    final formattedBalanceData = ref.watch(liquidBalancePerDayInFormatProvider(widget.assetId));
    final formattedBalanceDataInBtc = ref.watch(liquidBalancePerDayInBTCFormatProvider(widget.assetId));
    final selectedCurrency = ref.watch(settingsProvider).currency;
    final currencyRate = ref.watch(selectedCurrencyProvider(selectedCurrency));
    final balanceInCurrency = calculateBalanceInCurrency(formattedBalanceDataInBtc, currencyRate);

    final screenHeight = MediaQuery.of(context).size.height;

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
            mainData: !isShowingBalanceData ? formattedBalanceData : null,
            balanceInCurrency: balanceInCurrency,
            selectedCurrency: selectedCurrency,
            isShowingMainData: !isShowingBalanceData,
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
            _buildLegend('Fee', Colors.orangeAccent),
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
