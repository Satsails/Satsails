import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/screens/analytics/components/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:i18n_extension/default.i18n.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Analytics extends ConsumerStatefulWidget {
  const Analytics({super.key});

  @override
  ConsumerState<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends ConsumerState<Analytics> {
  int viewMode = 0;
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedRange = '1M';
  String _selectedAsset = 'Bitcoin';

  final Map<String, String> _networkImages = {
    'Bitcoin': 'lib/assets/bitcoin-logo.png',
    'Liquid Bitcoin': 'lib/assets/l-btc.png',
  };

  List<DateTime> _getNormalizedDateRange() {
    final now = DateTime.now().dateOnly();
    DateTime start;

    final transactions = _selectedAsset == 'Bitcoin'
        ? ref.read(transactionNotifierProvider).bitcoinTransactions
        : ref.read(transactionNotifierProvider).liquidTransactions;

    DateTime? firstTransactionDate;
    for (var transaction in transactions) {
      final time = transaction.timestamp;
      if (time != null && time != 0) {
        firstTransactionDate = time.dateOnly();
        break;
      }
    }

    start = _startDate ?? now.subtract(const Duration(days: 29));
    final end = _endDate ?? now;

    final days = <DateTime>[];
    DateTime current = start;
    while (!current.isAfter(end)) {
      days.add(current.dateOnly());
      current = current.add(const Duration(days: 1));
    }

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentSelection = ref.read(selectedDaysDateArrayProvider);
      if (currentSelection.isEmpty) {
        final now = DateTime.now().dateOnly();
        final defaultStart = now.subtract(const Duration(days: 29)); // Matches '1M'
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
    super.initState();
  }

  /// Builds a Row with the network icon and text for dropdown items
  Widget _buildNetworkRow(String network, {required double size}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          _networkImages[network]!,
          width: size.sp,
          height: size.sp,
        ),
        SizedBox(width: 10.sp),
        Text(
          network,
          style: TextStyle(color: Colors.white, fontSize: (size * 0.66).sp),
        ),
      ],
    );
  }

  /// Builds view mode selection buttons
  Widget _buildViewModeButtons(String selectedCurrency) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              viewMode = 0;
            });
          },
          style: TextButton.styleFrom(
            backgroundColor: Color(0xFF212121),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          ),
          child: Text(
            'Balance'.i18n,
            style: TextStyle(
              fontSize: 14.sp,
              color: viewMode == 0 ? Colors.orangeAccent : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 16.sp),
        TextButton(
          onPressed: () {
            setState(() {
              viewMode = 1;
            });
          },
          style: TextButton.styleFrom(
            backgroundColor: Color(0xFF212121),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          ),
          child: Text(
            '$selectedCurrency Valuation',
            style: TextStyle(
              fontSize: 14.sp,
              color: viewMode == 1 ? Colors.orangeAccent : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the price percentage change ticker
  Widget _buildPricePercentageChangeTicker(
      BuildContext context, WidgetRef ref, double percentageChange) {
    final currency = ref.watch(settingsProvider).currency;
    final currentPrice = ref.watch(selectedCurrencyProvider(currency)) * 1;

    IconData? icon;
    Color textColor;
    String displayText = '${percentageChange.abs().toStringAsFixed(2)}%';

    if (percentageChange == 0) {
      icon = null;
      textColor = Colors.white;
    } else if (percentageChange > 0) {
      icon = Icons.arrow_upward;
      textColor = Colors.green;
    } else {
      icon = Icons.arrow_downward;
      textColor = Colors.red;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$${currentPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          VerticalDivider(
            color: Colors.white,
            thickness: 1,
            width: 20.w,
          ),
          Row(
            children: [
              if (icon != null)
                Icon(
                  icon,
                  size: 20.sp,
                  color: textColor,
                ),
              SizedBox(width: icon != null ? 4.w : 0),
              Text(
                percentageChange > 0 ? '+$displayText' : displayText,
                style: TextStyle(
                  fontSize: 20.sp,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final selectedCurrency = settings.currency;
    final btcFormat = settings.btcFormat;

    final selectedDays = _getNormalizedDateRange();

    final asset = AssetMapper.reverseMapTicker(AssetId.LBTC);

    final selectedBalanceByDayFormatted = _selectedAsset == 'Bitcoin'
        ? ref.watch(bitcoinBalanceInFormatByDayProvider)
        : ref.watch(liquidBalancePerDayInFormatProvider(asset));

    final selectedBalanceByDayUnformatted = _selectedAsset == 'Bitcoin'
        ? ref.watch(bitcoinBalanceInBtcByDayProvider)
        : ref.watch(liquidBalancePerDayInBTCFormatProvider(asset));

    final selectedAssetBalanceFormatted = _selectedAsset == 'Bitcoin'
        ? ref.watch(btcBalanceInFormatProvider(btcFormat))
        : ref.watch(liquidBalanceInFormatProvider(asset));

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

    // Calculate percentage change
    double percentageChange = 0;
    if (priceByDay.isNotEmpty) {
      final firstDayWithData = selectedDays.firstWhere(
            (day) => priceByDay.containsKey(day),
        orElse: () => selectedDays.first,
      );
      final lastDayWithData = selectedDays.lastWhere(
            (day) => priceByDay.containsKey(day),
        orElse: () => selectedDays.last,
      );
      final startPrice = priceByDay[firstDayWithData] ?? 0;
      final endPrice = priceByDay[lastDayWithData] ?? 0;
      if (startPrice != 0) {
        percentageChange = ((endPrice - startPrice) / startPrice * 100);
      }
    }

    final mainData = viewMode == 0 ? selectedBalanceByDayFormatted : dollarBalanceByDay;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final assetDropdown = Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      child: DropdownButton<String>(
        value: _selectedAsset,
        items: ['Bitcoin', 'Liquid Bitcoin'].map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: _buildNetworkRow(option, size: 35),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedAsset = newValue;
            });
          }
        },
        dropdownColor: Color(0xFF212121),
        style: TextStyle(color: Colors.white, fontSize: 14.sp),
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white, size: 24.sp),
        underline: const SizedBox(),
      ),
    );

    final dateRanges = ['7D', '1M', '3M', '6M', '1Y', 'ALL'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
         onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            assetDropdown,
            Text(
              '$selectedAssetBalanceFormatted $btcFormat',
              style: TextStyle(
                fontSize: screenWidth / 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
              child: _buildViewModeButtons(selectedCurrency),
            ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: dateRanges.map((range) {
                return TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedRange = range;
                      final now = DateTime.now().dateOnly();
                      final transactions = _selectedAsset == 'Bitcoin'
                          ? ref.read(transactionNotifierProvider).bitcoinTransactions
                          : ref.read(transactionNotifierProvider).liquidTransactions;

                      DateTime? firstTransactionDate;
                      for (var transaction in transactions) {
                        final time = transaction.timestamp;
                        if (time != null && time != 0) {
                          firstTransactionDate = time.dateOnly();
                          break;
                        }
                      }

                      switch (range) {
                        case '7D':
                          _startDate = now.subtract(const Duration(days: 6));
                          break;
                        case '1M':
                          _startDate = now.subtract(const Duration(days: 29));
                          break;
                        case '3M':
                          _startDate = now.subtract(const Duration(days: 89));
                          break;
                        case '6M':
                          _startDate = now.subtract(const Duration(days: 179));
                          break;
                        case '1Y':
                          _startDate = now.subtract(const Duration(days: 364));
                          break;
                        case 'ALL':
                          _startDate = firstTransactionDate ?? now.subtract(const Duration(days: 29));
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
                  },
                  child: Text(
                    range,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _selectedRange == range ? Colors.orangeAccent : Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
              child: marketDataAsync.when(
                data: (_) => _buildPricePercentageChangeTicker(context, ref, percentageChange),
                loading: () => LoadingAnimationWidget.progressiveDots(
                  size: 16.sp,
                  color: Colors.white,
                ),
                error: (error, stack) => Text(
                  'Error',
                  style: TextStyle(fontSize: 16.sp, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}