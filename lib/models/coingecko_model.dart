import 'package:coingecko_api/coingecko_api.dart';
import 'package:coingecko_api/data/market_chart_data.dart';

class CoingeckoModel {
  final CoinGeckoApi api = CoinGeckoApi();

  Future<double> getBitcoinChangePercentage(String currency) async {
    final marketData = await api.coins.getCoinMarketChart(
      id: 'bitcoin',
      vsCurrency: currency.toLowerCase(),
      days: 7,
    );
    final currentPrice = marketData.data.last.price;
    final secondToLastPrice = marketData.data[marketData.data.length - 5].price;

    if (currentPrice != null && secondToLastPrice != null) {
      final percentageChange = ((currentPrice - secondToLastPrice) / secondToLastPrice) * 100;
      return percentageChange;
    } else {
      return 0.0;
    }
  }

  Future<List<MarketChartData>> getBitcoinMarketData(MarketData data) async {
    try {
      final marketData = await api.coins.getCoinMarketChart(
        id: 'bitcoin',
        vsCurrency: data.currency.toLowerCase(),
        days: data.days,
      );
      return marketData.data;
    } on Exception catch (e) {
      throw Exception('Failed to fetch market data: $e');
    }
  }

  // New method to fetch market data for a specific range
  Future<List<MarketChartData>> getBitcoinMarketDataRange(String currency, DateTime from, DateTime to) async {
    try {
      final marketData = await api.coins.getCoinMarketChartRanged(
        id: 'bitcoin',
        vsCurrency: currency.toLowerCase(),
        from: from,
        to: to,
      );
      return marketData.data;
    } catch (e) {
      throw Exception('Failed to fetch market data: $e');
    }
  }
}

class MarketData {
  final int days;
  final String currency;

  MarketData({
    required this.days,
    required this.currency,
  });
}