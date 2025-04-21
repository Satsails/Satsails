import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SideswapMarketsModel extends StateNotifier<List<Market>> {
  SideswapMarketsModel(super.state);

  void updateMarkets(List<Market> newMarkets) {
    state = newMarkets;
  }

  List<String> get assetPairs {
    return state.map((market) => market.assetPair).toList();
  }

  List<Market> get filteredMarkets {
    return state.where((market) =>
    AssetMapper.mapAsset(market.baseAsset) != AssetId.UNKNOWN &&
        AssetMapper.mapAsset(market.quoteAsset) != AssetId.UNKNOWN
    ).toList();
  }
}

class Market {
  final String baseAsset;
  final String quoteAsset;
  final String feeAsset;
  final String type;

  Market({
    required this.baseAsset,
    required this.quoteAsset,
    required this.feeAsset,
    required this.type,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      baseAsset: json['asset_pair']['base'],
      quoteAsset: json['asset_pair']['quote'],
      feeAsset: json['fee_asset'],
      type: json['type'],
    );
  }

  String get assetPair {
    final base = AssetMapper.mapAsset(baseAsset);
    final quote = AssetMapper.mapAsset(quoteAsset);
    return '${base.name}/${quote.name}';
  }
}