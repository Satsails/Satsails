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
          if (trackballDetails.point == null) return Container();

          final DateFormat formatter = DateFormat('dd/MM');
          final DateTime date = trackballDetails.point!.x;
          final num? value = trackballDetails.point!.y;
          final String formattedDate = formatter.format(date);
          final String valueString = value!.toString();

          String displayString;
          if (isBtc && isShowingMainData) {
            final num balance = balanceInCurrency[date]!;
            displayString = '$formattedDate\n$valueString\n${balance.toStringAsFixed(2)} $selectedCurrency';
          } else if (isBtc && isShowingMainData) {
            displayString = '$formattedDate\n$valueString';
          } else {
            displayString = '$valueString';
          }

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
              displayString,
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
      if (isBtc) {
      seriesList.add(LineSeries<MapEntry<DateTime, num>, DateTime>(
        name: 'Fee',
        dataSource: feeData.entries.toList(),
        xValueMapper: (MapEntry<DateTime, num> entry, _) => entry.key,
        yValueMapper: (MapEntry<DateTime, num> entry, _) => entry.value.toDouble(),
        color: Colors.orangeAccent,
        markerSettings: const MarkerSettings(isVisible: false),
        dashArray: _getDashArray(feeData),
      ));
      }
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
    final isBtc = AssetMapper.reverseMapTicker(AssetId.LBTC) == widget.assetId;

    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: <Widget>[
        Container(
          height: screenHeight * 0.18,
          padding: const EdgeInsets.only(right: 16, left: 6, top: 34),
          child: LiquidExpensesGraph(
            selectedDays: selectedDays,
            sentData: spendingData,
            receivedData: incomeData,
            feeData: feeData,
            mainData: !isShowingBalanceData ? formattedBalanceData : null,
            balanceInCurrency: balanceInCurrency,
            selectedCurrency: selectedCurrency,
            isShowingMainData: !isShowingBalanceData,
            isBtc: isBtc,
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
              ? [_buildLegend('Balance'.i18n(ref), Colors.orangeAccent)]
              : [
            _buildLegend('Spending'.i18n(ref), Colors.blueAccent),
            _buildLegend('Income'.i18n(ref), Colors.greenAccent),
            _buildLegend('Fee'.i18n(ref), Colors.orangeAccent),
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

int decimalPlacesBtcFormat(num value) {
  if (value == value.roundToDouble()) return 0;
  final String valueString = value.toString();
  final int decimalPlaces = valueString.split('.').last.length;
  return decimalPlaces;
}
