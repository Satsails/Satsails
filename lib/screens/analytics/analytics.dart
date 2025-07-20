import 'package:Satsails/helpers/asset_mapper.dart';
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
import 'package:webview_flutter/webview_flutter.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:Satsails/models/datetime_range_model.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/helpers/fiat_format_converter.dart';
import 'package:Satsails/helpers/bitcoin_formart_converter.dart';


enum AnalyticsSection { internal, market }

class Analytics extends ConsumerStatefulWidget {
  const Analytics({super.key});

  @override
  ConsumerState<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends ConsumerState<Analytics> {
  AnalyticsSection _selectedSection = AnalyticsSection.internal;
  int viewMode = 0;
  String _selectedRange = '1M';
  String? _selectedAsset;

  // --- Asset Maps from original Analytics ---
  final List<String> _assetOptions = ['Bitcoin (Mainnet)', 'Liquid Bitcoin', 'Depix', 'USDT', 'EURx'];
  final Map<String, String> _assetImages = {
    'Bitcoin (Mainnet)': 'lib/assets/bitcoin-logo.png',
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

  // --- Methods from original Analytics ---
  void _updateDateRange(String range) {
    final now = DateTime.now().dateOnly();
    DateTime start;
    switch (range) {
      case '7D': start = now.subtract(const Duration(days: 6)); break;
      case '1M': start = now.subtract(const Duration(days: 29)); break;
      case '3M': start = now.subtract(const Duration(days: 89)); break;
      case '1Y': start = now.subtract(const Duration(days: 364)); break;
      case 'ALL':
        final ts = ref.read(transactionNotifierProvider).value?.earliestTimestamp;
        start = ts?.dateOnly() ?? now.subtract(const Duration(days: 364 * 5));
        break;
      default: start = now.subtract(const Duration(days: 29));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: false,
        title: Text('Analytics'.i18n, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22.sp)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white)),
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
                child: _selectedSection == AnalyticsSection.internal
                    ? _buildInternalAnalyticsView()
                    : const _MarketDataView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NEW Top Level Picker ---
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

  // --- WIDGET BUILDERS for Internal Analytics ---
  Widget _buildInternalAnalyticsView() {
    final settings = ref.watch(settingsProvider);
    final selectedCurrency = settings.currency;
    final btcFormat = settings.btcFormat;
    final selectedDays = ref.watch(selectedDaysDateArrayProvider);
    final isBitcoinAsset = ['Bitcoin (Mainnet)', 'Liquid Bitcoin'].contains(_selectedAsset);
    final cardColor = const Color(0xFF333333).withOpacity(0.4);

    // Data fetching and processing...
    final balanceByDay = switch (_selectedAsset) {
      'Bitcoin (Mainnet)' => ref.watch(bitcoinBalanceInFormatByDayProvider),
      'Liquid Bitcoin' || 'Depix' || 'USDT' || 'EURx' => ref.watch(liquidBalancePerDayInFormatProvider(_assetIdMap[_selectedAsset!]!)),
      _ => <DateTime, num>{},
    };

    // CORRECTED: Calling the provider without a parameter.
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

    // Current Balance calculation
    final balance = ref.read(balanceNotifierProvider);
    final currentBalanceFormatted = switch (_selectedAsset) {
      'Bitcoin (Mainnet)' => btcInDenominationFormatted(balance.onChainBtcBalance, btcFormat),
      'Liquid Bitcoin' => btcInDenominationFormatted(balance.liquidBtcBalance, btcFormat),
      'Depix' => fiatInDenominationFormatted(balance.liquidDepixBalance),
      'USDT' => fiatInDenominationFormatted(balance.liquidUsdtBalance),
      'EURx' => fiatInDenominationFormatted(balance.liquidEuroxBalance),
      _ => '',
    };
    final balanceWithUnit = isBitcoinAsset ? '$currentBalanceFormatted ${btcFormat.toUpperCase()}' : currentBalanceFormatted;

    return Column(
      children: [
        _buildHeaderCard(balanceWithUnit, cardColor),
        SizedBox(height: 24.h),
        Expanded(
          child: _buildChartContainer(
            cardColor: cardColor,
            isBitcoinAsset: isBitcoinAsset,
            chartView: marketDataAsync.when(
              data: (_) => Chart(
                selectedDays: selectedDays, mainData: (viewMode == 0 ? balanceByDay : dollarBalanceByDay), bitcoinBalanceByDayformatted: balanceByDay,
                dollarBalanceByDay: dollarBalanceByDay, priceByDay: priceByDay, selectedCurrency: selectedCurrency,
                isShowingMainData: true, isCurrency: viewMode == 1, btcFormat: btcFormat, isBitcoinAsset: isBitcoinAsset,
              ),
              loading: () => Center(child: LoadingAnimationWidget.fourRotatingDots(color: Colors.orangeAccent, size: 40)),
              error: (e, s) => Center(child: Text('Error Loading Chart'.i18n, style: const TextStyle(color: Colors.redAccent))),
            ),
          ),
        ),
      ],
    );
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
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16.r)),
      child: Column(children: [
        if (isBitcoinAsset) Padding(padding: EdgeInsets.symmetric(horizontal: 16.w), child: _ViewModeSelector(selectedIndex: viewMode, onSelected: (index) => setState(() => viewMode = index))),
        if (isBitcoinAsset) SizedBox(height: 16.h),
        Expanded(child: chartView),
        SizedBox(height: 16.h),
        const Divider(color: Colors.grey, thickness: 0.2),
        SizedBox(height: 16.h),
        Padding(padding: EdgeInsets.symmetric(horizontal: 16.w), child: _DateRangeSelector(selectedRange: _selectedRange, onSelected: (range) { setState(() => _selectedRange = range); _updateDateRange(range); })),
      ]),
    );
  }
}

// --- NEW WIDGET for Market Data (adapted from Services) ---
class _MarketDataView extends ConsumerStatefulWidget {
  const _MarketDataView();
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
      backgroundColor: const Color(0xFF333333),
      builder: (context) {
        return ListView(
          children: _links.entries.map((entry) {
            final isSelected = _currentTitle == entry.key;
            return ListTile(
              leading: Icon(_getIconForTitle(entry.key), color: isSelected ? Colors.orange : Colors.white),
              title: Text(entry.key.i18n, style: TextStyle(color: isSelected ? Colors.orange : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              onTap: () {
                setState(() {
                  _currentTitle = entry.key;
                  _webViewController.loadRequest(Uri.parse(entry.value));
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
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
            decoration: BoxDecoration(color: const Color(0xFF333333).withOpacity(0.4), borderRadius: BorderRadius.circular(12.r)),
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
            clipBehavior: Clip.antiAlias, // Ensures WebView respects the border radius
            child: Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_isLoading) Center(child: LoadingAnimationWidget.fourRotatingDots(size: 40, color: Colors.orange)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


// --- Component Widgets from original Analytics ---
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