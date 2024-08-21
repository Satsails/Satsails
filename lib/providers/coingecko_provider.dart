import 'package:Satsails/models/coingecko_model.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:coingecko_api/data/market_chart_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDateRangeProvider = StateProvider<int>((ref) => 7);

final coinGeckoBitcoinChange = FutureProvider.autoDispose<double>((ref) async {
  CoingeckoModel coingeckoModel = CoingeckoModel();
  return await coingeckoModel.getBitcoinChangePercentage();
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

