import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/screens/analytics/components/bitcoin_expenses_graph.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Analytics extends ConsumerStatefulWidget {
  const Analytics({super.key});

  @override
  ConsumerState<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends ConsumerState<Analytics> {
  int viewMode = 0; // 0: BTC Balance, 1: Currency Balance, 2: Statistics
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedRange = '30 days'; // Default to 30 days

  // Helper to get normalized date range or default to last 30 days
  List<DateTime> _getNormalizedDateRange() {
    final now = DateTime.now().dateOnly();
    final start = _startDate ?? now.subtract(const Duration(days: 29));
    final end = _endDate ?? now;

    final days = <DateTime>[];
    DateTime current = start;
    while (!current.isAfter(end)) {
      days.add(current.dateOnly());
      current = current.add(const Duration(days: 1));
    }
    // Update state if not already set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_startDate == null || _endDate == null) {
        setState(() {
          _startDate = start;
          _endDate = end;
        });
      }
    });
    return days;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentSelection = ref.read(selectedDaysDateArrayProvider);
      if (currentSelection.isEmpty) {
        final now = DateTime.now().dateOnly();
        final defaultStart = now.subtract(const Duration(days: 29));
        final defaultEnd = now;
        final defaultDays = <DateTime>[];
        DateTime current = defaultStart;
        while (!current.isAfter(defaultEnd)) {
          defaultDays.add(current.dateOnly());
          current = current.add(const Duration(days: 1));
        }
        setState(() {
          _startDate = defaultStart;
          _endDate = defaultEnd;
        });
        ref.read(selectedDaysDateArrayProvider.notifier).state = defaultDays;
      } else {
        setState(() {
          _startDate = currentSelection.first;
          _endDate = currentSelection.last;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers for settings and data
    final settings = ref.watch(settingsProvider);
    final selectedCurrency = settings.currency;
    final btcFormat = settings.btcFormat;

    final selectedDays = _getNormalizedDateRange();

    final feeData = ref.watch(bitcoinFeeSpentPerDayProvider);
    final incomeData = ref.watch(bitcoinIncomePerDayProvider);
    final spendingData = ref.watch(bitcoinSpentPerDayProvider);
    final bitcoinBalanceByDayFormatted = ref.watch(bitcoinBalanceInFormatByDayProvider);
    final bitcoinBalanceByDayUnformatted = ref.watch(bitcoinBalanceInBtcByDayProvider);
    final marketDataAsync = ref.watch(bitcoinHistoricalMarketDataProvider);
    final btcBalanceInFormat = ref.watch(btcBalanceInFormatProvider(btcFormat));

    // Calculate dollar balance and price by day
    final (dollarBalanceByDay, priceByDay) = marketDataAsync.when(
      data: (marketData) {
        final dailyPrices = <DateTime, num>{};
        for (var dataPoint in marketData) {
          final date = dataPoint.date.toLocal().dateOnly();
          dailyPrices[date] = dataPoint.price ?? 0;
        }

        final dailyDollarBalance = <DateTime, num>{};
        num lastKnownBalance = 0;
        num lastKnownPrice = 0;

        for (var day in selectedDays) {
          final normalizedDay = day.dateOnly();
          if (bitcoinBalanceByDayUnformatted.containsKey(normalizedDay)) {
            lastKnownBalance = bitcoinBalanceByDayUnformatted[normalizedDay]!;
          }
          if (dailyPrices.containsKey(normalizedDay)) {
            lastKnownPrice = dailyPrices[normalizedDay]!;
          }
          dailyDollarBalance[normalizedDay] = lastKnownBalance * lastKnownPrice;
        }
        return (dailyDollarBalance, dailyPrices);
      },
      loading: () => (<DateTime, num>{}, <DateTime, num>{}),
      error: (_, __) => (<DateTime, num>{}, <DateTime, num>{}),
    );

    // Determine main data based on view mode
    final mainData = viewMode == 0 ? bitcoinBalanceByDayFormatted : viewMode == 1 ? dollarBalanceByDay : null;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Date Range Dropdown
          DropdownButton<String>(
            value: _selectedRange,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.grey[800],
            underline: const SizedBox(),
            items: ['7 days', '30 days', '6 months'].map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedRange = newValue;
                  final now = DateTime.now().dateOnly();
                  switch (newValue) {
                    case '7 days':
                      _startDate = now.subtract(const Duration(days: 6));
                      break;
                    case '30 days':
                      _startDate = now.subtract(const Duration(days: 29));
                      break;
                    case '6 months':
                      _startDate = now.subtract(const Duration(days: 182));
                      break;
                  }
                  _endDate = now;
                  final days = <DateTime>[];
                  DateTime current = _startDate!;
                  while (!current.isAfter(_endDate!)) {
                    days.add(current.dateOnly());
                    current = current.add(const Duration(days: 1));
                  }
                  ref.read(selectedDaysDateArrayProvider.notifier).state = days;
                });
              }
            },
          ),
          // Calendar Button
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              final selectedDateRange = await showCalendarDatePicker2Dialog(
                context: context,
                config: CalendarDatePicker2WithActionButtonsConfig(
                  calendarType: CalendarDatePicker2Type.range,
                  firstDate: DateTime(2009, 1, 3),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                  currentDate: _endDate ?? DateTime.now(),
                  selectedRangeHighlightColor: Colors.orange.withOpacity(0.3),
                  centerAlignModePicker: true,
                  controlsTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  dayTextStyle: const TextStyle(color: Colors.white),
                  disabledDayTextStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  weekdayLabelTextStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  selectedDayTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  selectedDayHighlightColor: Colors.orange,
                  yearTextStyle: const TextStyle(color: Colors.white),
                  selectedYearTextStyle: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  dayBorderRadius: BorderRadius.circular(4),
                  okButton: Text('OK', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  cancelButton: Text('CANCEL', style: TextStyle(color: Colors.white70)),
                ),
                dialogSize: const Size(325, 400),
                value: (_startDate != null && _endDate != null) ? [_startDate, _endDate] : [],
                borderRadius: BorderRadius.circular(15),
                dialogBackgroundColor: Colors.grey[900],
              );

              if (selectedDateRange != null && selectedDateRange.isNotEmpty) {
                final newStart = selectedDateRange.first?.dateOnly();
                final newEnd = (selectedDateRange.length > 1 ? selectedDateRange.last?.dateOnly() : newStart);

                if (newStart != null && newEnd != null) {
                  final DateTime effectiveStart = newStart.isAfter(newEnd) ? newEnd : newStart;
                  final DateTime effectiveEnd = newStart.isAfter(newEnd) ? newStart : newEnd;

                  final days = <DateTime>[];
                  DateTime current = effectiveStart;
                  while (!current.isAfter(effectiveEnd)) {
                    days.add(current.dateOnly());
                    current = current.add(const Duration(days: 1));
                  }

                  setState(() {
                    _startDate = effectiveStart;
                    _endDate = effectiveEnd;
                    // Update dropdown to reflect custom range (optional)
                    _selectedRange = 'Custom'; // You can add "Custom" to the dropdown options if desired
                  });
                  ref.read(selectedDaysDateArrayProvider.notifier).state = days;
                }
              }
            },
          ),
          // Reset Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _selectedRange = '30 days';
                  final now = DateTime.now().dateOnly();
                  _startDate = now.subtract(const Duration(days: 29));
                  _endDate = now;
                  final days = <DateTime>[];
                  DateTime current = _startDate!;
                  while (!current.isAfter(_endDate!)) {
                    days.add(current.dateOnly());
                    current = current.add(const Duration(days: 1));
                  }
                  ref.read(selectedDaysDateArrayProvider.notifier).state = days;
                  viewMode = 0; // Reset to BTC Balance
                });
              },
              child: const Text(
                'Reset',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance Card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Current Bitcoin Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$btcBalanceInFormat $btcFormat',
                        style: TextStyle(
                          fontSize: screenWidth / 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // View Mode Toggle Buttons (Button Slider Selector)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ToggleButtons(
              isSelected: [viewMode == 0, viewMode == 1, viewMode == 2],
              onPressed: (index) {
                setState(() {
                  viewMode = index;
                });
              },
              borderRadius: BorderRadius.circular(20.0),
              selectedColor: Colors.black,
              fillColor: Colors.orange,
              color: Colors.white,
              borderColor: Colors.grey[800],
              selectedBorderColor: Colors.orange,
              constraints: BoxConstraints(minWidth: screenWidth / 4, minHeight: 40),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('BTC Balance'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('$selectedCurrency Valuation'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Statistics'),
                ),
              ],
            ),
          ),
          // Graph
          Expanded(
            child: marketDataAsync.when(
              data: (_) {
                return Chart(
                  selectedDays: selectedDays,
                  feeData: feeData,
                  incomeData: incomeData,
                  spendingData: spendingData,
                  mainData: mainData,
                  bitcoinBalanceByDayUnformatted: bitcoinBalanceByDayUnformatted,
                  dollarBalanceByDay: dollarBalanceByDay,
                  priceByDay: priceByDay,
                  selectedCurrency: selectedCurrency,
                  isShowingMainData: viewMode != 2,
                  isCurrency: viewMode == 1,
                  btcFormat: btcFormat,
                );
              },
              loading: () => Center(
                child: LoadingAnimationWidget.fourRotatingDots(
                  color: Colors.orangeAccent,
                  size: screenHeight * 0.08,
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Error Loading Market Data',
                        style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please check your connection and try again.\n${error.toString()}',
                        style: TextStyle(color: Colors.red.shade200, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text('Retry', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          ref.invalidate(bitcoinHistoricalMarketDataProvider);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}