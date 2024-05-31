import 'package:Satsails/providers/analytics_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LineChartSample extends StatelessWidget {
  final List<int> selectedDays;
  final Map<int, num> feeData;
  final Map<int, num> incomeData;
  final Map<int, num> spendingData;
  final Map<int, num>? mainData;

  const LineChartSample({
    super.key,
    required this.selectedDays,
    required this.feeData,
    required this.incomeData,
    required this.spendingData,
    this.mainData,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      _chartData(),
    );
  }

  LineChartData _chartData() {
    final dataToUse = mainData ?? {...feeData, ...incomeData, ...spendingData};
    final allValues = [...dataToUse.values];
    final double minY = allValues.isNotEmpty ? allValues.reduce((a, b) => a < b ? a : b).toDouble() : 0;
    final double maxY = allValues.isNotEmpty ? allValues.reduce((a, b) => a > b ? a : b).toDouble() : 4;
    final double midY = (minY + maxY) / 2;

    final double minX = selectedDays.isNotEmpty ? selectedDays.first.toDouble() : 0;
    final double maxX = selectedDays.isNotEmpty ? selectedDays.last.toDouble() : 1;

    return LineChartData(
      lineTouchData: _lineTouchData(),
      gridData: _gridData(),
      titlesData: _titlesData(minY, midY, maxY, selectedDays.length),
      borderData: _borderData(),
      lineBarsData: _lineBarsData(),
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
    );
  }

  LineTouchData _lineTouchData() {
    return LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
      ),
    );
  }

  FlTitlesData _titlesData(double minY, double midY, double maxY, int days) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: _bottomTitles(days),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false, getTitlesWidget: (value, meta) {
          const style = TextStyle(
            fontSize: 11,
            color: Colors.grey,
          );
          String text;
          if (value >= 1000) {
            text = (value / 1000).toInt().toString() + 'K';
          } else {
            text = value.toInt().toString();
          }
          return Text(text, style: style);
        }),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  List<LineChartBarData> _lineBarsData() {
    return mainData != null
        ? [_mainLine()]
        : [
      _spendingLine(),
      _incomeLine(),
      _feeLine(),
    ];
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
      color: Colors.grey,
    );
    String text = '';
    if (value.toInt() >= selectedDays.first && value.toInt() <= selectedDays.last) {
      text = selectedDays[(value - selectedDays.first).toInt()].toString();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: Text(text, style: style),
    );
  }

  SideTitles _bottomTitles(int days) {
    if (days > 20) {
      return SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 5,
        getTitlesWidget: _bottomTitleWidgets,
      );
    } else {
      return SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: _bottomTitleWidgets,
      );
    }
  }

  FlGridData _gridData() {
    return FlGridData(show: false);
  }

  FlBorderData _borderData() {
    return FlBorderData(
      show: false,
    );
  }

  LineChartBarData _spendingLine() {
    return LineChartBarData(
      isCurved: true,
      color: Colors.blueAccent,
      barWidth: 8,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: selectedDays
          .map((day) => FlSpot(day.toDouble(), spendingData[day]?.toDouble() ?? 0))
          .toList(),
    );
  }

  LineChartBarData _incomeLine() {
    return LineChartBarData(
      isCurved: true,
      color: Colors.greenAccent,
      barWidth: 8,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: false,
        color: Colors.green.withOpacity(0.3),
      ),
      spots: selectedDays
          .map((day) => FlSpot(day.toDouble(), incomeData[day]?.toDouble() ?? 0))
          .toList(),
    );
  }

  LineChartBarData _feeLine() {
    return LineChartBarData(
      isCurved: true,
      color: Colors.orangeAccent,
      barWidth: 7,
      isStrokeCapRound: false,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: selectedDays
          .map((day) => FlSpot(day.toDouble(), feeData[day]?.toDouble() ?? 0))
          .toList(),
    );
  }

  LineChartBarData _mainLine() {
    return LineChartBarData(
      isCurved: true,
      color: Colors.orangeAccent,
      barWidth: 8,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: selectedDays
          .map((day) => FlSpot(day.toDouble(), mainData?[day]?.toDouble() ?? 0))
          .toList(),
    );
  }
}

class ExpensesGraph extends ConsumerStatefulWidget {
  const ExpensesGraph({super.key});

  @override
  _ExpensesGraphState createState() => _ExpensesGraphState();
}

class _ExpensesGraphState extends ConsumerState<ExpensesGraph> {
  bool isShowingMainData = false;

  @override
  Widget build(BuildContext context) {
    final selectedDays = ref.watch(selectedDaysDateArrayProvider);
    final feeData = ref.watch(bitcoinFeeSpentPerDayProvider);
    final incomeData = ref.watch(bitcoinIncomePerDayProvider);
    final spendingData = ref.watch(bitcoinSpentPerDayProvider);
    final bitcoinBalanceByDay = ref.watch(bitcoinBalanceOverPeriodByDayProvider);

    return AspectRatio(
      aspectRatio: 1.5,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 6, top: 34),
                  child: LineChartSample(
                    selectedDays: selectedDays,
                    feeData: feeData,
                    incomeData: incomeData,
                    spendingData: spendingData,
                    mainData: !isShowingMainData ? bitcoinBalanceByDay : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: !isShowingMainData
                      ? [_buildLegend('Balance Over Time', Colors.orangeAccent)]
                      : [
                    _buildLegend('Spending', Colors.blueAccent),
                    _buildLegend('Income', Colors.greenAccent),
                    _buildLegend('Fee', Colors.orangeAccent),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              icon: Icon(
                Icons.track_changes,
                color: Colors.red.withOpacity(!isShowingMainData ? 1.0 : 0.5),
              ),
              onPressed: () {
                setState(() {
                  isShowingMainData = !isShowingMainData;
                });
              },
            ),
          ),
        ],
      ),
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
}
