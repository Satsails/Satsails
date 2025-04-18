import 'package:Satsails/models/coingecko_model.dart';
import 'package:Satsails/providers/analytics_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:coingecko_api/data/market_chart_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDateRangeProvider = StateProvider<int>((ref) => 7);

final coinGeckoBitcoinChange = FutureProvider.autoDispose.family<double, String>((ref, currency) async {
  CoingeckoModel coingeckoModel = CoingeckoModel();
  return await coingeckoModel.getBitcoinChangePercentage(currency);
});

final coinGeckoBitcoinMarketDataProvider = FutureProvider.autoDispose<List<MarketChartData>>((ref) async {
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

final bitcoinHistoricalMarketDataProvider = FutureProvider<List<MarketChartData>>((ref) async {
  final selectedDays = ref.watch(selectedDaysDateArrayProvider);
  if (selectedDays.isEmpty) return [];

  // Find the earliest and latest dates from selected days as DateTime
  final from = selectedDays.reduce((a, b) => a.isBefore(b) ? a : b);
  final to = selectedDays.reduce((a, b) => a.isAfter(b) ? a : b).add(const Duration(days: 1));

  final currency = ref.read(settingsProvider).currency;
  final coingeckoModel = CoingeckoModel();
  // Convert DateTime to Unix timestamps when calling the method
  return await coingeckoModel.getBitcoinMarketDataRange(
    currency,
    from, // Pass as DateTime
    to,   // Pass as DateTime
  );
});

