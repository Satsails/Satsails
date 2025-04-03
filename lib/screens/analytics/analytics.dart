import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/screens/analytics/components/chart.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:intl/intl.dart';

class Analytics extends ConsumerStatefulWidget {
  const Analytics({super.key});

  @override
  ConsumerState<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends ConsumerState<Analytics> {
  int viewMode = 0; // 0: BTC Balance, 1: Currency Valuation
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedRange = '30 days'; // Default to 30 days
  String _selectedAsset = 'Bitcoin'; // Default to Bitcoin

  // Helper method to compute the normalized date range, including "ALL" option
  List<DateTime> _getNormalizedDateRange() {
    final now = DateTime.now().dateOnly();
    DateTime start;

    // Get transactions based on the selected asset
    final transactions = _selectedAsset == 'Bitcoin'
        ? ref.read(transactionNotifierProvider).bitcoinTransactions
        : ref.read(transactionNotifierProvider).liquidTransactions;

    // Find the first valid transaction date
    DateTime? firstTransactionDate;
    for (var transaction in transactions) {
      final time = transaction.timestamp;
      if (time != null && time != 0) {
        firstTransactionDate = time.dateOnly();
        break;
      }
    }

    if (_selectedRange == 'ALL') {
      start = firstTransactionDate ?? now.subtract(const Duration(days: 29));
    } else {
      start = _startDate ?? now.subtract(const Duration(days: 29));
    }
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
    // Initialize date range based on provider or default to 30 days
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
    final settings = ref.watch(settingsProvider);
    final selectedCurrency = settings.currency;
    final btcFormat = settings.btcFormat;

    final selectedDays = _getNormalizedDateRange();

    final asset = AssetMapper.reverseMapTicker(AssetId.LBTC);

    // Historical balance data for the selected asset
    final selectedBalanceByDayFormatted = _selectedAsset == 'Bitcoin'
        ? ref.watch(bitcoinBalanceInFormatByDayProvider)
        : ref.watch(liquidBalancePerDayInFormatProvider(asset));

    final selectedBalanceByDayUnformatted = _selectedAsset == 'Bitcoin'
        ? ref.watch(bitcoinBalanceInBtcByDayProvider)
        : ref.watch(liquidBalancePerDayInBTCFormatProvider(asset));

    // Current balance for the selected asset
    final selectedAssetBalanceFormatted = _selectedAsset == 'Bitcoin'
        ? ref.watch(btcBalanceInFormatProvider(btcFormat))
        : ref.watch(liquidBalanceInFormatProvider(asset));

    // Total balance across all assets
    final totalBalance = ref.watch(totalBalanceInDenominationProvider(btcFormat));

    final marketDataAsync = ref.watch(bitcoinHistoricalMarketDataProvider);

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
          if (selectedBalanceByDayUnformatted.containsKey(normalizedDay)) {
            lastKnownBalance = selectedBalanceByDayUnformatted[normalizedDay]!;
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

    final mainData = viewMode == 0 ? selectedBalanceByDayFormatted : dollarBalanceByDay;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              viewMode = 0;
              _selectedAsset = 'Bitcoin'; // Reset to Bitcoin on back
            });
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // Date Range Dropdown
          DropdownButton<String>(
            value: _selectedRange,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.grey[800],
            underline: const SizedBox(),
            items: ['7 days', '30 days', '6 months', 'ALL', 'Custom'].map((String option) {
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
                  final transactions = _selectedAsset == 'Bitcoin'
                      ? ref.read(transactionNotifierProvider).bitcoinTransactions
                      : ref.read(transactionNotifierProvider).liquidTransactions;

                  // Find the first valid transaction date
                  DateTime? firstTransactionDate;
                  for (var transaction in transactions) {
                    final time = transaction.timestamp;
                    if (time != null && time != 0) {
                      firstTransactionDate = time.dateOnly();
                      break;
                    }
                  }

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
                    case 'ALL':
                      _startDate = firstTransactionDate ?? now.subtract(const Duration(days: 29));
                      break;
                    case 'Custom':
                    // Do nothing, let the calendar handle custom ranges
                      return;
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
          // Asset Selection Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _selectedAsset,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              style: const TextStyle(color: Colors.white),
              dropdownColor: Colors.grey[800],
              underline: const SizedBox(),
              items: ['Bitcoin', 'Liquid Bitcoin'].map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedAsset = newValue;
                  });
                }
              },
            ),
          ),
          // Calendar Button
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              final selectedDateRange = await showCalendarDatePicker2Dialog(
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
                  selectedRangeHighlightColor: Colors.orange.withOpacity(0.3),
                  disabledDayTextStyle: const TextStyle(color: Colors.grey),
                  yearTextStyle: const TextStyle(color: Colors.white),
                  lastMonthIcon: const Icon(Icons.arrow_back, color: Colors.white),
                  nextMonthIcon: const Icon(Icons.arrow_forward, color: Colors.white),
                  okButton: const Text('OK', style: TextStyle(color: Colors.orange)),
                  cancelButton: const Text('CANCEL', style: TextStyle(color: Colors.white)),
                ),
                dialogSize: const Size(325, 400),
                dialogBackgroundColor: const Color(0xFF212121),
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
                    _selectedRange = 'Custom';
                  });
                  ref.read(selectedDaysDateArrayProvider.notifier).state = days;
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance Card for Selected Asset
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
                    Text(
                      'Current $_selectedAsset Balance',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$selectedAssetBalanceFormatted $btcFormat',
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
          // Toggle Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ToggleButtons(
              isSelected: [viewMode == 0, viewMode == 1],
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
              ],
            ),
          ),
          // Total Balance Display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Total Balance: $totalBalance $btcFormat',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          // Graph
          Expanded(
            child: marketDataAsync.when(
              data: (_) {
                return Chart(
                  selectedDays: selectedDays,
                  mainData: mainData,
                  bitcoinBalanceByDayUnformatted: selectedBalanceByDayUnformatted,
                  dollarBalanceByDay: dollarBalanceByDay,
                  priceByDay: priceByDay,
                  selectedCurrency: selectedCurrency,
                  isShowingMainData: true,
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