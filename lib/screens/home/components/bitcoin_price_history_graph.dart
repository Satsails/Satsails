import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:coingecko_api/data/market_chart_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:fl_chart/fl_chart.dart';

final interactiveModeProvider = StateProvider<bool>((ref) => false);
class LineChartSample extends StatelessWidget {
  final List<MarketChartData> marketData;
  final bool isInteractive;

  const LineChartSample({
    super.key,
    required this.marketData,
    required this.isInteractive,
  });

  @override
  Widget build(BuildContext context) {
    if (marketData.isEmpty) {
      return const Center(child: Text('No data available', style: TextStyle(color: Colors.white)));
    }

    // Map MarketChartData to FlSpot
    List<FlSpot> spots = marketData.map((data) {
      return FlSpot(
        data.date.millisecondsSinceEpoch.toDouble(),
        data.price!,
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.transparent,
          lineTouchData: LineTouchData(
            enabled: isInteractive,
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.orangeAccent,
              tooltipRoundedRadius: 8,
              fitInsideHorizontally: true, // Keep the tooltip inside the screen horizontally
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot spot) {
                  final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                  final formattedDate = DateFormat('dd/MM/yyyy').format(date);
                  final bitcoinValue = spot.y.toStringAsFixed(2);

                  return LineTooltipItem(
                    '$formattedDate\n\$ $bitcoinValue',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: false,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  String formattedDate = DateFormat('dd/MM').format(date);
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '\$${value.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                },
                reservedSize: 50,
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
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
    );
  }
}

class BitcoinPriceHistoryGraph extends ConsumerWidget {
  const BitcoinPriceHistoryGraph({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketDataAsync = ref.watch(coinGeckoBitcoinMarketDataProvider);
    final isInteractiveMode = ref.watch(interactiveModeProvider);

    return marketDataAsync.when(
      data: (data) {
        return Column(
          children: [
            _buildDateRangeButtons(ref),
            Expanded(
              child: LineChartSample(marketData: data, isInteractive: isInteractiveMode),
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
    final isInteractiveMode = ref.watch(interactiveModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDateRangeButton(ref, 1, '1D'),
          _buildDateRangeButton(ref, 7, '7D'),
          _buildDateRangeButton(ref, 30, '1M'),
          _buildDateRangeButton(ref, 365, '1Y'),
          IconButton(
            onPressed: () {
              ref.read(interactiveModeProvider.notifier).state = !isInteractiveMode;
            },
            icon: Icon(Icons.touch_app, color: isInteractiveMode ? Colors.orangeAccent : Colors.white),
          ),
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
