import 'package:Satsails/models/coingecko_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final coinGeckoDataProvider = FutureProvider.autoDispose<double>((ref) async {
  CoingeckoModel coingeckoModel = CoingeckoModel();
  return await coingeckoModel.getCoinData();
});