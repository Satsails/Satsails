// Import necessary packages and files
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../channels/greenwallet.dart' as greenwallet;
import 'package:fl_chart/fl_chart.dart';

import '../../helpers/networks.dart';
import '../home/components/bottom_navigation_bar.dart';
import '../transactions/components/transactions_builder.dart';

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
  String _selectedOption = 'Categories';

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

    _parseData();
  }

  void _parseData() {
    bitcoinTransactions.forEach((element) {
      print(element);
    });

    liquidTransactions.forEach((element) {
      print(element);
    });

    setState(() {
      allTransactions = bitcoinTransactions + liquidTransactions;
    });
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
        Expanded(
          flex: 4,
          child: _buildChart(),
        ),
        SizedBox(height: 16), // Add spacing
        _buildDropdown(), // Add the dropdown button
        SizedBox(height: 16), // Add spacing
        Expanded(
          flex: 2,
          child: _buildSelectedContent(allTransactions, context),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Align(
      alignment: Alignment.centerLeft,
      child: DropdownButton<String>(
        value: _selectedOption,
        items: ['Categories', 'Transactions'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedOption = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildSelectedContent(transactions, context) {
    if (_selectedOption == 'Categories') {
      return _buildCategories();
    } else {
      return buildTransactions(transactions, context);
    }
  }

  Widget _buildCategories() {
    return Column(
      children: [
        Text('Bitcoin Categories'),
        Text('Liquid Categories'),
      ],
    );
  }
}
