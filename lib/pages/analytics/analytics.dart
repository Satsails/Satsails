import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../channels/greenwallet.dart' as greenwallet;
import 'package:fl_chart/fl_chart.dart';
import '../../helpers/networks.dart';
import '../home/components/bottom_navigation_bar.dart';
import '../transactions/components/transactions_builder.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class Analytics extends StatefulWidget {
  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  int _currentIndex = 2;
  final _storage = const FlutterSecureStorage();
  late String mnemonic;
  List<Object?> bitcoinTransactions = [];
  List<Object?> allTransactions = [];
  List<Object?> liquidTransactions = [];
  double totalSpent = 0.0;
  double totalFees = 0.0;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadMnemonic().then((_) {
      _fetchData();
    });
  }

  Future<void> loadMnemonic() async {
    mnemonic = await _storage.read(key: 'mnemonic') ?? '';
  }

  Future<void> _fetchData() async {
    final channel = greenwallet.Channel('ios_wallet');

    bitcoinTransactions = await channel.getTransactions(
      mnemonic: mnemonic,
      connectionType: NetworkSecurityCase.bitcoinSS.network,
    );

    liquidTransactions = await channel.getTransactions(
      mnemonic: mnemonic,
      connectionType: NetworkSecurityCase.liquidSS.network,
    );

    setState(() {
      allTransactions = bitcoinTransactions + liquidTransactions;
    });
  }

  void _parseData(DateTime month) {
    totalSpent = 0.0;
    totalFees = 0.0;

    for (var transaction in allTransactions) {
      if (transaction is Map<Object?, Object?>) {
        if (transaction['type'] == 'outgoing') {
          final amount = transaction['amount'] as double;
          final fee = transaction['fee'] as double;
          final date = DateTime.parse(transaction['date'] as String);

          if (date.month == month.month && date.year == month.year) {
            totalSpent += amount;
            totalFees += fee;
          }
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.white,
      ),
      body: _buildBody(context),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        context: context,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // change to monthly, line chart with 2 lines, one for fees and one for transactions sent
  // every month from a dropdown is a new chart
  // choose select all also
  Widget _buildChart() {
    return BarChart(
      BarChartData(
        maxY: 5,
        barGroups: [
          BarChartGroupData(
            x: 5,
            barsSpace: 8,
            barRods: [
              BarChartRodData(
                toY: 3,
                width: 16,
                color: Colors.red,
              ),
            ],
          ),
          BarChartGroupData(
            x: 5,
            barsSpace: 8,
            barRods: [
              BarChartRodData(
                toY: 2,
                width: 16,
                color: Colors.blue,
              ),
            ],
          ),
        ],
        borderData: FlBorderData(
          show: false,
          border: const Border(
            bottom: BorderSide(
              color: Colors.transparent,
            ),
            left: BorderSide(
              color: Colors.grey,
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
              strokeWidth: 1,
            );
          },
        ),
        titlesData: const FlTitlesData(
          show: true,
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
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
        Text("Spent"),
        Text("${totalSpent.toStringAsFixed(2)}", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        ElevatedButton(
          onPressed: () {
            showMonthPicker(
                    context: context,
                    initialDate: DateTime.now(),
                    headerColor: Colors.white,
                    headerTextColor: Colors.black,
                    selectedMonthBackgroundColor: Colors.amber[900],
                    roundedCornersRadius: 20,
                  )
                .then((date) {
              if (date != null) {
                setState(() {
                  selectedDate = date;
                });
              }
            });
          },
          child: Text(
            '${selectedDate.month}/${selectedDate.year}',
            style: TextStyle(fontSize: 20),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Expanded(
          child: _buildChart(),
        ),
        Expanded(
          child: buildTransactions(allTransactions, context)
        ),
      ],
    );
  }
}