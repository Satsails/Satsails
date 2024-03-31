import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forex_currency_conversion/forex_currency_conversion.dart';

class BalanceModel extends StateNotifier<Balance>{
  BalanceModel(super.state);

  Future<double> _getConvertedBalance(String sourceCurrency, String destinationCurrency, double sourceAmount) async {
    final fx = Forex();
    return await fx.getCurrencyConverted(sourceCurrency: sourceCurrency, destinationCurrency: destinationCurrency, sourceAmount: sourceAmount);
  }

  Future<double> totalBalanceInCurrency() async {
    double total = 0;
    switch (state.currency) {
      case 'BTC':
        total += state.btcBalance.toDouble() + state.liquidBalance.toDouble();
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
        break;
      case 'CAD':
        total += state.cadBalance.toDouble();
        total += await _getConvertedBalance('BRL', 'CAD', state.brlBalance.toDouble());
        total += await _getConvertedBalance('EUR', 'CAD', state.eurBalance.toDouble());
        total += await _getConvertedBalance('USD', 'CAD', state.usdBalance.toDouble());
        break;
      case 'EUR':
        total += state.eurBalance.toDouble();
        total += await _getConvertedBalance('BRL', 'EUR', state.brlBalance.toDouble());
        total += await _getConvertedBalance('CAD', 'EUR', state.cadBalance.toDouble());
        total += await _getConvertedBalance('USD', 'EUR', state.usdBalance.toDouble());
        break;
      case 'BRL':
        total += state.brlBalance.toDouble();
        total += await _getConvertedBalance('CAD', 'BRL', state.cadBalance.toDouble());
        total += await _getConvertedBalance('EUR', 'BRL', state.eurBalance.toDouble());
        total += await _getConvertedBalance('USD', 'BRL', state.usdBalance.toDouble());
        break;
    }
    return total;
  }

  Future<double> totalBalanceInBtcOnly() async {
    return state.btcBalance.toDouble() + state.liquidBalance.toDouble();
  }
}

class Balance {
  final double btcBalance;
  final double liquidBalance;
  final double usdBalance;
  final double cadBalance;
  final double eurBalance;
  final double brlBalance;
  final String currency;

  Balance({
    required this.btcBalance,
    required this.liquidBalance,
    required this.usdBalance,
    required this.cadBalance,
    required this.eurBalance,
    required this.brlBalance,
    required this.currency,
  });

  Balance copyWith({
    double? btcBalance,
    double? liquidBalance,
    double? usdBalance,
    double? cadBalance,
    double? eurBalance,
    double? brlBalance,
    String? currency,
  }) {
    return Balance(
      btcBalance: btcBalance ?? this.btcBalance,
      liquidBalance: liquidBalance ?? this.liquidBalance,
      usdBalance: usdBalance ?? this.usdBalance,
      cadBalance: cadBalance ?? this.cadBalance,
      eurBalance: eurBalance ?? this.eurBalance,
      brlBalance: brlBalance ?? this.brlBalance,
      currency: currency ?? this.currency,
    );
  }
}
