import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/models/datetime_range_model.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/screens/analytics/components/chart.dart';
import 'package:Satsails/screens/shared/balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:i18n_extension/default.i18n.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';

class BalanceCardWithDropdown extends StatelessWidget {
  final String selectedAsset;
  final Function(String) onAssetChanged;
  final String balanceWithUnit;
  final List<String> assetOptions;
  final Map<String, String> assetImages;

  const BalanceCardWithDropdown({
    required this.selectedAsset,
    required this.onAssetChanged,
    required this.balanceWithUnit,
    required this.assetOptions,
    required this.assetImages,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            assetImages[selectedAsset]!,
            width: 35.sp,
            height: 35.sp,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.sp),
              child: Text(
                balanceWithUnit,
                style: TextStyle(
                  fontSize: 24.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                color: const Color(0xFF212121),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: 24.sp,
              ),
              onSelected: (String value) {
                onAssetChanged(value);
              },
              itemBuilder: (BuildContext context) => assetOptions.map((String option) {
                return PopupMenuItem<String>(
                  value: option,
                  child: Row(
                    children: [
                      Image.asset(
                        assetImages[option]!,
                        width: 35.sp,
                        height: 35.sp,
                      ),
                      SizedBox(width: 10.sp),
                      Text(
                        option,
                        style: TextStyle(
                          color: option == selectedAsset ? Colors.orange : Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class Analytics extends ConsumerStatefulWidget {
  const Analytics({super.key});

  @override
  ConsumerState<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends ConsumerState<Analytics> {
  int viewMode = 0; // 0 for Balance, 1 for Valuation (only for Bitcoin assets)
  String _selectedRange = '1M';
  String? _selectedAsset;

  // Asset options for the dropdown
  final List<String> _assetOptions = [
    'Bitcoin (Mainnet)',
    'Bitcoin (Liquid)',
    'Depix (Liquid)',
    'USDT (Liquid)',
    'EURx (Liquid)',
  ];

  final Map<String, String> _assetImages = {
    'Bitcoin (Mainnet)': 'lib/assets/bitcoin-logo.png',
    'Bitcoin (Liquid)': 'lib/assets/l-btc.png',
    'Depix (Liquid)': 'lib/assets/depix.png',
    'USDT (Liquid)': 'lib/assets/tether.png',
    'EURx (Liquid)': 'lib/assets/eurx.png',
  };

  final Map<String, String> _assetIdMap = {
    'Bitcoin (Liquid)': AssetMapper.reverseMapTicker(AssetId.LBTC),
    'Depix (Liquid)': AssetMapper.reverseMapTicker(AssetId.BRL),
    'USDT (Liquid)': AssetMapper.reverseMapTicker(AssetId.USD),
    'EURx (Liquid)': AssetMapper.reverseMapTicker(AssetId.EUR),
  };

  final Map<String, int> _assetPrecisionMap = {
    AssetMapper.reverseMapTicker(AssetId.LBTC): 8,
    AssetMapper.reverseMapTicker(AssetId.BRL): 2,
    AssetMapper.reverseMapTicker(AssetId.USD): 2,
    AssetMapper.reverseMapTicker(AssetId.EUR): 2,
  };

  @override
  void initState() {
    super.initState();
    _selectedAsset = ref.read(selectedAssetProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now().dateOnly();
      final start = now.subtract(const Duration(days: 29));
      ref.read(dateTimeSelectProvider.notifier).state = DateTimeSelect(
        start: start,
        end: now,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Builds the price percentage change ticker (only for Bitcoin assets) as a row with three columns
  Widget _buildPricePercentageChangeTicker(BuildContext context, WidgetRef ref, double percentageChange) {
    final format = ref.watch(settingsProvider).btcFormat;
    final currency = ref.watch(settingsProvider).currency;
    final currentPrice = ref.watch(selectedCurrencyProvider(currency)) * 1;
    final totalBalance = ref.watch(totalBalanceInDenominationProvider(format));

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
      margin: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp), // Consistent with BalanceCardWithDropdown
      padding: EdgeInsets.all(16.sp), // Matching padding with BalanceCardWithDropdown
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Column: Total Balance
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Balance'.i18n,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  totalBalance,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 4.sp), // Space between columns
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Variation'.i18n,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null)
                      Icon(
                        icon,
                        size: 16.sp,
                        color: textColor,
                      ),
                    SizedBox(width: icon != null ? 4.w : 0),
                    Text(
                      percentageChange > 0 ? '+$displayText' : displayText,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 4.sp), // Space between columns
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Price Today'.i18n,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '\$${currentPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
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
    final depixBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).brlBalance);
    final usdBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).usdBalance);
    final euroBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).eurBalance);
    final btcBalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).btcBalance, btcFormat);
    final liquidBalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidBalance, btcFormat);

    final selectedDays = ref.watch(selectedDaysDateArrayProvider);
    final isBitcoinAsset = _selectedAsset == 'Bitcoin (Mainnet)' || _selectedAsset == 'Bitcoin (Liquid)';

    final currentBalanceFormatted = switch (_selectedAsset) {
      'Bitcoin (Mainnet)' => btcBalance,
      'Bitcoin (Liquid)' => liquidBalance,
      'Depix (Liquid)' => depixBalance,
      'USDT (Liquid)' => usdBalance,
      'EURx (Liquid)' => euroBalance,
      _ => throw ArgumentError('Unsupported asset: $_selectedAsset'),
    };

    final balanceWithUnit = '$currentBalanceFormatted ${isBitcoinAsset ? btcFormat : _selectedAsset!.split(' ')[0]}';

    final balanceByDay = _selectedAsset == 'Bitcoin (Mainnet)'
        ? ref.watch(bitcoinBalanceOverPeriodByDayProvider)
        : ref.watch(liquidBalanceOverPeriodByDayProvider(_assetIdMap[_selectedAsset!]!));

    final balanceByDayNum = <DateTime, num>{};
    for (var entry in balanceByDay.entries) {
      final day = entry.key;
      final balance = entry.value;
      if (isBitcoinAsset) {
        balanceByDayNum[day] = btcInDenominationNum(balance, btcFormat);
      } else {
        final assetId = _assetIdMap[_selectedAsset!]!;
        final precision = _assetPrecisionMap[assetId] ?? 8;
        balanceByDayNum[day] = balance / pow(10, precision);
      }
    }

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
          if (balanceByDay.containsKey(normalizedDay)) {
            lastKnownBalance = balanceByDay[normalizedDay]! /
                (isBitcoinAsset ? 100000000 : pow(10, _assetPrecisionMap[_assetIdMap[_selectedAsset!]!] ?? 8));
          }
          if (dailyPrices.containsKey(normalizedDay)) {
            lastKnownPrice = dailyPrices[normalizedDay]!;
          }
          dailyDollarBalance[normalizedDay] = lastKnownBalance * (isBitcoinAsset ? lastKnownPrice : 1);
        }
        return (dailyDollarBalance, dailyPrices);
      },
      loading: () => (<DateTime, num>{}, <DateTime, num>{}),
      error: (_, __) => (<DateTime, num>{}, <DateTime, num>{}),
    );

    double percentageChange = 0;
    if (isBitcoinAsset && priceByDay.isNotEmpty) {
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

    final mainData = viewMode == 0 ? balanceByDayNum : dollarBalanceByDay;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            'Analytics',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          actions: [
            if (isBitcoinAsset) // Only show dropdown for Bitcoin assets
              Padding(
                padding: EdgeInsets.only(right: 8.sp),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    popupMenuTheme: PopupMenuThemeData(
                      color: const Color(0xFF212121),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  child: PopupMenuButton<int>(
                    icon: Icon(
                      Icons.arrow_drop_down_circle_outlined,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    onSelected: (int value) {
                      setState(() {
                        viewMode = value;
                      });
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<int>(
                        value: 0,
                        child: Text(
                          'Balance'.i18n,
                          style: TextStyle(
                            color: viewMode == 0 ? Colors.orangeAccent : Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      PopupMenuItem<int>(
                        value: 1,
                        child: Text(
                          'USD Valuation',
                          style: TextStyle(
                            color: viewMode == 1 ? Colors.orangeAccent : Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              BalanceCardWithDropdown(
                selectedAsset: _selectedAsset!,
                onAssetChanged: (newAsset) {
                  setState(() {
                    _selectedAsset = newAsset;
                    ref.read(selectedAssetProvider.notifier).state = newAsset;
                  });
                },
                balanceWithUnit: balanceWithUnit,
                assetOptions: _assetOptions,
                assetImages: _assetImages,
              ),
              Expanded(
                child: marketDataAsync.when(
                  data: (_) {
                    return Chart(
                      selectedDays: selectedDays,
                      isBitcoinAsset: isBitcoinAsset,
                      mainData: mainData,
                      bitcoinBalanceByDayUnformatted: balanceByDay,
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
                      size: 35,
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
                            'Please check your connection and try again.\n$error',
                            style: TextStyle(color: Colors.red.shade200, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            label: const Text('Retry', style: TextStyle(color: Colors.white)),
                            onPressed: () => ref.invalidate(bitcoinHistoricalMarketDataProvider),
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
                children: ['7D', '1M', '3M', '6M', '1Y', 'ALL'].map((range) {
                  return TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedRange = range;
                        final now = DateTime.now().dateOnly();
                        DateTime start;
                        if (range == 'ALL') {
                          final transactionState = ref.read(transactionNotifierProvider);
                          final earliestTimestamp = transactionState.earliestTimestamp;
                          if (earliestTimestamp != null) {
                            start = earliestTimestamp.dateOnly();
                          } else {
                            start = now.subtract(const Duration(days: 364 * 10));
                          }
                        } else {
                          switch (range) {
                            case '7D':
                              start = now.subtract(const Duration(days: 6));
                              break;
                            case '1M':
                              start = now.subtract(const Duration(days: 29));
                              break;
                            case '3M':
                              start = now.subtract(const Duration(days: 89));
                              break;
                            case '6M':
                              start = now.subtract(const Duration(days: 179));
                              break;
                            case '1Y':
                              start = now.subtract(const Duration(days: 364));
                              break;
                            default:
                              start = now.subtract(const Duration(days: 29));
                          }
                        }
                        ref.read(dateTimeSelectProvider.notifier).state = DateTimeSelect(
                          start: start,
                          end: now,
                        );
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
              if (isBitcoinAsset)
                marketDataAsync.when(
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
            ],
          ),
        ),
      ),
    );
  }
}