import 'package:Satsails/models/coingecko_model.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:coingecko_api/data/market_chart_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Simple Providers (Unchanged) ---

final selectedDateRangeProvider = StateProvider<int>((ref) => 7);

final coinGeckoBitcoinChange = FutureProvider.family<double, String>((ref, currency) async {
  CoingeckoModel coingeckoModel = CoingeckoModel();
  return await coingeckoModel.getBitcoinChangePercentage(currency);
});

// This provider is now replaced by the AsyncNotifier below.
// final coinGeckoBitcoinMarketDataProvider = FutureProvider<List<MarketChartData>>((ref) async { ... });


// --- REFACTORED: Converted from StateNotifier to the modern AsyncNotifier ---

class BitcoinMarketDataNotifier extends AsyncNotifier<List<MarketChartData>> {
  // This private variable holds the full year of data in memory
  // to allow for fast filtering without new network calls.
  List<MarketChartData> _fullData = [];

  /// The `build` method is the core of an AsyncNotifier.
  /// It's responsible for fetching the initial data and returning a Future.
  /// Riverpod automatically handles the loading and error states.
  /// This method will also re-run automatically whenever a provider it `watch`es changes.
  @override
  Future<List<MarketChartData>> build() async {
    // 1. Watch for currency changes. If the currency changes, this `build` method will
    //    automatically be re-executed, fetching new data for the new currency.
    final currency = ref.watch(settingsProvider.select((s) => s.currency));

    // 2. Fetch the full 365-day dataset from the API.
    final coingeckoModel = CoingeckoModel();
    final to = DateTime.now();
    final from = to.subtract(const Duration(days: 365));
    _fullData = await coingeckoModel.getBitcoinMarketDataRange(currency, from, to);

    // 3. Perform the initial filtering based on the current date range selection
    //    and return the filtered list as the initial state.
    final selectedDays = ref.read(selectedDaysDateArrayProvider);
    return _filterData(selectedDays);
  }

  /// A private helper method to perform the filtering logic.
  List<MarketChartData> _filterData(List<DateTime> selectedDays) {
    if (selectedDays.isEmpty || _fullData.isEmpty) {
      return [];
    }
    final from = selectedDays.reduce((a, b) => a.isBefore(b) ? a : b);
    // Add 1 day to 'to' to make the range inclusive of the last day.
    final to = selectedDays.reduce((a, b) => a.isAfter(b) ? a : b).add(const Duration(days: 1));

    final filtered = _fullData.where((data) {
      return data.date.isAfter(from.subtract(const Duration(days: 1))) && data.date.isBefore(to);
    }).toList();

    return filtered;
  }

  /// A public method that the UI can call to update the date filter.
  /// This runs the filtering logic on the existing `_fullData` without
  /// making a new network request.
  void updateFilter() {
    final selectedDays = ref.read(selectedDaysDateArrayProvider);
    final filteredData = _filterData(selectedDays);
    // Manually update the state with the newly filtered data.
    state = AsyncValue.data(filteredData);
  }

  /// A public method to force a full refresh of the data from the API.
  Future<void> refreshData() async {
    // Invalidate the provider, which will cause the `build` method to run again.
    ref.invalidateSelf();
    // You can await the completion of the build method by awaiting the future.
    await future;
  }
}

/// The final provider definition using the modern `AsyncNotifierProvider`.
/// This replaces your old `StateNotifierProvider`.
final bitcoinMarketDataProvider = AsyncNotifierProvider<BitcoinMarketDataNotifier, List<MarketChartData>>(
      () => BitcoinMarketDataNotifier(),
);