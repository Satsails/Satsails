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
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';

class Analytics extends ConsumerStatefulWidget {
  const Analytics({super.key});

  @override
  ConsumerState<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends ConsumerState<Analytics> {
  int viewMode = 0;
  String _selectedRange = '1M';
  String? _selectedAsset;

  // Asset definitions remain the same
  final List<String> _assetOptions = ['Bitcoin (Mainnet)', 'Liquid Bitcoin', 'Depix', 'USDT', 'EURx'];
  final Map<String, String> _assetImages = {
    'Bitcoin (Mainnet)': 'lib/assets/bitcoin-logo.png',
    'Lightning Bitcoin': 'lib/assets/Bitcoin_lightning_logo.png',
    'Liquid Bitcoin': 'lib/assets/l-btc.png',
    'Depix': 'lib/assets/depix.png',
    'USDT': 'lib/assets/tether.png',
    'EURx': 'lib/assets/eurx.png',
  };
  final Map<String, String> _assetIdMap = {
    'Liquid Bitcoin': AssetMapper.reverseMapTicker(AssetId.LBTC),
    'Depix': AssetMapper.reverseMapTicker(AssetId.BRL),
    'USDT': AssetMapper.reverseMapTicker(AssetId.USD),
    'EURx': AssetMapper.reverseMapTicker(AssetId.EUR),
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateDateRange(_selectedRange));
  }

