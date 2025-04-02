import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:Satsails/screens/analytics/components/bitcoin_expenses_graph.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Analytics extends ConsumerStatefulWidget {
  const Analytics({super.key});

  @override
  _AnalyticsState createState() => _AnalyticsState();
}

class _AnalyticsState extends ConsumerState<Analytics> {
  int viewMode = 0; // 0: BTC Balance, 1: Currency Balance, 2: Statistics
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    // Watch providers
    final selectedCurrency = ref.watch(settingsProvider).currency;
    final selectedDays = ref.watch(selectedDaysDateArrayProvider);
    final feeData = ref.watch(bitcoinFeeSpentPerDayProvider);
    final incomeData = ref.watch(bitcoinIncomePerDayProvider);
    final spendingData = ref.watch(bitcoinSpentPerDayProvider);
    final bitcoinBalanceByDay = ref.watch(bitcoinBalanceInFormatByDayProvider);
    final bitcoinBalanceByDayUnformatted = ref.watch(bitcoinBalanceInBtcByDayProvider);
    final marketDataAsync = ref.watch(bitcoinHistoricalMarketDataProvider);
    final btcFormat = ref.watch(settingsProvider).btcFormat;
    final btcBalanceInFormat = ref.watch(btcBalanceInFormatProvider(btcFormat));

    // Compute dollar balance by day
    final dollarBalanceByDay = marketDataAsync.when(
      data: (marketData) {
        final priceByDay = <DateTime, num>{};
        for (var data in marketData) {
          final date = data.date.toLocal().dateOnly();
          priceByDay[date] = data.price ?? 0;
        }
        return {
          for (var day in selectedDays)
            if (bitcoinBalanceByDayUnformatted.containsKey(day) && priceByDay.containsKey(day))
              day: bitcoinBalanceByDayUnformatted[day]! * priceByDay[day]!
        };
      },
      loading: () => <DateTime, num>{},
      error: (_, __) => <DateTime, num>{},
    );

    // Determine main data based on view mode
    final mainData = viewMode == 0 ? bitcoinBalanceByDay : viewMode == 1 ? dollarBalanceByDay : null;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Bitcoin Expenses'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bitcoin Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$btcBalanceInFormat $btcFormat',
                      style: TextStyle(
                        fontSize: screenWidth / 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Dropdown and Date Picker
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<int>(
                value: viewMode,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                dropdownColor: const Color(0xFF212121),
                underline: Container(),
                items: [
                  const DropdownMenuItem(value: 0, child: Text('BTC Balance', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 1, child: Text('$selectedCurrency Balance', style: const TextStyle(color: Colors.white))),
                  const DropdownMenuItem(value: 2, child: Text('Statistics', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() => viewMode = newValue);
                  }
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () async {
                  final selectedDate = await showCalendarDatePicker2Dialog(
                    context: context,
                    config: CalendarDatePicker2WithActionButtonsConfig(
                      calendarType: CalendarDatePicker2Type.range,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      currentDate: _startDate ?? DateTime.now(),
                      dayTextStyle: const TextStyle(color: Colors.white),
                      weekdayLabelTextStyle: const TextStyle(color: Colors.white),
                      controlsTextStyle: const TextStyle(color: Colors.white),
                      selectedDayTextStyle: const TextStyle(color: Colors.black),
                      selectedDayHighlightColor: Colors.orange,
                    ),
                    dialogSize: const Size(325, 400),
                  );

                  if (selectedDate != null && selectedDate.isNotEmpty) {
                    setState(() {
                      _startDate = selectedDate.first;
                      _endDate = selectedDate.length > 1 ? selectedDate.last : selectedDate.first;
                      final days = <DateTime>[];
                      for (var date = _startDate!;
                      date.isBefore(_endDate!.add(const Duration(days: 1)));
                      date = date.add(const Duration(days: 1))) {
                        days.add(date.dateOnly());
                      }
                      ref.read(selectedDaysDateArrayProvider.notifier).state = days;
                    });
                  }
                },
              ),
            ],
          ),
          // Line Chart with Fixed Height
          Expanded(
            child: marketDataAsync.when(
              data: (_) => ProfessionalLineChart(
                selectedDays: selectedDays,
                feeData: feeData,
                incomeData: incomeData,
                spendingData: spendingData,
                mainData: mainData,
                bitcoinBalanceByDayUnformatted: bitcoinBalanceByDayUnformatted,
                dollarBalanceByDay: dollarBalanceByDay,
                selectedCurrency: selectedCurrency,
                isShowingMainData: viewMode != 2,
                isCurrency: viewMode == 1,
                btcFormat: 'BTC',
              ),
              loading: () => Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                  color: Colors.orangeAccent,
                  size: screenHeight * 0.08,
                ),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $error', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(bitcoinHistoricalMarketDataProvider),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}