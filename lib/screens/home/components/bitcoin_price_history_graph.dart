import 'package:Satsails/models/coingecko_model.dart';
import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:coingecko_api/data/market_chart_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChartSample extends StatelessWidget {
  final List<MarketChartData> marketData;

  const LineChartSample({
    super.key,
    required this.marketData,
  });

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: const DateTimeAxis(
        isVisible: true,
        majorGridLines: MajorGridLines(width: 0),
        minorGridLines: MinorGridLines(width: 0),
        axisLine: AxisLine(width: 0),
        labelStyle: TextStyle(color: Colors.white),
      ),
      primaryYAxis: const NumericAxis(
        isVisible: true,
        majorGridLines: MajorGridLines(width: 0),
        minorGridLines: MinorGridLines(width: 0),
        axisLine: AxisLine(width: 0),
        labelStyle: TextStyle(color: Colors.white),
      ),
      plotAreaBorderWidth: 0,
      trackballBehavior: TrackballBehavior(
        enable: false,
        activationMode: ActivationMode.longPress,
        lineType: TrackballLineType.none, // Disable vertical lines
        tooltipSettings: const InteractiveTooltip(
          enable: true,
          color: Colors.orangeAccent,
          textStyle: TextStyle(color: Colors.white),
          borderWidth: 0,
          decimalPlaces: 8,
        ),
        builder: (BuildContext context, TrackballDetails trackballDetails) {
          final DateFormat formatter = DateFormat('dd/MM');
          final DateTime date = trackballDetails.point!.x;
          final num? value = trackballDetails.point!.y;
          final String formattedDate = formatter.format(date);
          final String bitcoinValue = value!.toStringAsFixed(value == value.roundToDouble() ? 0 : 8);

          return Text(
            '$formattedDate\nBitcoin: $bitcoinValue',
            style: const TextStyle(color: Colors.white),
          );
        },
      ),
      series: _chartSeries(),
    );
  }

  List<SplineSeries<MarketChartData, DateTime>> _chartSeries() {
    return [
      SplineSeries<MarketChartData, DateTime>(
        name: 'Market Data',
        dataSource: marketData,
        xValueMapper: (MarketChartData data, _) => data.date,
        yValueMapper: (MarketChartData data, _) => data.price,
        color: Colors.orangeAccent,
        markerSettings: const MarkerSettings(isVisible: false),
        animationDuration: 0,
      ),
    ];
  }
}

class BitcoinPriceHistoryGraph extends ConsumerWidget {
  const BitcoinPriceHistoryGraph({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketData = ref.watch(coinGeckoBitcoinMarketDataProvider);

    return marketData.when(
      data: (data) {
        return Column(
          children: [
            _buildDateRangeButtons(ref),
            Expanded(
              child: LineChartSample(marketData: data),
            ),
          ],
        );
      },
      loading: () {
        return Center(
          child: LoadingAnimationWidget.threeArchedCircle(size: 100, color: Colors.orange),
        );
      },
      error: (error, stack) {
        return Center(
          child: Text('Error: $error'),
        );
      },
    );
  }

  Widget _buildDateRangeButtons(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDateRangeButton(ref, 7, '7'),
        _buildDateRangeButton(ref, 30, '30'),
        _buildDateRangeButton(ref, 90, '90'),
        _buildDateRangeButton(ref, 365, '1Y'),
      ],
    );
  }

  Widget _buildDateRangeButton(WidgetRef ref, int range, String text) {
    final selectedDateRange = ref.watch(selectedDateRangeProvider);

    return TextButton(
      onPressed: () => ref.read(selectedDateRangeProvider.notifier).state = range,
      child: Text(
        text,
        style: TextStyle(
          color: selectedDateRange == range ? Colors.orangeAccent : Colors.white,
        ),
      ),
    );
  }
}