  void _updateDateRange(String range) {
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
      case '1Y':
        start = now.subtract(const Duration(days: 364));
        break;
      case 'ALL':
        final ts = ref.read(transactionNotifierProvider).value?.earliestTimestamp;
        start = ts?.dateOnly() ?? now.subtract(const Duration(days: 364 * 5));
        break;
      default:
        start = now.subtract(const Duration(days: 29));
    }
    ref.read(dateTimeSelectProvider.notifier).state = DateTimeSelect(start: start, end: now);
  }

  void _showAssetMenu(BuildContext context, GlobalKey key) async {
    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy + renderBox.size.height, overlay.size.width - position.dx - renderBox.size.width, overlay.size.height - position.dy),
      items: _assetOptions.map((option) => PopupMenuItem<String>(
        value: option,
        child: Row(children: [
          Image.asset(_assetImages[option]!, width: 32.sp, height: 32.sp),
          SizedBox(width: 12.w),
          Text(option, style: TextStyle(color: option == _selectedAsset ? Colors.orangeAccent : Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500)),
        ]),
      )).toList(),
      color: const Color(0xFF2C2C2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    );

    if (selected != null) {
      setState(() {
        _selectedAsset = selected;
        ref.read(selectedAssetProvider.notifier).state = selected;
        viewMode = 0;
      });
    }
  }

  Widget _buildHeaderCard(String balanceWithUnit, Color cardColor) {
    final cardKey = GlobalKey();
    return GestureDetector(
      key: cardKey,
      onTap: () { HapticFeedback.lightImpact(); _showAssetMenu(context, cardKey); },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16.r)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Image.asset(_assetImages[_selectedAsset!]!, width: 24.sp, height: 24.sp),
            SizedBox(width: 8.w),
            Text(_selectedAsset!, style: TextStyle(fontSize: 16.sp, color: Colors.white70, fontWeight: FontWeight.w500)),
            SizedBox(width: 4.w),
            Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 20.sp),
          ]),
          SizedBox(height: 12.h),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(balanceWithUnit, style: TextStyle(fontSize: 34.sp, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -0.5), maxLines: 1)),
        ]),
      ),
    );
  }

  Widget _buildChartContainer({required Widget chartView, required bool isBitcoinAsset, required Color cardColor}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16.r)),
      child: Column(children: [
        if (isBitcoinAsset)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _ViewModeSelector(selectedIndex: viewMode, onSelected: (index) => setState(() => viewMode = index)),
          ),
        if (isBitcoinAsset) SizedBox(height: 16.h),
        // This Expanded widget is key to making the chart fill available space.
        Expanded(child: chartView),
        SizedBox(height: 16.h),
        Divider(color: Colors.grey.shade800, height: 1.h),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _DateRangeSelector(selectedRange: _selectedRange, onSelected: (range) { setState(() => _selectedRange = range); _updateDateRange(range); }),
        ),
      ]),
    );
  }

  Widget _buildPriceTicker(double percentageChange, Color cardColor) {
    final settings = ref.watch(settingsProvider);
    final currency = settings.currency;
    final currentPrice = ref.watch(selectedCurrencyProvider(currency));
    final isPositive = percentageChange > 0;
    final isZero = percentageChange.abs() < 0.01;
    final Color changeColor = isZero ? Colors.white70 : (isPositive ? Colors.greenAccent.shade400 : Colors.redAccent.shade400);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16.r)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _TickerItem(label: 'Price ($currency)', value: currentPrice.toStringAsFixed(2)),
        _TickerItem(label: 'Change ($_selectedRange)', value: '${isPositive && !isZero ? '+' : ''}${percentageChange.toStringAsFixed(2)}%', valueColor: changeColor),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final selectedCurrency = settings.currency;
    final btcFormat = settings.btcFormat;
    final depixBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidDepixBalance);
    final liquidUsdtBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidUsdtBalance);
    final euroBalance = fiatInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidEuroxBalance);
    final onChainBtcBalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).onChainBtcBalance, btcFormat);
    final liquidBtcBalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).liquidBtcBalance, btcFormat);
    final sparkBitcoinbalance = btcInDenominationFormatted(ref.watch(balanceNotifierProvider).sparkBitcoinbalance ?? 0, btcFormat);
    final selectedDays = ref.watch(selectedDaysDateArrayProvider);

    final isBitcoinAsset = ['Bitcoin (Mainnet)', 'Lightning Bitcoin', 'Liquid Bitcoin'].contains(_selectedAsset);

    final balanceByDay = switch (_selectedAsset) {
      'Bitcoin (Mainnet)' || 'Lightning Bitcoin' => ref.watch(bitcoinBalanceInFormatByDayProvider),
      'Liquid Bitcoin' || 'Depix' || 'USDT' || 'EURx' => ref.watch(liquidBalancePerDayInFormatProvider(_assetIdMap[_selectedAsset!]!)),
      _ => <DateTime, num>{},
    };

    final marketDataAsync = ref.watch(bitcoinMarketDataProvider);
    final (dollarBalanceByDay, priceByDay) = marketDataAsync.when(
      data: (marketData) {
        final dailyPrices = { for (var dp in marketData) dp.date.toLocal().dateOnly(): dp.price ?? 0 };
        final dailyDollarBalance = <DateTime, num>{};
        num lastKnownBalance = 0, lastKnownPrice = 0;
        for (var day in selectedDays) {
          final normalizedDay = day.dateOnly();
          if (balanceByDay.containsKey(normalizedDay)) {
            lastKnownBalance = balanceByDay[normalizedDay]! / (isBitcoinAsset && btcFormat == 'sats' ? 1e8 : (isBitcoinAsset ? 1 : pow(10, _assetPrecisionMap[_assetIdMap[_selectedAsset!]!] ?? 8)));
          }
          if (dailyPrices.containsKey(normalizedDay)) { lastKnownPrice = dailyPrices[normalizedDay]!; }
          dailyDollarBalance[normalizedDay] = lastKnownBalance * (isBitcoinAsset ? lastKnownPrice : 1);
        }
        return (dailyDollarBalance, dailyPrices);
      },
      loading: () => (<DateTime, num>{}, <DateTime, num>{}),
      error: (_, __) => (<DateTime, num>{}, <DateTime, num>{}),
    );

    double percentageChange = 0;
    if (isBitcoinAsset && priceByDay.isNotEmpty && selectedDays.isNotEmpty) {
      final firstDay = selectedDays.firstWhere((d) => priceByDay[d] != null, orElse: () => selectedDays.first);
      final lastDay = selectedDays.lastWhere((d) => priceByDay[d] != null, orElse: () => selectedDays.last);
      final startPrice = priceByDay[firstDay] ?? 0;
      final endPrice = priceByDay[lastDay] ?? 0;
      if (startPrice != 0) { percentageChange = ((endPrice - startPrice) / startPrice * 100); }
    }

    final mainData = viewMode == 0 ? balanceByDay : dollarBalanceByDay;
    final currentBalanceFormatted = switch (_selectedAsset) {
      'Bitcoin (Mainnet)' => onChainBtcBalance, 'Lightning Bitcoin' => sparkBitcoinbalance, 'Liquid Bitcoin' => liquidBtcBalance,
      'Depix' => depixBalance, 'USDT' => liquidUsdtBalance, 'EURx' => euroBalance, _ => '',
    };
    final balanceWithUnit = isBitcoinAsset ? '$currentBalanceFormatted ${btcFormat.toUpperCase()}' : currentBalanceFormatted;

    // The new card color, defined once. Note: 0x00 is fully transparent, so using 0xFF for solid color before opacity.
    final cardColor = const Color(0xFF333333).withOpacity(0.4);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: false,
        title: Text('Analytics'.i18n, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22.sp)),
        backgroundColor: Colors.black, elevation: 0,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white)),
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
          child: Column(
            children: [
              _buildHeaderCard(balanceWithUnit, cardColor),
              SizedBox(height: 24.h),
              Expanded(
                child: _buildChartContainer(
                  cardColor: cardColor,
                  isBitcoinAsset: isBitcoinAsset,
                  chartView: marketDataAsync.when(
                    data: (_) => Chart(
                      selectedDays: selectedDays, mainData: mainData, bitcoinBalanceByDayformatted: balanceByDay,
                      dollarBalanceByDay: dollarBalanceByDay, priceByDay: priceByDay, selectedCurrency: selectedCurrency,
                      isShowingMainData: true, isCurrency: viewMode == 1, btcFormat: btcFormat, isBitcoinAsset: isBitcoinAsset,
                    ),
                    loading: () => Center(child: LoadingAnimationWidget.fourRotatingDots(color: Colors.orangeAccent, size: 40)),
                    error: (e, s) => Center(child: Text('Error Loading Chart'.i18n, style: const TextStyle(color: Colors.redAccent))),
                  ),
                ),
              ),
              if (isBitcoinAsset) ...[
                SizedBox(height: 24.h),
                _buildPriceTicker(percentageChange, cardColor),
              ],
              SizedBox(height: 24.h), // Padding at the bottom
            ],
          ),
        ),
      ),
    );
  }
}

