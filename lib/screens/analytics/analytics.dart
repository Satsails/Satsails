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
  ConsumerState<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends ConsumerState<Analytics> {
  int viewMode = 0; // 0: BTC Balance, 1: Currency Balance, 2: Statistics
  DateTime? _startDate;
  DateTime? _endDate;


  // Helper to get normalized date range or default
  List<DateTime> _getNormalizedDateRange() {
    final now = DateTime.now().dateOnly();
    final start = _startDate ?? now.subtract(const Duration(days: 29)); // Default to last 30 days
    final end = _endDate ?? now;

    final days = <DateTime>[];
    DateTime current = start;
    while (!current.isAfter(end)) {
      days.add(current.dateOnly()); // Add normalized date
      current = current.add(const Duration(days: 1));
    }
    // Update state if needed, but primary source is provider
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
    // Set initial date range in the provider if not already set by external means
    // We do this *after* the first frame to allow providers to initialize
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
        // Update provider AFTER setting local state
        ref.read(selectedDaysDateArrayProvider.notifier).state = defaultDays;
      } else {
        // Sync local state with provider if provider already has data
        setState(() {
          _startDate = currentSelection.first;
          _endDate = currentSelection.last;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    // Watch providers
    final settings = ref.watch(settingsProvider);
    final selectedCurrency = settings.currency;
    final btcFormat = settings.btcFormat;

    // Use a selector for selectedDays to potentially avoid unnecessary rebuilds
    // Note: Direct watch is usually fine for StateProvider unless it changes very frequently
    // final selectedDays = ref.watch(selectedDaysDateArrayProvider);
    final selectedDays = _getNormalizedDateRange(); // Use helper to ensure range is always available

    // Ensure dependent providers use the *current* selectedDays from the provider
    final feeData = ref.watch(bitcoinFeeSpentPerDayProvider);
    final incomeData = ref.watch(bitcoinIncomePerDayProvider);
    final spendingData = ref.watch(bitcoinSpentPerDayProvider);
    final bitcoinBalanceByDayFormatted = ref.watch(bitcoinBalanceInFormatByDayProvider);
    final bitcoinBalanceByDayUnformatted = ref.watch(bitcoinBalanceInBtcByDayProvider);
    final marketDataAsync = ref.watch(bitcoinHistoricalMarketDataProvider);
    final btcBalanceInFormat = ref.watch(btcBalanceInFormatProvider(btcFormat)); // Overall balance display


    // --- Calculate Price and Dollar Balance by Day ---
    final (dollarBalanceByDay, priceByDay) = marketDataAsync.when(
      data: (marketData) {
        final dailyPrices = <DateTime, num>{};
        for (var dataPoint in marketData) {
          // Ensure dataPoint date is local and normalized
          final date = dataPoint.date.toLocal().dateOnly();
          dailyPrices[date] = dataPoint.price ?? 0;
        }

        final dailyDollarBalance = <DateTime, num>{};
        num lastKnownBalance = 0; // Carry forward balance
        num lastKnownPrice = 0; // Carry forward price

        for (var day in selectedDays) { // Iterate through the DISPLAYED days
          final normalizedDay = day.dateOnly(); // Ensure normalization

          // Get BTC balance for the day, carrying forward if missing
          if (bitcoinBalanceByDayUnformatted.containsKey(normalizedDay)) {
            lastKnownBalance = bitcoinBalanceByDayUnformatted[normalizedDay]!;
          }

          // Get price for the day, carrying forward if missing
          if (dailyPrices.containsKey(normalizedDay)) {
            lastKnownPrice = dailyPrices[normalizedDay]!;
          }

          // Calculate valuation using potentially carried-forward values
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
        foregroundColor: Colors.white, // Ensure title/icons are white
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), // Reduced bottom padding
            child: Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Card takes minimum space
                  children: [
                    const Text(
                      'Current Bitcoin Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    FittedBox( // Ensure text fits
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$btcBalanceInFormat ${btcFormat}',
                        style: TextStyle(
                          fontSize: screenWidth / 12, // Adjust size dynamically
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
          Padding( // Add padding around controls
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dropdown wrapped for better alignment if needed
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: viewMode,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      dropdownColor: Colors.grey[850], // Slightly different dropdown bg
                      style: const TextStyle(color: Colors.white, fontSize: 14), // Consistent style
                      items: [
                        const DropdownMenuItem(value: 0, child: Text('BTC Balance')),
                        DropdownMenuItem(value: 1, child: Text('$selectedCurrency Valuation')),
                        const DropdownMenuItem(value: 2, child: Text('Statistics')),
                      ],
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() => viewMode = newValue);
                        }
                      },
                    ),
                  ),
                ),
                const Spacer(), // Pushes calendar icon to the right
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  tooltip: 'Select Date Range',
                  onPressed: () async {
                    final selectedDateRange = await showCalendarDatePicker2Dialog(
                      context: context,
                      config: CalendarDatePicker2WithActionButtonsConfig(
                        calendarType: CalendarDatePicker2Type.range,
                        firstDate: DateTime(2009, 1, 3), // Bitcoin genesis
                        lastDate: DateTime.now().add(const Duration(days: 1)), // Allow selecting today
                        currentDate: _endDate ?? DateTime.now(), // Highlight end or today
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
                        // Custom action button styles
                        okButton: Text('OK', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        cancelButton: Text('CANCEL', style: TextStyle(color: Colors.white70)),

                      ),
                      dialogSize: const Size(325, 400),
                      value: (_startDate != null && _endDate != null)
                          ? [_startDate, _endDate]
                          : [], // Pre-select current range
                      borderRadius: BorderRadius.circular(15),
                      dialogBackgroundColor: Colors.grey[900],
                    );

                    if (selectedDateRange != null && selectedDateRange.isNotEmpty) {
                      final newStart = selectedDateRange.first?.dateOnly();
                      final newEnd = (selectedDateRange.length > 1 ? selectedDateRange.last?.dateOnly() : newStart);

                      if (newStart != null && newEnd != null) {
                        // Ensure start is before or same as end
                        final DateTime effectiveStart = newStart.isAfter(newEnd) ? newEnd : newStart;
                        final DateTime effectiveEnd = newStart.isAfter(newEnd) ? newStart : newEnd;

                        final days = <DateTime>[];
                        DateTime current = effectiveStart;
                        while (!current.isAfter(effectiveEnd)) {
                          days.add(current.dateOnly());
                          current = current.add(const Duration(days: 1));
                        }

                        // Update local state and provider
                        setState(() {
                          _startDate = effectiveStart;
                          _endDate = effectiveEnd;
                        });
                        ref.read(selectedDaysDateArrayProvider.notifier).state = days;
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          // Line Chart takes remaining space
          Expanded(
            child: marketDataAsync.when(
              data: (_) {
                // Data maps are assumed to be using normalized keys from providers or calculations above
                return ProfessionalLineChart(
                  selectedDays: selectedDays, // Already normalized list
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
                        'Please check your connection and try again.\n${error.toString()}', // Show error details concisely
                        style: TextStyle(color: Colors.red.shade200, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text('Retry', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          ref.invalidate(bitcoinHistoricalMarketDataProvider);
                          // Optionally refresh others if needed
                          // ref.invalidate(selectedDaysDateArrayProvider); // Re-trigger calculations
                        } ,
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