import 'package:Satsails/models/coingecko_model.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:coingecko_api/data/market_chart_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDateRangeProvider = StateProvider<int>((ref) => 7);

final coinGeckoBitcoinChange = FutureProvider.family<double, String>((ref, currency) async {
  CoingeckoModel coingeckoModel = CoingeckoModel();
  return await coingeckoModel.getBitcoinChangePercentage(currency);
});

final coinGeckoBitcoinMarketDataProvider = FutureProvider<List<MarketChartData>>((ref) async {
  final selectedDateRange = ref.watch(selectedDateRangeProvider);
  final currency = ref.watch(settingsProvider).currency;

  MarketData marketInfo = MarketData(
    days: selectedDateRange,
    currency: currency,
  );

  CoingeckoModel coingeckoModel = CoingeckoModel();
  final market = await coingeckoModel.getBitcoinMarketData(marketInfo);
  return market;
});


class BitcoinMarketDataNotifier extends StateNotifier<AsyncValue<List<MarketChartData>>> {
  final Ref ref;
  List<MarketChartData> _fullData = [];

  BitcoinMarketDataNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadInitialData();
    // Listen to selected days changes to update filtering
    ref.listen(selectedDaysDateArrayProvider, (_, __) {
      _filterAndUpdateState();
    });
    // Listen to currency changes to refresh data
    ref.listen(settingsProvider, (previous, next) {
      if (previous?.currency != next.currency) {
        _loadInitialData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    state = const AsyncValue.loading();
    try {
      final currency = ref.read(settingsProvider).currency;
      final coingeckoModel = CoingeckoModel();
      final to = DateTime.now();
      final from = to.subtract(const Duration(days: 365));
      _fullData = await coingeckoModel.getBitcoinMarketDataRange(currency, from, to);
      _filterAndUpdateState();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _filterAndUpdateState() {
    final selectedDays = ref.read(selectedDaysDateArrayProvider);
    if (selectedDays.isEmpty) {
      state = AsyncValue.data([]);
      return;
    }
    final from = selectedDays.reduce((a, b) => a.isBefore(b) ? a : b);
    final to = selectedDays.reduce((a, b) => a.isAfter(b) ? a : b).add(const Duration(days: 1));
    final filtered = _fullData.where((data) {
      return data.date.isAfter(from.subtract(const Duration(days: 1))) &&
          data.date.isBefore(to);
    }).toList();
    state = AsyncValue.data(filtered);
  }

  Future<void> refreshData() async {
    await _loadInitialData();
  }

  void updateFilteredData() {
    _filterAndUpdateState();
  }
}

final bitcoinMarketDataProvider = StateNotifierProvider<BitcoinMarketDataNotifier, AsyncValue<List<MarketChartData>>>(
      (ref) => BitcoinMarketDataNotifier(ref),
);


