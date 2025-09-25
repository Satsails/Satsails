import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/models/datetime_range_model.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:Satsails/screens/analytics/components/bitcoin_price_chart.dart';
import 'package:Satsails/screens/analytics/components/chart.dart';
import 'package:Satsails/screens/analytics/components/pie_chart.dart';
import 'package:Satsails/translations/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum ChartType { balance, valuation, allocation, price }
enum AnalyticsSection { internal, market }

class Analytics extends ConsumerStatefulWidget {
  const Analytics({super.key});

  @override
  ConsumerState<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends ConsumerState<Analytics> {
  AnalyticsSection _selectedSection = AnalyticsSection.internal;
  ChartType _selectedChartType = ChartType.balance;
  String _selectedRange = '1M';
  String _selectedAsset = 'Bitcoin';

  final List<String> _assetOptions = ['Bitcoin', 'Liquid Bitcoin', 'Depix', 'USDT', 'EURx'];
  final Map<String, String> _assetImages = {
    'Bitcoin': 'lib/assets/bitcoin-logo.png',
    'Liquid Bitcoin': 'lib/assets/l-btc.png',
    'Depix': 'lib/assets/depix.png',
    'USDT': 'lib/assets/tether.png',
    'EURx': 'lib/assets/eurx.png',
  };
  final Map<String, String> _assetIdMap = {
    'Bitcoin': 'btc',
    'Liquid Bitcoin': AssetMapper.reverseMapTicker(AssetId.LBTC),
    'Depix': AssetMapper.reverseMapTicker(AssetId.BRL),
    'USDT': AssetMapper.reverseMapTicker(AssetId.USD),
    'EURx': AssetMapper.reverseMapTicker(AssetId.EUR),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDateRangeProvider(_selectedRange);
    });
  }

  void _updateDateRangeProvider(String range) {
    final now = DateTime.now().dateOnly();
    DateTime start;
    switch (range) {
      case '7D': start = now.subtract(const Duration(days: 6)); break;
      case '1M': start = now.subtract(const Duration(days: 29)); break;
      case '3M': start = now.subtract(const Duration(days: 89)); break;
      case '1Y': start = now.subtract(const Duration(days: 364)); break;
      case 'ALL':
        final ts = ref.read(transactionNotifierProvider).earliestTimestamp;
        start = ts?.dateOnly() ?? now.subtract(const Duration(days: 364 * 5));
        break;
      default: start = now.subtract(const Duration(days: 29));
    }
    ref.read(dateTimeSelectProvider.notifier).state = DateTimeSelect(start: start, end: now);
  }

  String _getFormattedBalanceForHeader(String asset, WalletBalance balance, String btcFormat) {
    final isBitcoinAsset = ['Bitcoin', 'Liquid Bitcoin'].contains(asset);
    final value = switch (asset) {
      'Bitcoin' => btcInDenominationFormatted(balance.onChainBtcBalance, btcFormat),
      'Liquid Bitcoin' => btcInDenominationFormatted(balance.liquidBtcBalance, btcFormat),
      'Depix' => fiatInDenominationFormatted(balance.liquidDepixBalance),
      'USDT' => fiatInDenominationFormatted(balance.liquidUsdtBalance),
      'EURx' => fiatInDenominationFormatted(balance.liquidEuroxBalance),
      _ => '',
    };
    return isBitcoinAsset ? '$value ${btcFormat.toUpperCase()}' : value;
  }

  void _showAssetSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              builder: (BuildContext context, ScrollController scrollController) {
                return Column(
                  children: [
                    SizedBox(height: 12.h),
                    Container(
                      width: 40.w,
                      height: 5.h,
                      decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(12.r)),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Select Asset'.i18n,
                      style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _assetOptions.length,
                        itemBuilder: (context, index) {
                          final option = _assetOptions[index];
                          final isSelected = _selectedAsset == option;

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              final bool newIsBitcoin = ['Bitcoin', 'Liquid Bitcoin'].contains(option);
                              setState(() {
                                _selectedAsset = option;
                                if (!newIsBitcoin && (_selectedChartType == ChartType.valuation || _selectedChartType == ChartType.price)) {
                                  _selectedChartType = ChartType.balance;
                                }
                              });
                              Navigator.pop(context);
                            },
                            // MODIFIED: Replaced AnimatedContainer with a standard Container
                            child: Container(
                              height: 72.h,
                              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF333333) : const Color(0xFF2C2C2E),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(_assetImages[option]!, width: 36.sp, height: 36.sp),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: false,
          title: Text('Analytics'.i18n, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22.sp)),
          backgroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          bottom: true,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Column(
              children: [
                _buildSectionPicker(),
                SizedBox(height: 24.h),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _selectedSection == AnalyticsSection.internal
                        ? _buildInternalAnalyticsView(key: ValueKey(_selectedAsset))
                        : _MarketDataView(key: const ValueKey('market')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionPicker() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        children: [
          _buildPickerOption(AnalyticsSection.internal, 'Internal Analytics'),
          _buildPickerOption(AnalyticsSection.market, 'Market Data'),
        ],
      ),
    );
  }

  Widget _buildPickerOption(AnalyticsSection section, String text) {
    final bool isSelected = _selectedSection == section;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSection = section),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(color: isSelected ? Colors.black.withOpacity(0.5) : Colors.transparent, borderRadius: BorderRadius.circular(10.r)),
          child: Center(child: Text(text.i18n, style: TextStyle(fontSize: 14.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: Colors.white))),
        ),
      ),
    );
  }

  Widget _buildInternalAnalyticsView({Key? key}) {
    final settings = ref.watch(settingsProvider);
    final btcFormat = settings.btcFormat;
    final isBitcoinAsset = ['Bitcoin', 'Liquid Bitcoin'].contains(_selectedAsset);
    final cardColor = const Color(0xFF333333).withOpacity(0.4);

    final balance = ref.watch(balanceNotifierProvider);
    final balanceWithUnit = _getFormattedBalanceForHeader(_selectedAsset, balance, btcFormat);

    final marketDataAsync = ref.watch(filteredBitcoinMarketDataProvider);
    final allocation = ref.watch(assetAllocationProvider);
    final selectedDays = ref.watch(selectedDaysDateArrayProvider);

    return Column(
      key: key,
      children: [
        _buildHeaderCard(balanceWithUnit, cardColor),
        SizedBox(height: 24.h),
        Expanded(
          child: _buildChartContainer(
            cardColor: cardColor,
            isBitcoinAsset: isBitcoinAsset,
            chartView: marketDataAsync.when(
              loading: () => _buildChartShimmer(),
              error: (e, s) => Center(child: Text("Error loading chart data".i18n)),
              data: (marketData) {
                final dailyPrices = { for (var dp in marketData) dp.date.toLocal().dateOnly(): dp.price ?? 0 };
                final balanceByDay = _selectedAsset == 'Bitcoin'
                    ? ref.watch(bitcoinBalanceInFormatByDayProvider)
                    : ref.watch(liquidBalancePerDayInFormatProvider(_assetIdMap[_selectedAsset]!));

                final dailyDollarBalance = <DateTime, num>{};

                num lastKnownBalance = 0;
                num lastKnownPrice = 0;

                if (selectedDays.isNotEmpty) {
                  final startDate = selectedDays.first.dateOnly();
                  final sortedBalanceKeys = balanceByDay.keys.toList()..sort();

                  for (final day in sortedBalanceKeys) {
                    if (day.isBefore(startDate)) {
                      lastKnownBalance = balanceByDay[day]!;
                    } else {
                      break;
                    }
                  }

                  final sortedPriceKeys = dailyPrices.keys.toList()..sort();
                  for (final day in sortedPriceKeys) {
                    if (day.isBefore(startDate)) {
                      lastKnownPrice = dailyPrices[day]!;
                    } else {
                      break;
                    }
                  }
                }

                for (var day in selectedDays) {
                  final normalizedDay = day.dateOnly();
                  if (balanceByDay.containsKey(normalizedDay)) {
                    lastKnownBalance = balanceByDay[normalizedDay]! / (isBitcoinAsset && btcFormat == 'sats' ? 1e8 : 1);
                  }
                  if (dailyPrices.containsKey(normalizedDay)) {
                    lastKnownPrice = dailyPrices[normalizedDay]!;
                  }
                  dailyDollarBalance[normalizedDay] = lastKnownBalance * (isBitcoinAsset ? lastKnownPrice : 1);
                }

                return switch (_selectedChartType) {
                  ChartType.allocation => allocation.when(
                    data: (data) => AssetAllocationChart(allocationData: <String, ({double fiatValue, int originalBalance})>{
                      'BTC': (fiatValue: data['BTC'] ?? 0.0, originalBalance: balance.onChainBtcBalance),
                      'L-BTC': (fiatValue: data['L-BTC'] ?? 0.0, originalBalance: balance.liquidBtcBalance),
                      'Depix': (fiatValue: data['Depix'] ?? 0.0, originalBalance: balance.liquidDepixBalance),
                      'USDT': (fiatValue: data['USDT'] ?? 0.0, originalBalance: balance.liquidUsdtBalance),
                      'EURx': (fiatValue: data['EURx'] ?? 0.0, originalBalance: balance.liquidEuroxBalance),
                    }),
                    loading: () => _buildChartShimmer(),
                    error: (e,s) => Center(child: Text("Error".i18n)),
                  ),
                  ChartType.price => BitcoinPriceChart(selectedAsset: _assetIdMap[_selectedAsset]!,),
                  _ => Chart(
                    selectedDays: selectedDays,
                    mainData: _selectedChartType == ChartType.balance ? balanceByDay : dailyDollarBalance,
                    bitcoinBalanceByDayformatted: balanceByDay,
                    dollarBalanceByDay: dailyDollarBalance,
                    priceByDay: dailyPrices,
                    selectedCurrency: settings.currency,
                    isShowingMainData: true,
                    isCurrency: _selectedChartType == ChartType.valuation,
                    btcFormat: btcFormat,
                    isBitcoinAsset: isBitcoinAsset,
                    selectedAsset: _selectedAsset,
                  ),
                };
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(String balanceWithUnit, Color cardColor) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); _showAssetSelection(); },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16.r)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Image.asset(_assetImages[_selectedAsset]!, width: 24.sp, height: 24.sp),
            SizedBox(width: 8.w),
            Text(_selectedAsset, style: TextStyle(fontSize: 16.sp, color: Colors.white70, fontWeight: FontWeight.bold)),
            SizedBox(width: 4.w),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 20),
          ]),
          SizedBox(height: 12.h),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(balanceWithUnit, style: TextStyle(fontSize: 34.sp, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -0.5), maxLines: 1)),
        ]),
      ),
    );
  }

  Widget _buildChartContainer({required Widget chartView, required bool isBitcoinAsset, required Color cardColor}) {
    return Container(
      padding: EdgeInsets.fromLTRB(8.w, 16.h, 8.w, 8.h),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16.r)),
      child: Column(children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: _ChartTypeSelector(
            isBitcoinAsset: isBitcoinAsset,
            selectedType: _selectedChartType,
            onSelected: (type) {
              setState(() => _selectedChartType = type);
            },
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(child: chartView),
        SizedBox(height: 16.h),
        if (_selectedChartType != ChartType.allocation)
          _DateRangeSelector(
            selectedRange: _selectedRange,
            onSelected: (range) {
              setState(() => _selectedRange = range);
              _updateDateRangeProvider(range);
            },
          ),
      ]),
    );
  }
}

