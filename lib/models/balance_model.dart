import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forex_currency_conversion/forex_currency_conversion.dart';

class BalanceModel extends StateNotifier<Balance>{
  BalanceModel(super.state);

  Future<double> _getConvertedBalance(String sourceCurrency, String destinationCurrency, double sourceAmount) async {
    final fx = Forex();
    final result = await fx.getCurrencyConverted(sourceCurrency: sourceCurrency, destinationCurrency: destinationCurrency, sourceAmount: sourceAmount);
    final error = fx.getErrorNotifier.value;

    if (error != null){
      throw 'No internet connection';
    }
    return result;
  }

  Future<double> totalBalanceInCurrency(String currency) async {
    double total = 0;
    double totalInBtc = totalBtcBalanceInDenomination('BTC');

    switch (currency) {
      case 'BTC':
        total += totalInBtc;
        total += await _getConvertedBalance('BRL', 'BTC', state.brlBalance.toDouble());
        total += await _getConvertedBalance('CAD', 'BTC', state.cadBalance.toDouble());
        total += await _getConvertedBalance('EUR', 'BTC', state.eurBalance.toDouble());
        total += await _getConvertedBalance('USD', 'BTC', state.usdBalance.toDouble());
        break;
      case 'USD':
        total += state.usdBalance.toDouble();
        total += await _getConvertedBalance('BRL', 'USD', state.brlBalance.toDouble());
        total += await _getConvertedBalance('CAD', 'USD', state.cadBalance.toDouble());
        total += await _getConvertedBalance('EUR', 'USD', state.eurBalance.toDouble());
        total += await _getConvertedBalance('BTC', 'USD', totalInBtc);
        break;
      case 'CAD':
        total += state.cadBalance.toDouble();
        total += await _getConvertedBalance('BRL', 'CAD', state.brlBalance.toDouble());
        total += await _getConvertedBalance('EUR', 'CAD', state.eurBalance.toDouble());
        total += await _getConvertedBalance('USD', 'CAD', state.usdBalance.toDouble());
        total += await _getConvertedBalance('BTC', 'CAD', totalInBtc);
        break;
      case 'EUR':
        total += state.eurBalance.toDouble();
        total += await _getConvertedBalance('BRL', 'EUR', state.brlBalance.toDouble());
        total += await _getConvertedBalance('CAD', 'EUR', state.cadBalance.toDouble());
        total += await _getConvertedBalance('USD', 'EUR', state.usdBalance.toDouble());
        total += await _getConvertedBalance('BTC', 'EUR', totalInBtc);
        break;
      case 'BRL':
        total += state.brlBalance.toDouble();
        total += await _getConvertedBalance('CAD', 'BRL', state.cadBalance.toDouble());
        total += await _getConvertedBalance('EUR', 'BRL', state.eurBalance.toDouble());
        total += await _getConvertedBalance('USD', 'BRL', state.usdBalance.toDouble());
        total += await _getConvertedBalance('BTC', 'BRL', totalInBtc);
        break;
    }
    return total;
  }

  double totalBtcBalance() {
    return state.btcBalance.toDouble() + state.liquidBalance.toDouble();
  }

  Future<double> currentBitcoinPriceInCurrency(String currency) {
    return _getConvertedBalance('BTC', currency, 1);
  }

  void updateBtcBalance(int newBtcBalance) {
    state = state.copyWith(btcBalance: newBtcBalance);
  }

  double totalBtcBalanceInDenomination([String? denomination]) {
    switch (denomination) {
      case 'sats':
        return totalBtcBalance();
      case 'BTC':
        return totalBtcBalance() / 100000000;
      case 'mBTC':
        return totalBtcBalance() / 100000;
      case 'bits':
        return totalBtcBalance() / 1000000;
      default:
        return 0;
    }
  }
}

class Balance {
late final int btcBalance;
  final int liquidBalance;
  final int usdBalance;
  final int cadBalance;
  final int eurBalance;
  final int brlBalance;

  Balance({
    required this.btcBalance,
    required this.liquidBalance,
    required this.usdBalance,
    required this.cadBalance,
    required this.eurBalance,
    required this.brlBalance,
  });

  Balance copyWith({
    int? btcBalance,
    int? liquidBalance,
    int? usdBalance,
    int? cadBalance,
    int? eurBalance,
    int? brlBalance,
  }) {
    return Balance(
      btcBalance: btcBalance ?? this.btcBalance,
      liquidBalance: liquidBalance ?? this.liquidBalance,
      usdBalance: usdBalance ?? this.usdBalance,
      cadBalance: cadBalance ?? this.cadBalance,
      eurBalance: eurBalance ?? this.eurBalance,
      brlBalance: brlBalance ?? this.brlBalance,
    );
  }
}
