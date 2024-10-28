import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:coingecko_api/data/market_chart_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartSample extends StatelessWidget {
  final List<MarketChartData> marketData;

  const LineChartSample({
    super.key,
    required this.marketData,
  });

  @override
  Widget build(BuildContext context) {
    if (marketData.isEmpty) {
      return const Center(child: Text('No data available', style: TextStyle(color: Colors.white)));
    }

    // Map MarketChartData to FlSpot and get min/max prices for labels
    List<FlSpot> spots = marketData.map((data) {
      return FlSpot(
        data.date.millisecondsSinceEpoch.toDouble(),
        data.price!,
      );
    }).toList();

    final double maxPrice = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final double minPrice = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          LineChart(
            LineChartData(
              backgroundColor: Colors.transparent,
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.black87,
                  tooltipRoundedRadius: 12,
                  fitInsideHorizontally: true,
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  tooltipMargin: 10,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((LineBarSpot spot) {
                      final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                      final formattedDate = DateFormat('dd MMM, yyyy').format(date);
                      final bitcoinValue = spot.y.toStringAsFixed(2);

                      return LineTooltipItem(
                        '$formattedDate\n\$ $bitcoinValue',
                        TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
          gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
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
                ),
              ],
            ),
          ),
          Positioned(
            top: 10,
            left: 20,
            child: Text(
              '\$${maxPrice.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 20,
            child: Text(
              '\$${minPrice.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class BitcoinPriceHistoryGraph extends ConsumerWidget {
  const BitcoinPriceHistoryGraph({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketDataAsync = ref.watch(coinGeckoBitcoinMarketDataProvider);

    return marketDataAsync.when(
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
          child: Text('Error: $error', style: const TextStyle(color: Colors.white)),
        );
      },
    );
  }

  Widget _buildDateRangeButtons(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDateRangeButton(ref, 1, '1D'),
          _buildDateRangeButton(ref, 7, '7D'),
          _buildDateRangeButton(ref, 30, '1M'),
          _buildDateRangeButton(ref, 365, '1Y'),
        ],
      ),
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
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
