class AssetMapper {
  String mapAsset(String assetId) {
    switch (assetId) {
      case 'ce091c998b83c78bb71a632313ba3760f1763d9cfcffae02258ffa9865a37bd2':
        return 'USD';
      case '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d':
        return 'L-BTC';
      case '18729918ab4bca843656f08d4dd877bed6641fbd596a0a963abbf199cfeb3cec':
        return 'EUR';
        case'02f22f8d9c76ab41661a2729e4752e2c5d1a263012141b86ea98af5472df5189':
        return 'BRL';
      default:
        return 'unknown';
    }
  }

  String reverseMapTicker(String ticker) {
    switch (ticker) {
      case 'USD':
        return 'ce091c998b83c78bb71a632313ba3760f1763d9cfcffae02258ffa9865a37bd2';
      case 'L-BTC':
        return '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d';
      case 'EUR':
        return '18729918ab4bca843656f08d4dd877bed6641fbd596a0a963abbf199cfeb3cec';

      default:
        return 'unknown';
    }
  }
}