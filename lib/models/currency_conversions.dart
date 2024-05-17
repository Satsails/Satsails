import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forex_currency_conversion/forex_currency_conversion.dart';
import 'package:hive/hive.dart';

class CurrencyExchangeRatesModel extends StateNotifier<CurrencyConversions> {
  CurrencyExchangeRatesModel(super.state);

  Future<void> updateRates() async {
    final fx = Forex();

    final usdToEur = await fx.getCurrencyConverted(sourceCurrency: 'USD', destinationCurrency: 'EUR', sourceAmount: 1);
    final error = fx.getErrorNotifier.value;
    if (error != null){
      throw 'No internet connection';
    }
    final usdToBrl = await fx.getCurrencyConverted(sourceCurrency: 'USD', destinationCurrency: 'BRL', sourceAmount: 1);
    final btcToUsd = await fx.getCurrencyConverted(sourceCurrency: 'BTC', destinationCurrency: 'USD', sourceAmount: 1);
    final eurToBrl = await fx.getCurrencyConverted(sourceCurrency: 'EUR', destinationCurrency: 'BRL', sourceAmount: 1);
    final btcToEur = await fx.getCurrencyConverted(sourceCurrency: 'BTC', destinationCurrency: 'EUR', sourceAmount: 1);
    final btcToBrl = await fx.getCurrencyConverted(sourceCurrency: 'BTC', destinationCurrency: 'BRL', sourceAmount: 1);


    final currencyBox = await Hive.openBox('currency');
    currencyBox.put('usdToEur', usdToEur);
    currencyBox.put('usdToBrl', usdToBrl);
    currencyBox.put('usdToBtc', 1/btcToUsd);
    currencyBox.put('eurToBrl', eurToBrl);
    currencyBox.put('eurToBtc', 1/btcToEur);
    currencyBox.put('brlToBtc', 1/btcToBrl);
    currencyBox.put('eurToUsd', 1/usdToEur);
    currencyBox.put('brlToUsd', 1/usdToBrl);
    currencyBox.put('btcToUsd', btcToUsd);
    currencyBox.put('brlToEur', 1/eurToBrl);
    currencyBox.put('btcToEur', btcToEur);
    currencyBox.put('btcToBrl', btcToBrl);

    state = CurrencyConversions(
      usdToEur: usdToEur,
      usdToBrl: usdToBrl,
      usdToBtc: 1/btcToUsd,
      eurToUsd: 1/usdToEur,
      eurToBrl: eurToBrl,
      eurToBtc: 1/btcToEur,
      brlToUsd: 1/usdToBrl,
      brlToEur: 1/eurToBrl,
      brlToBtc: 1/btcToBrl,
      btcToUsd: btcToUsd,
      btcToEur: btcToEur,
      btcToBrl: btcToBrl,
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


