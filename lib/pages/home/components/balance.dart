import 'package:flutter/material.dart';
import '../../../services/bitcoin_price.dart';
import '../../../channels/greenwallet.dart' as greenwallet;
import '../../../helpers/networks.dart';
import '../../../providers/balance_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

//  use helper instead
class AssetMapper {
  String mapAsset(String assetId) {
    switch (assetId) {
      case 'ce091c998b83c78bb71a632313ba3760f1763d9cfcffae02258ffa9865a37bd2':
        return 'usd';
      case '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d':
        return 'liquid';
      case '18729918ab4bca843656f08d4dd877bed6641fbd596a0a963abbf199cfeb3cec':
        return 'eur';
      default:
        return 'unknown';
    }
  }

  Map<String, int> translateLiquidAssets(Map<String, int> liquidBalance) {
    Map<String, int> translatedBalance = {};

    liquidBalance.forEach((key, value) {
      String translatedKey = mapAsset(key);
      translatedBalance[translatedKey] = value;
    });

    return translatedBalance;
  }
}

class BalanceWrapper {
  PriceProvider priceProvider = PriceProvider();
  AssetMapper assetMapper = AssetMapper();

  Future<Map<String, dynamic>> getBalance() async {
    const storage = FlutterSecureStorage();
    String mnemonic = await storage.read(key: 'mnemonic') ?? '';
    Map<String, int> bitcoinBalance = await greenwallet.Channel('ios_wallet').getBalance(mnemonic: mnemonic, connectionType: NetworkSecurityCase.bitcoinSS.network);
    Map<String, int> liquidBalance = await greenwallet.Channel('ios_wallet').getBalance(mnemonic: mnemonic, connectionType: NetworkSecurityCase.liquidSS.network);
    Map<String, dynamic> balance = {
      'bitcoin': bitcoinBalance["btc"] ?? 0,
      'liquid': assetMapper.translateLiquidAssets(liquidBalance),
    };
    return balance;
  }


  Future<Map<String, dynamic>> calculateUSDValue(double bitcoinPrice, Map<String, dynamic> balance) async {
    double bitcoinValue = 0;
    int usdBalance = balance['liquid']['usd'] ?? 0;
    bitcoinValue += balance["bitcoin"] ?? 0;
    bitcoinValue += balance['liquid']['liquid'] ?? 0;
    double bitcoinValueDouble = bitcoinValue / 100000000;
    double usdValue = bitcoinValueDouble * bitcoinPrice + (usdBalance / 100000000);
    Map<String, dynamic> result = {
      'usd': usdValue,
      'usdInt': usdValue * 100000000,
      'usdOnly': usdBalance / 100000000,
      'usdOnlyInt': usdBalance
    };
    return result;
  }

  Future<Map<String, dynamic>> calculateBitcoinValue(double bitcoinPrice, Map<String, dynamic> balance) async {
    int bitcoinValue = (balance["bitcoin"] as int) + (balance['liquid']['liquid'] as int);

    int usdBalance = balance['liquid']['usd'] ?? 0;
    double usdToValue = usdBalance / 100000000;
    double usdToBitcoin = usdToValue / bitcoinPrice;
    double bitcoinValueDouble = bitcoinValue.toDouble() / 100000000;
    bitcoinValueDouble += usdToBitcoin;

    int btc = balance["bitcoin"] ?? 0;
    double btcInUsd = balance["bitcoin"].toDouble() * bitcoinPrice / 100000000;

    int lBtc = balance['liquid']['liquid'] ?? 0;
    double lBtcInUsd = balance['liquid']['liquid'].toDouble() * bitcoinPrice / 100000000;

    int totalBtcOnly = btc + lBtc;
    double totalBtcOnlyInUsd = totalBtcOnly / 100000000 * bitcoinPrice;
    double totalValueInBTC = bitcoinValueDouble;

    return {
      'btcInt': btc,
      'btc': btc / 100000000,
      'btcInUsd': btcInUsd,
      'l-btc': lBtc / 100000000,
      'l-btcInt': lBtc,
      'l-btcInUsd': lBtcInUsd,
      'totalBtcOnly': totalBtcOnly / 100000000,
      'totalBtcOnlyInt': totalBtcOnly,
      'totalBtcOnlyInUsd': totalBtcOnlyInUsd,
      'totalValueInBTC': totalValueInBTC,
    };
  }


  Future<double> getBitcoinPrice() async {
    try {
      await priceProvider.fetchBitcoinPrice();
      return priceProvider.price;
    } catch (error) {
      throw Exception('Error getting Bitcoin price: $error');
    }
  }

  Future<Map<String, dynamic>> calculateTotalValue(BuildContext context) async {
    // double currentBitcoinPrice = await getBitcoinPrice();
    Map<String, dynamic> balance = await getBalance();
    double currentBitcoinPrice = 1000000;
    Future<Map<String, dynamic>> bitcoinValue = calculateBitcoinValue(currentBitcoinPrice, balance);
    Future<Map<String, dynamic>> usd = calculateUSDValue(currentBitcoinPrice, balance);
    Map<String, dynamic> result = {};
    result.addAll(await bitcoinValue);
    result.addAll(await usd);

    BalanceProvider balanceProvider = Provider.of<BalanceProvider>(context, listen: false);
    balanceProvider.setBalance(result);

    return result;
  }

}