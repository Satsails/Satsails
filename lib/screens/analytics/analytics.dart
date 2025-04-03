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

  @override
  Widget build(BuildContext context) {
    List<DateTime> _getNormalizedDateRange() {
      // Get the current date (normalized to start of day)
      final now = DateTime.now().dateOnly();
      DateTime start;

      // Step 1: Fetch transactions based on the selected asset
      final transactions = _selectedAsset == 'Bitcoin'
          ? ref.read(transactionNotifierProvider).bitcoinTransactions
          : ref.read(transactionNotifierProvider).liquidTransactions;

      // Step 2: Sort transactions by confirmation time
      transactions.sort((a, b) {
        // Get confirmation time based on asset
        final aTime = _selectedAsset == 'Bitcoin'
            ? a.timestamp ?? DateTime.now()
            : a.timestamp ?? DateTime.now();
        final bTime = _selectedAsset == 'Bitcoin'
            ? b.timestamp ?? DateTime.now()
            : b.timestamp ?? DateTime.now();

        // Handle null cases for sorting
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return -1;
        if (bTime == null) return 1;
        return aTime.compareTo(bTime);
      });

      // Step 3: Find the first valid transaction date
      DateTime? firstTransactionDate;
      for (var transaction in transactions) {
        final time = _selectedAsset == 'Bitcoin'
            ? transaction.timestamp
            : transaction.timestamp;
        if (time != null && time != 0) {
          firstTransactionDate = time.dateOnly();
          break;
        }
      }

      // Step 4: Calculate the start date based on selected range
      if (_selectedRange == 'ALL') {
        // Use the first transaction date, or default to 30 days ago if none exist
        start = firstTransactionDate ?? now.subtract(const Duration(days: 29));
      } else {
        // Use existing start date or default to 30 days ago for other ranges
        start = _startDate ?? now.subtract(const Duration(days: 29));
        // Note: For specific ranges (e.g., 7D, 30D), this could be adjusted in the range selector logic
      }
      final end = _endDate ?? now;

      // Step 5: Generate the list of days
      final days = <DateTime>[];
      DateTime current = start;
      while (!current.isAfter(end)) {
        days.add(current.dateOnly());
        current = current.add(const Duration(days: 1));
      }

      // Step 6: Update state if not already set
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
            items: ['7 days', '30 days', '6 months', 'ALL'].map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedRange = newValue;
                  // Update date range logic here (existing code omitted for brevity)
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
              // Calendar picker logic here (existing code omitted for brevity)
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