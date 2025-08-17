// lib/providers/coingecko_provider.dart

import 'package:Satsails/models/coingecko_model.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:coingecko_api/data/market_chart_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider #1: An AsyncNotifier that acts as a cache for the last year of market data.
// It only refetches from the network when the currency changes or when manually invalidated.
class BitcoinMarketDataNotifier extends AsyncNotifier<List<MarketChartData>> {
  @override
  Future<List<MarketChartData>> build() async {
    final currency = ref.read(settingsProvider.select((s) => s.currency));
    final coingeckoModel = CoingeckoModel();
    final to = DateTime.now();
    final from = to.subtract(const Duration(days: 365));
    // This network call only happens when the provider is first loaded or invalidated.
    return await coingeckoModel.getBitcoinMarketDataRange(currency, from, to);
  }

  Future<void> refreshData() async {
    ref.invalidateSelf();
    await future;
  }
}

final bitcoinMarketDataProvider = AsyncNotifierProvider<BitcoinMarketDataNotifier, List<MarketChartData>>(
      () => BitcoinMarketDataNotifier(),
);


// Provider #2: A simple provider that filters the cached data from above.
// It watches the date range provider and will re-run its filter whenever the date range changes.
final filteredBitcoinMarketDataProvider = Provider.autoDispose<AsyncValue<List<MarketChartData>>>((ref) {
  final marketDataAsync = ref.watch(bitcoinMarketDataProvider);
  final selectedDays = ref.watch(selectedDaysDateArrayProvider);

  // Pass through loading and error states from the main provider.
  if (marketDataAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (marketDataAsync.hasError) {
    return AsyncValue.error(marketDataAsync.error!, marketDataAsync.stackTrace!);
  }

  final fullData = marketDataAsync.value ?? [];
  if (selectedDays.isEmpty || fullData.isEmpty) {
    return const AsyncValue.data([]);
  }

  final from = selectedDays.first;
  final to = selectedDays.last.add(const Duration(days: 1));

  final filtered = fullData.where((data) {
    return !data.date.isBefore(from) && data.date.isBefore(to);
  }).toList();

  return AsyncValue.data(filtered);
});