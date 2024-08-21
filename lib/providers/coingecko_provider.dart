import 'package:Satsails/models/coingecko_model.dart';
import 'package:coingecko_api/data/market_chart_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final coinGeckoBitcoinChange = FutureProvider.autoDispose<double>((ref) async {
  CoingeckoModel coingeckoModel = CoingeckoModel();
  return await coingeckoModel.getBitcoinChangePercentage();
});

final coinGeckoBitcoinMarketDataProvider = FutureProvider.autoDispose.family<List<MarketChartData>, MarketData>((ref, data) async {
  CoingeckoModel coingeckoModel = CoingeckoModel();
  final market = coingeckoModel.getBitcoinMarketData(data);
  return await market;
});
