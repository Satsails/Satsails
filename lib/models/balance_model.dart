import 'package:flutter/material.dart';
import 'package:forex_currency_conversion/forex_currency_conversion.dart';

class BalanceModel extends ChangeNotifier {
  int btcBalance;
  int liquidBalance;
  int brlBalance;
  int usdBalance;
  int cadBalance;
  int eurBalance;

  BalanceModel({
    required this.btcBalance,
    required this.liquidBalance,
    required this.brlBalance,
    required this.usdBalance,
    required this.cadBalance,
    required this.eurBalance,
  });

  Future<double> _getConvertedBalance(String sourceCurrency, String destinationCurrency, double sourceAmount) async {
    final fx = Forex();
    return await fx.getCurrencyConverted(sourceCurrency: sourceCurrency, destinationCurrency: destinationCurrency, sourceAmount: sourceAmount);
  }

  Future<double> totalBalanceInCurrency(String currency) async {
    double total = 0;
    switch (currency) {
      case 'BTC':
        total += btcBalance.toDouble() + liquidBalance.toDouble();
        total += await _getConvertedBalance('BRL', 'BTC', brlBalance.toDouble());
        total += await _getConvertedBalance('CAD', 'BTC', cadBalance.toDouble());
        total += await _getConvertedBalance('EUR', 'BTC', eurBalance.toDouble());
        total += await _getConvertedBalance('USD', 'BTC', usdBalance.toDouble());
        break;
      case 'USD':
        total += usdBalance.toDouble();
        total += await _getConvertedBalance('BRL', 'USD', brlBalance.toDouble());
        total += await _getConvertedBalance('CAD', 'USD', cadBalance.toDouble());
        total += await _getConvertedBalance('EUR', 'USD', eurBalance.toDouble());
        break;
      case 'CAD':
        total += cadBalance.toDouble();
        total += await _getConvertedBalance('BRL', 'CAD', brlBalance.toDouble());
        total += await _getConvertedBalance('EUR', 'CAD', eurBalance.toDouble());
        total += await _getConvertedBalance('USD', 'CAD', usdBalance.toDouble());
        break;
      case 'EUR':
        total += eurBalance.toDouble();
        total += await _getConvertedBalance('BRL', 'EUR', brlBalance.toDouble());
        total += await _getConvertedBalance('CAD', 'EUR', cadBalance.toDouble());
        total += await _getConvertedBalance('USD', 'EUR', usdBalance.toDouble());
        break;
      case 'BRL':
        total += brlBalance.toDouble();
        total += await _getConvertedBalance('CAD', 'BRL', cadBalance.toDouble());
        total += await _getConvertedBalance('EUR', 'BRL', eurBalance.toDouble());
        total += await _getConvertedBalance('USD', 'BRL', usdBalance.toDouble());
        break;
    }
    return total;
  }

  Future<double> totalBalanceInBtcOnly() async {
    return btcBalance.toDouble() + liquidBalance.toDouble();
  }

  Future<double> totalBalanceInBtc() async {
    return await totalBalanceInCurrency('BTC');
  }

  Future<double> totalBalanceInUsd() async {
    return await totalBalanceInCurrency('USD');
  }

  Future<double> totalBalanceInCad() async {
    return await totalBalanceInCurrency('CAD');
  }

  Future<double> totalBalanceInEur() async {
    return await totalBalanceInCurrency('EUR');
  }

  Future<double> totalBalanceInBrl() async {
    return await totalBalanceInCurrency('BRL');
  }
}
