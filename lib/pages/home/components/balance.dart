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


  Future<double> calculateUSDValue(double bitcoinPrice) async {
    Map<String, dynamic> balance = await getBalance();
    int bitcoinValue = 0;
    bitcoinValue += balance["bitcoin"] as int;
    bitcoinValue += balance['liquid']['liquid'] as int;
    double bitcoinValueDouble = bitcoinValue.toDouble() / 100000000;
    double usdValue = bitcoinValueDouble * bitcoinPrice + (balance['liquid']['usd'] / 100000000);
    return usdValue;
  }

  Future<double> calculateBitcoinValue(double bitcoinPrice) async {
    Map<String, dynamic> balance = await getBalance();
    int bitcoinValue = 0;
    bitcoinValue += balance["bitcoin"] as int;
    bitcoinValue += balance['liquid']['liquid'] as int;

    double usdToValue = (balance['liquid']['usd'] / 100000000);
    double usdToBitcoin = usdToValue / bitcoinPrice;
    double bitcoinValueDouble = bitcoinValue.toDouble() / 100000000;

    bitcoinValueDouble += usdToBitcoin;

    return bitcoinValueDouble;
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
    double currentBitcoinPrice = await getBitcoinPrice();
    Future<double> bitcoinValue = calculateBitcoinValue(currentBitcoinPrice);
    Future<double> usdValue = calculateUSDValue(currentBitcoinPrice);
    List<double> values = await Future.wait([bitcoinValue, usdValue]);

    Map<String, double> result = {
      'bitcoin': values[0],
      'usd': values[1],
    };

    return result;
  }
}