class _MarketDataView extends ConsumerStatefulWidget {
  const _MarketDataView({Key? key}) : super(key: key);
  @override
  ConsumerState<_MarketDataView> createState() => _MarketDataViewState();
}

class _MarketDataViewState extends ConsumerState<_MarketDataView> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  String _currentTitle = 'Dashboards';

  late final Map<String, String> _links;

  @override
  void initState() {
    super.initState();
    final language = ref.read(settingsProvider).language;
    _links = _getLinks(language);

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(_links[_currentTitle]!));
  }

  Map<String, String> _getLinks(String language) => {
    'Dashboards': language == 'pt' ? 'https://bitcoincounterflow.com/pt/satsails-2/mini-paineis-iframe/' : 'https://bitcoincounterflow.com/satsails/dashboards-iframe',
    'ETF Tracker': language == 'pt' ? 'https://bitcoincounterflow.com/pt/satsails-2/etf-tracker-btc-iframe' : 'https://bitcoincounterflow.com/satsails/etf-tracker-iframe',
    'Retirement Calculator': language == 'pt' ? 'https://bitcoincounterflow.com/pt/satsails-2/calculadora-de-aposentadoria-bitcoin-iframe/' : 'https://bitcoincounterflow.com/satsails/bitcoin-retirement-calculator-iframe/',
    'Bitcoin Converter': language == 'pt' ? 'https://bitcoincounterflow.com/pt/satsails-2/calculadora-conversora-bitcoin-iframe/' : 'https://bitcoincounterflow.com/satsails/bitcoin-converter-calculator-iframe/',
    'DCA Calculator': language == 'pt' ? 'https://bitcoincounterflow.com/pt/satsails-2/calculadora-dca-iframe/' : 'https://bitcoincounterflow.com/satsails/dca-calculator-iframe/',
    'Bitcoin Counterflow Strategy': language == 'pt' ? 'https://bitcoincounterflow.com/pt/satsails-2/estrategia-counterflow-iframe/' : 'https://bitcoincounterflow.com/satsails/bitcoin-counterflow-strategy-iframe/',
    'Charts': language == 'pt' ? 'https://bitcoincounterflow.com/pt/satsails-2/graficos-bitcoin-iframe/' : 'https://bitcoincounterflow.com/satsails/charts-iframe',
    'Liquidation Zone': language == 'pt' ? 'https://bitcoincounterflow.com/pt/satsails-2/zona-de-liquidacao-iframe/' : 'https://bitcoincounterflow.com/satsails/liquidation-heatmap-iframe/',
  };

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Dashboards': return Icons.dashboard;
      case 'ETF Tracker': return Icons.assessment;
      case 'Retirement Calculator': return Icons.calculate;
      case 'Bitcoin Converter': return Icons.attach_money;
      case 'DCA Calculator': return Icons.history;
      case 'Bitcoin Counterflow Strategy': return Icons.trending_up;
      case 'Charts': return Icons.show_chart;
      case 'Liquidation Zone': return Icons.waterfall_chart;
      default: return Icons.link;
    }
  }

  void _showChartSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) {
        final linkItems = _links.entries.toList();
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (BuildContext context, ScrollController scrollController) {
            return Column(
              children: [
                SizedBox(height: 12.h),
                Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(12.r)),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Select View'.i18n,
                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: linkItems.length,
                    itemBuilder: (context, index) {
                      final item = linkItems[index];
                      final isSelected = _currentTitle == item.key;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _currentTitle = item.key;
                            _webViewController.loadRequest(Uri.parse(item.value));
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 72.h,
                          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF333333) : const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(_getIconForTitle(item.key), color: Colors.white, size: 28.sp),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Text(
                                  item.key.i18n,
                                  style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Widget _buildWebViewShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      child: Container(color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _showChartSelection,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(12.r)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(_currentTitle.i18n, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500)),
              const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
            ]),
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_isLoading) _buildWebViewShimmer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChartTypeSelector extends ConsumerWidget {
  final bool isBitcoinAsset;
  final ChartType selectedType;
  final Function(ChartType) onSelected;

  const _ChartTypeSelector({
    required this.isBitcoinAsset,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<ChartType, String> options = {
      ChartType.balance: 'Balance'.i18n,
      if (isBitcoinAsset) ChartType.valuation: 'Valuation'.i18n,
      if (isBitcoinAsset) ChartType.price: 'Price'.i18n,
      ChartType.allocation: 'Allocation'.i18n,
    };

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), borderRadius: BorderRadius.circular(10.r)),
      child: Row(
        children: options.entries.map((entry) {
          final isSelected = selectedType == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.grey.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  final String selectedRange;
  final Function(String) onSelected;
  static const ranges = ['7D', '1M', '3M', '1Y', 'ALL'];
  const _DateRangeSelector({required this.selectedRange, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: ranges.map((range) {
          final isSelected = selectedRange == range;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onSelected(range);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.grey.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    range.i18n,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}