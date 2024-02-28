import 'package:flutter/material.dart';

class AssetMapper {
  String mapAsset(String assetId) {
    switch (assetId) {
      case 'btc':
        return 'BTC';
      case 'ce091c998b83c78bb71a632313ba3760f1763d9cfcffae02258ffa9865a37bd2':
        return 'USD';
      case '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d':
        return 'BTC';
      case '18729918ab4bca843656f08d4dd877bed6641fbd596a0a963abbf199cfeb3cec':
        return 'eur';
      default:
        return 'unknown';
    }
  }

  String reverseMapTicker(String ticker) {
    switch (ticker) {
      case 'USDT':
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