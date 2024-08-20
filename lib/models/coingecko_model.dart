import 'package:coingecko_api/coingecko_api.dart';

class CoingeckoModel {
  CoinGeckoApi api = CoinGeckoApi();

  Future<double> getCoinData() async {
    final marketData = await api.coins.getCoinMarketChart(
      id: 'bitcoin',
      vsCurrency: 'usd',
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
}