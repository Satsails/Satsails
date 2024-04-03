import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:satsails/providers/navigation_provider.dart';
import '../shared/bottom_navigation_bar.dart';
import '../shared/transactions_builder.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class Analytics extends ConsumerWidget {
  DateTime selectedDate = DateTime.now();

  Analytics({super.key});

  void _parseData(BuildContext context, DateTime date) {
    List<Object?> transactionsByMonth = [];
    for (var transaction in []) {
      if (transaction is Map<Object?, Object?>) {
        try {
          DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch((transaction['created_at_ts'] as int));
          if (dateTime.month == date.month && dateTime.year == date.year) {
            transactionsByMonth.add(transaction);
          }
        //   implement proper handling of the code  for income and spent by token and by type
        //   implement check by year
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error parsing transaction data'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Analytics'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: _buildBody(context),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: ref.watch(navigationProvider),
        context: context,
        onTap: (int index) {
          ref.read(navigationProvider.notifier).state = index;
        },
      ),
    );
  }

  // implement a chart converted by coin (user can choose coin)
  Widget _buildChart() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: LineChart(
        LineChartData(
          maxX: 31,
          lineBarsData: [
            // add a line bar for fees
            LineChartBarData(
              spots: [FlSpot(1, 4), FlSpot(1, 5)],
              isCurved: true,
              belowBarData: BarAreaData(show: true, color: Colors.amber),
              color: Colors.amber, // Amber color
              dotData: FlDotData(show: false),
              isStrokeCapRound: true,
            ),
          ],
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(
                color: Colors.transparent,
              ),
              left: BorderSide(
                color: Colors.transparent,
              ),
              right: BorderSide(
                color: Colors.transparent,
              ),
              top: BorderSide(
                color: Colors.transparent,
              ),
            ),
          ),
          gridData: FlGridData(
            show: false,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Colors.grey,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: false,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blue,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final TextStyle textStyle = TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  );
                  return LineTooltipItem(
                    touchedSpot.y.toStringAsFixed(2),
                    textStyle,
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildBody(context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        // implement data on different screens
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     Column(
        //       children: [
        //         Text("Spent"),
        //         Text("${totalSpent.toStringAsFixed(0)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        //       ],
        //     ),
        //     Column(
        //       children: [
        //         Text("Income"),
        //         Text("${totalIncome.toStringAsFixed(0)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        //       ],
        //     ),
        //     Column(
        //       children: [
        //         Text("Fees"),
        //         Text("${totalIncome.toStringAsFixed(0)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        //       ],
        //     ),
        //   ],
        // ),
        // SizedBox(height: MediaQuery.of(context).size.height * 0.04),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     Column(
        //       children: [
        //         Text("Spent in USD"),
        //         Text("${totalSpentUsd.toStringAsFixed(0)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        //       ],
        //     ),
        //     Column(
        //       children: [
        //         Text("Income in USD"),
        //         Text("${totalIncomeUsd.toStringAsFixed(0)}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        //       ],
        //     ),
        //   ],
        // ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        ElevatedButton(
          onPressed: () {
            showMonthPicker(
                    context: context,
                    initialDate: selectedDate,
                    headerColor: Colors.white,
                    headerTextColor: Colors.black,
                    selectedMonthBackgroundColor: Colors.amber[900],
                    roundedCornersRadius: 20,
                  )
                .then((date) {
              _parseData(context, selectedDate);
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            '${selectedDate.month}/${selectedDate.year}',
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        // Expanded(
        //   child: _buildChart(),
        // ),


        Expanded(
          child: buildTransactions([], context)
        ),
      ],
    );
  }
}