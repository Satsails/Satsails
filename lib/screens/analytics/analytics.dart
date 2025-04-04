import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/models/datetime_range_model.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/analytics/components/chart.dart';
import 'package:Satsails/screens/shared/balance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:i18n_extension/default.i18n.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';

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

  // Precision map for Liquid assets (assuming standard precisions)
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
    ref.read(selectedAssetProvider.notifier).state = 'Bitcoin (Mainnet)';
    super.dispose();
  }

  /// Builds the dropdown for selecting assets
  Widget _buildAssetDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      child: DropdownButton<String>(
        value: _selectedAsset,
        items: _assetOptions.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Row(
              children: [
                Image.asset(
                  _assetImages[option]!,
                  width: 35.sp,
                  height: 35.sp,
                ),
                SizedBox(width: 10.sp),
                Text(
                  option,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedAsset = newValue;
              ref.read(selectedAssetProvider.notifier).state = newValue;
            });
          }
        },
        dropdownColor: const Color(0xFF212121),
        style: TextStyle(color: Colors.white, fontSize: 14.sp),
        padding: EdgeInsets.zero,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white, size: 24.sp),
        underline: const SizedBox(),
      ),
    );
  }

  /// Builds view mode selection buttons (only for Bitcoin assets)
  Widget _buildViewModeButtons(String selectedCurrency, bool isBitcoinAsset) {
    if (!isBitcoinAsset) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => setState(() => viewMode = 0),
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF212121),
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
          onPressed: () => setState(() => viewMode = 1),
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF212121),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          ),
          child: Text(
            'USD Valuation',
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

  /// Builds the price percentage change ticker (only for Bitcoin assets)
  Widget _buildPricePercentageChangeTicker(BuildContext context, WidgetRef ref, double percentageChange) {
    final format = ref.watch(settingsProvider).btcFormat;
    final currency = ref.watch(settingsProvider).currency;
    final currentPrice = ref.watch(selectedCurrencyProvider(currency)) * 1;
    final totalBalance =  ref.watch(totalBalanceInDenominationProvider(format));

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
      child: Column(
    children: [        Text(
      'Total balance: $totalBalance'.i18n,
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
        SizedBox(height: 6.h),
        Row(
          mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Price today: \$${currentPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
        ],
      ),
      ]),
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
    final lightningBalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).lightningBalance ?? 0, btcFormat);

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

    // Fetch balance data from providers
    final balanceByDay = _selectedAsset == 'Bitcoin (Mainnet)'
        ? ref.watch(bitcoinBalanceOverPeriodByDayProvider)
        : ref.watch(liquidBalanceOverPeriodByDayProvider(_assetIdMap[_selectedAsset!]!));

    // Compute balance in display units
    final balanceByDayNum = <DateTime, num>{};
    for (var entry in balanceByDay.entries) {
      final day = entry.key;
      final balance = entry.value;
      if (isBitcoinAsset) {
        balanceByDayNum[day] = btcInDenominationNum(balance, btcFormat);
      } else {
        final assetId = _assetIdMap[_selectedAsset!]!;
        final precision = _assetPrecisionMap[assetId] ?? 8; // Default to 8 if not found
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
            lastKnownBalance = balanceByDay[normalizedDay]! / (isBitcoinAsset ? 100000000 : pow(10, _assetPrecisionMap[_assetIdMap[_selectedAsset!]!] ?? 8));
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

    // Calculate percentage change for Bitcoin assets
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

    return Scaffold(
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
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildAssetDropdown(),
            Text(
              '$currentBalanceFormatted ${isBitcoinAsset ? btcFormat : _selectedAsset!.split(' ')[0]}',
              style: TextStyle(
                fontSize: 24.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
              child: _buildViewModeButtons(selectedCurrency, isBitcoinAsset),
            ),
            Expanded(
              child: marketDataAsync.when(
                data: (_) {
                  return Chart(
                    selectedDays: selectedDays,
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
                        case 'ALL':
                          start = now.subtract(const Duration(days: 364 * 10)); // Adjust as needed
                          break;
                        default:
                          start = now.subtract(const Duration(days: 29));
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