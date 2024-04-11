import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forex_currency_conversion/forex_currency_conversion.dart';
import 'package:hive/hive.dart';

class CurrencyExchangeRatesModel extends StateNotifier<CurrencyConversions> {
  CurrencyExchangeRatesModel(super.state);

  Future<void> updateRates() async {
    final fx = Forex();
    final usdToEur = await fx.getCurrencyConverted(sourceCurrency: 'USD', destinationCurrency: 'EUR', sourceAmount: 10000) / 10000;
    final usdToBrl = await fx.getCurrencyConverted(sourceCurrency: 'USD', destinationCurrency: 'BRL', sourceAmount: 10000) / 10000;
    final usdToBtc = await fx.getCurrencyConverted(sourceCurrency: 'USD', destinationCurrency: 'BTC', sourceAmount: 10000) / 10000;
    final eurToBrl = await fx.getCurrencyConverted(sourceCurrency: 'EUR', destinationCurrency: 'BRL', sourceAmount: 10000) / 10000;
    final eurToBtc = await fx.getCurrencyConverted(sourceCurrency: 'EUR', destinationCurrency: 'BTC', sourceAmount: 10000) / 10000;
    final brlToBtc = await fx.getCurrencyConverted(sourceCurrency: 'BRL', destinationCurrency: 'BTC', sourceAmount: 10000) / 10000;
    final error = fx.getErrorNotifier.value;

    if (error != null){
      throw 'No internet connection';
    }

    final currencyBox = await Hive.openBox('currency');
    currencyBox.put('usdToEur', usdToEur);
    currencyBox.put('usdToBrl', usdToBrl);
    currencyBox.put('usdToBtc', usdToBtc);
    currencyBox.put('eurToBrl', eurToBrl);
    currencyBox.put('eurToBtc', eurToBtc);
    currencyBox.put('brlToBtc', brlToBtc);
    currencyBox.put('eurToUsd', 1/usdToEur);
    currencyBox.put('brlToUsd', 1/usdToBrl);
    currencyBox.put('btcToUsd', 1/usdToBtc);
    currencyBox.put('brlToEur', 1/eurToBrl);
    currencyBox.put('btcToEur', 1/eurToBtc);
    currencyBox.put('btcToBrl', 1/brlToBtc);

    state = CurrencyConversions(
      usdToEur: usdToEur,
      usdToBrl: usdToBrl,
      usdToBtc: usdToBtc,
      eurToUsd: 1/usdToEur,
      eurToBrl: eurToBrl,
      eurToBtc: eurToBtc,
      brlToUsd: 1/usdToBrl,
      brlToEur: 1/eurToBrl,
      brlToBtc: brlToBtc,
      btcToUsd: 1/usdToBtc,
      btcToEur: 1/eurToBtc,
      btcToBrl: 1/brlToBtc,
    );
  }
}

class CurrencyConversions {
  final double usdToEur;
  final double usdToBrl;
  final double usdToBtc;
  final double eurToUsd;
  final double eurToBrl;
  final double eurToBtc;
  final double brlToUsd;
  final double brlToEur;
  final double brlToBtc;
  final double btcToUsd;
  final double btcToEur;
  final double btcToBrl;

  CurrencyConversions({
    required this.usdToEur,
    required this.usdToBrl,
    required this.usdToBtc,
    required this.eurToUsd,
    required this.eurToBrl,
    required this.eurToBtc,
    required this.brlToUsd,
    required this.brlToEur,
    required this.brlToBtc,
    required this.btcToUsd,
    required this.btcToEur,
    required this.btcToBrl,
  });
}


