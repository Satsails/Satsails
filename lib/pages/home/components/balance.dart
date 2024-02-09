import '../../../services/bitcoin_price.dart';
import '../../../channels/greenwallet.dart' as greenwallet;
import '../../../helpers/networks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


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

  Map<String, dynamic> translateLiquidAssets(Map<String, dynamic> balance) {
    Map<String, dynamic> liquidBalance = balance['liquid'];
    Map<String, dynamic> translatedBalance = {};

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
    // String mnemonic = await storage.read(key: 'mnemonic') ?? '';
    String mnemonic = 'visa hole fiscal already fuel keen girl vault hand antique lesson tattoo';
    Map<String, dynamic> bitcoinBalance = await greenwallet.Channel('ios_wallet').getBalance(mnemonic: mnemonic, connectionType: NetworkSecurityCase.bitcoinSS.network);
    Map<String, dynamic> liquidBalance = await greenwallet.Channel('ios_wallet').getBalance(mnemonic: mnemonic, connectionType: NetworkSecurityCase.liquidSS.network);
    Map<String, dynamic> balance ={
      'bitcoin': bitcoinBalance["btc"],
      'liquid': assetMapper.translateLiquidAssets({'liquid': liquidBalance}),
    };
    return balance;
  }


  Future<Map<String, double>> calculateUSDValue(double bitcoinPrice, Map<String, dynamic> balance) async {
    int bitcoinValue = 0;
    bitcoinValue += balance["bitcoin"] as int;
    bitcoinValue += balance['liquid']['liquid'] as int;
    double bitcoinValueDouble = bitcoinValue.toDouble() / 100000000;
    double usdOnly = balance['liquid']['usd'] / 100000000;
    double usdValue = bitcoinValueDouble * bitcoinPrice + (usdOnly);
    Map<String, double> result = {
      'usd': usdValue,
      'usdOnly': usdOnly
    };
    return result;
  }

  Future<Map<String, double>> calculateBitcoinValue(double bitcoinPrice, Map<String, dynamic> balance) async {
    int bitcoinValue = (balance["bitcoin"] as int) + (balance['liquid']['liquid'] as int);

    double usdToValue = balance['liquid']['usd'] / 100000000;
    double usdToBitcoin = usdToValue / bitcoinPrice;
    double bitcoinValueDouble = bitcoinValue.toDouble() / 100000000;
    bitcoinValueDouble += usdToBitcoin;

    double btc = balance["bitcoin"].toDouble() / 100000000;
    double btcInUsd = balance["bitcoin"].toDouble() * bitcoinPrice / 100000000;

    double lBtc = balance['liquid']['liquid'].toDouble() / 100000000;
    double lBtcInUsd = balance['liquid']['liquid'].toDouble() * bitcoinPrice / 100000000;

    double totalBtcOnly = btc + lBtc;
    double totalBtcOnlyInUsd = totalBtcOnly * bitcoinPrice;
    double totalValueInBTC = bitcoinValueDouble;

    return {
      'btc': btc,
      'btcInUsd': btcInUsd,
      'l-btc': lBtc,
      'l-btcInUsd': lBtcInUsd,
      'totalBtcOnly': totalBtcOnly,
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

  Future<Map<String, double>> calculateTotalValue() async {
    // double currentBitcoinPrice = await getBitcoinPrice();
    Map<String, dynamic> balance = await getBalance();
    double currentBitcoinPrice = 1000000;
    Future<Map<String, double>> bitcoinValue = calculateBitcoinValue(currentBitcoinPrice, balance);
    Future<Map<String, double>> usd = calculateUSDValue(currentBitcoinPrice, balance);
    Map<String, double> result = {};
    result.addAll(await bitcoinValue);
    result.addAll(await usd);

    return result;
  }
}