// Internal widgets for cleaner build method (unchanged)
class _ViewModeSelector extends ConsumerWidget {
  final int selectedIndex; final Function(int) onSelected;
  const _ViewModeSelector({required this.selectedIndex, required this.onSelected});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(settingsProvider).currency;
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(12.r)),
      child: Row(children: [
        _buildSegment(context, 0, 'Balance', selectedIndex == 0),
        _buildSegment(context, 1, '$currency Valuation', selectedIndex == 1),
      ]),
    );
  }
  Widget _buildSegment(BuildContext context, int index, String text, bool isSelected) => Expanded(
    child: GestureDetector(
      onTap: () => onSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(color: isSelected ? Colors.grey.shade700 : Colors.transparent, borderRadius: BorderRadius.circular(12.r)),
        child: Center(child: Text(text.i18n, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.sp))),
      ),
    ),
  );
}

class _DateRangeSelector extends StatelessWidget {
  final String selectedRange; final Function(String) onSelected;
  static const ranges = ['7D', '1M', '3M', '1Y', 'ALL'];
  const _DateRangeSelector({required this.selectedRange, required this.onSelected});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: ranges.map((range) => GestureDetector(
      onTap: () => onSelected(range),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: selectedRange == range ? Colors.orangeAccent : Colors.grey.shade500),
        child: Text(range.i18n),
      ),
    )).toList(),
  );
}

class _TickerItem extends StatelessWidget {
  final String label; final String value; final Color? valueColor;
  const _TickerItem({required this.label, required this.value, this.valueColor});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(fontSize: 14.sp, color: Colors.white70, fontWeight: FontWeight.w500)),
    SizedBox(height: 6.h),
    Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: valueColor ?? Colors.white)),
  ]);
}