enum AssetId {
  USD,
  LBTC,
  EUR,
  BRL,
  UNKNOWN;

  String get name {
    switch (this) {
      case AssetId.USD:
        return 'USDT';
      case AssetId.LBTC:
        return 'BTC';
      case AssetId.EUR:
        return 'EURx';
      case AssetId.BRL:
        return 'Depix';
      default:
        return 'UNKNOWN';
    }
  }
}

class AssetMapper {
  static AssetId mapAsset(String assetId) {
    switch (assetId) {
      case 'ce091c998b83c78bb71a632313ba3760f1763d9cfcffae02258ffa9865a37bd2':
        return AssetId.USD;
      case '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d':
        return AssetId.LBTC;
      case '18729918ab4bca843656f08d4dd877bed6641fbd596a0a963abbf199cfeb3cec':
        return AssetId.EUR;
      case '02f22f8d9c76ab41661a2729e4752e2c5d1a263012141b86ea98af5472df5189':
        return AssetId.BRL;
      default:
        return AssetId.UNKNOWN;
    }
  }

  static String reverseMapTicker(AssetId ticker) {
    switch (ticker) {
      case AssetId.USD:
        return 'ce091c998b83c78bb71a632313ba3760f1763d9cfcffae02258ffa9865a37bd2';
      case AssetId.LBTC:
        return '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d';
      case AssetId.EUR:
        return '18729918ab4bca843656f08d4dd877bed6641fbd596a0a963abbf199cfeb3cec';
      case AssetId.BRL:
        return '02f22f8d9c76ab41661a2729e4752e2c5d1a263012141b86ea98af5472df5189';
      default:
        return '';
    }
  }
}