import 'package:Satsails/models/coingecko_model.dart';
import 'package:Satsails/providers/coingecko_provider.dart';
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
        isVisible: false,
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
        enable: true,
        activationMode: ActivationMode.singleTap,
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

class BitcoinPriceHistoryGraph extends ConsumerStatefulWidget {
  const BitcoinPriceHistoryGraph({super.key});

  @override
  _BitcoinPriceHistoryGraphState createState() => _BitcoinPriceHistoryGraphState();
}

class _BitcoinPriceHistoryGraphState extends ConsumerState<BitcoinPriceHistoryGraph> {
  int selectedDateRange = 7;

  @override
  Widget build(BuildContext context) {
    MarketData marketData = MarketData(
      days: selectedDateRange,
      currency: 'usd',
    );
    final data = ref.watch(coinGeckoBitcoinMarketDataProvider(marketData));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () => _updateDateRange(7),
              child: const Text('7D', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () => _updateDateRange(30),
              child: const Text('30D', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () => _updateDateRange(90),
              child: const Text('90D', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () => _updateDateRange(365),
              child: const Text('1Y', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        data.when(
          data: (marketData) {
            return LineChartSample(marketData: marketData);
          },
          loading: () => LoadingAnimationWidget.threeArchedCircle(size: 100, color: Colors.orange),
          error: (error, stack) => SvgPicture.asset(
            'lib/assets/GraficoAnalise.svg',
          ),
        ),
      ],
    );
  }

  void _updateDateRange(int range) {
    setState(() {
      selectedDateRange = range;
    });
  }
}

