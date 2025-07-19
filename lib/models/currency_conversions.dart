import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forex_currency_conversion/forex_currency_conversion.dart';
import 'package:hive/hive.dart';

enum CurrencyType {
  BRL,
  USD,
  EUR,
  GBP,
  CHF;

  factory CurrencyType.fromString(String value) {
    return CurrencyType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => CurrencyType.USD,
    );
  }
}

enum BitcoinType {
  BTC,
  SATS;

  factory BitcoinType.fromString(String value) {
    return BitcoinType.values.firstWhere(
          (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => BitcoinType.BTC,
    );
  }
}

class CurrencyExchangeRatesModel extends StateNotifier<CurrencyConversions> {
  CurrencyExchangeRatesModel(super.state);

  Future<void> updateRates() async {
    final fx = Forex();

    final usdToEur = await fx.getCurrencyConverted(sourceCurrency: CurrencyType.USD.name, destinationCurrency: CurrencyType.EUR.name, sourceAmount: 1);
    final error = fx.getErrorNotifier.value;
    if (error != null) {
      throw 'No internet connection';
    }
    final usdToBrl = await fx.getCurrencyConverted(sourceCurrency: CurrencyType.USD.name, destinationCurrency: CurrencyType.BRL.name, sourceAmount: 1);
    final usdToGbp = await fx.getCurrencyConverted(sourceCurrency: CurrencyType.USD.name, destinationCurrency: CurrencyType.GBP.name, sourceAmount: 1);
    final usdToChf = await fx.getCurrencyConverted(sourceCurrency: CurrencyType.USD.name, destinationCurrency: CurrencyType.CHF.name, sourceAmount: 1);
    final btcToUsd = await fx.getCurrencyConverted(sourceCurrency: BitcoinType.BTC.name, destinationCurrency: CurrencyType.USD.name, sourceAmount: 1);
    final eurToBrl = await fx.getCurrencyConverted(sourceCurrency: CurrencyType.EUR.name, destinationCurrency: CurrencyType.BRL.name, sourceAmount: 1);
    final eurToGbp = await fx.getCurrencyConverted(sourceCurrency: CurrencyType.EUR.name, destinationCurrency: CurrencyType.GBP.name, sourceAmount: 1);
    final eurToChf = await fx.getCurrencyConverted(sourceCurrency: CurrencyType.EUR.name, destinationCurrency: CurrencyType.CHF.name, sourceAmount: 1);
    final btcToEur = await fx.getCurrencyConverted(sourceCurrency: BitcoinType.BTC.name, destinationCurrency: CurrencyType.EUR.name, sourceAmount: 1);
    final btcToBrl = await fx.getCurrencyConverted(sourceCurrency: BitcoinType.BTC.name, destinationCurrency: CurrencyType.BRL.name, sourceAmount: 1);
    final btcToGbp = await fx.getCurrencyConverted(sourceCurrency: BitcoinType.BTC.name, destinationCurrency: CurrencyType.GBP.name, sourceAmount: 1);
    final btcToChf = await fx.getCurrencyConverted(sourceCurrency: BitcoinType.BTC.name, destinationCurrency: CurrencyType.CHF.name, sourceAmount: 1);
    final gbpToBrl = await fx.getCurrencyConverted(sourceCurrency: CurrencyType.GBP.name, destinationCurrency: CurrencyType.BRL.name, sourceAmount: 1);
    final gbpToChf = await fx.getCurrencyConverted(sourceCurrency: CurrencyType.GBP.name, destinationCurrency: CurrencyType.CHF.name, sourceAmount: 1);
    final chfToBrl = await fx.getCurrencyConverted(sourceCurrency: CurrencyType.CHF.name, destinationCurrency: CurrencyType.BRL.name, sourceAmount: 1);

    const int satsPerBtc = 100000000;
    const satsToBtc = 1 / satsPerBtc;
    const int btcToSats = satsPerBtc;

    final satsToUsd = btcToUsd / satsPerBtc;
    final usdToSats = 1 / satsToUsd;
    final satsToEur = btcToEur / satsPerBtc;
    final eurToSats = 1 / satsToEur;
    final satsToBrl = btcToBrl / satsPerBtc;
    final brlToSats = 1 / satsToBrl;
    final satsToGbp = btcToGbp / satsPerBtc;
    final gbpToSats = 1 / satsToGbp;
    final satsToChf = btcToChf / satsPerBtc;
    final chfToSats = 1 / satsToChf;

    final currencyBox = await Hive.openBox('currency');

    currencyBox.put('${CurrencyType.USD.name}To${CurrencyType.EUR.name}', usdToEur);
    currencyBox.put('${CurrencyType.USD.name}To${CurrencyType.BRL.name}', usdToBrl);
    currencyBox.put('${CurrencyType.USD.name}To${CurrencyType.GBP.name}', usdToGbp);
    currencyBox.put('${CurrencyType.USD.name}To${CurrencyType.CHF.name}', usdToChf);
    currencyBox.put('${CurrencyType.USD.name}To${BitcoinType.BTC.name}', 1 / btcToUsd);
    currencyBox.put('${CurrencyType.EUR.name}To${CurrencyType.BRL.name}', eurToBrl);
    currencyBox.put('${CurrencyType.EUR.name}To${CurrencyType.GBP.name}', eurToGbp);
    currencyBox.put('${CurrencyType.EUR.name}To${CurrencyType.CHF.name}', eurToChf);
    currencyBox.put('${CurrencyType.EUR.name}To${BitcoinType.BTC.name}', 1 / btcToEur);
    currencyBox.put('${CurrencyType.BRL.name}To${BitcoinType.BTC.name}', 1 / btcToBrl);
    currencyBox.put('${CurrencyType.EUR.name}To${CurrencyType.USD.name}', 1 / usdToEur);
    currencyBox.put('${CurrencyType.BRL.name}To${CurrencyType.USD.name}', 1 / usdToBrl);
    currencyBox.put('${CurrencyType.GBP.name}To${CurrencyType.USD.name}', 1 / usdToGbp);
    currencyBox.put('${CurrencyType.CHF.name}To${CurrencyType.USD.name}', 1 / usdToChf);
    currencyBox.put('${BitcoinType.BTC.name}To${CurrencyType.USD.name}', btcToUsd);
    currencyBox.put('${CurrencyType.BRL.name}To${CurrencyType.EUR.name}', 1 / eurToBrl);
    currencyBox.put('${CurrencyType.GBP.name}To${CurrencyType.EUR.name}', 1 / eurToGbp);
    currencyBox.put('${CurrencyType.CHF.name}To${CurrencyType.EUR.name}', 1 / eurToChf);
    currencyBox.put('${BitcoinType.BTC.name}To${CurrencyType.EUR.name}', btcToEur);
    currencyBox.put('${BitcoinType.BTC.name}To${CurrencyType.BRL.name}', btcToBrl);
    currencyBox.put('${BitcoinType.BTC.name}To${CurrencyType.GBP.name}', btcToGbp);
    currencyBox.put('${BitcoinType.BTC.name}To${CurrencyType.CHF.name}', btcToChf);
    currencyBox.put('${CurrencyType.GBP.name}To${CurrencyType.BRL.name}', gbpToBrl);
    currencyBox.put('${CurrencyType.GBP.name}To${CurrencyType.CHF.name}', gbpToChf);
    currencyBox.put('${CurrencyType.CHF.name}To${CurrencyType.BRL.name}', chfToBrl);
    currencyBox.put('${CurrencyType.BRL.name}To${CurrencyType.GBP.name}', 1 / gbpToBrl);
    currencyBox.put('${CurrencyType.CHF.name}To${CurrencyType.GBP.name}', 1 / gbpToChf);
    currencyBox.put('${CurrencyType.BRL.name}To${CurrencyType.CHF.name}', 1 / chfToBrl);
    currencyBox.put('${BitcoinType.SATS.name}To${CurrencyType.USD.name}', satsToUsd);
    currencyBox.put('${CurrencyType.USD.name}To${BitcoinType.SATS.name}', usdToSats);
    currencyBox.put('${BitcoinType.SATS.name}To${CurrencyType.EUR.name}', satsToEur);
    currencyBox.put('${CurrencyType.EUR.name}To${BitcoinType.SATS.name}', eurToSats);
    currencyBox.put('${BitcoinType.SATS.name}To${CurrencyType.BRL.name}', satsToBrl);
    currencyBox.put('${CurrencyType.BRL.name}To${BitcoinType.SATS.name}', brlToSats);
    currencyBox.put('${BitcoinType.SATS.name}To${CurrencyType.GBP.name}', satsToGbp);
    currencyBox.put('${CurrencyType.GBP.name}To${BitcoinType.SATS.name}', gbpToSats);
    currencyBox.put('${BitcoinType.SATS.name}To${CurrencyType.CHF.name}', satsToChf);
    currencyBox.put('${CurrencyType.CHF.name}To${BitcoinType.SATS.name}', chfToSats);
    currencyBox.put('${BitcoinType.SATS.name}To${BitcoinType.BTC.name}', satsToBtc);
    currencyBox.put('${BitcoinType.BTC.name}To${BitcoinType.SATS.name}', btcToSats);

    // Update state with all conversion rates
    state = CurrencyConversions(
      usdToEur: usdToEur,
      usdToBrl: usdToBrl,
      usdToGbp: usdToGbp,
      usdToChf: usdToChf,
      usdToBtc: 1 / btcToUsd,
      eurToUsd: 1 / usdToEur,
      eurToBrl: eurToBrl,
      eurToGbp: eurToGbp,
      eurToChf: eurToChf,
      eurToBtc: 1 / btcToEur,
      brlToUsd: 1 / usdToBrl,
      brlToEur: 1 / eurToBrl,
      brlToGbp: 1 / gbpToBrl,
      brlToChf: 1 / chfToBrl,
      brlToBtc: 1 / btcToBrl,
      gbpToUsd: 1 / usdToGbp,
      gbpToEur: 1 / eurToGbp,
      gbpToBrl: gbpToBrl,
      gbpToChf: gbpToChf,
      gbpToBtc: 1 / btcToGbp,
      chfToUsd: 1 / usdToChf,
      chfToEur: 1 / eurToChf,
      chfToBrl: chfToBrl,
      chfToGbp: 1 / gbpToChf,
      chfToBtc: 1 / btcToChf,
      btcToUsd: btcToUsd,
      btcToEur: btcToEur,
      btcToBrl: btcToBrl,
      btcToGbp: btcToGbp,
      btcToChf: btcToChf,
      satsToUsd: satsToUsd,
      usdToSats: usdToSats,
      satsToEur: satsToEur,
      eurToSats: eurToSats,
      satsToBrl: satsToBrl,
      brlToSats: brlToSats,
      satsToGbp: satsToGbp,
      gbpToSats: gbpToSats,
      satsToChf: satsToChf,
      chfToSats: chfToSats,
      satsToBtc: satsToBtc,
      btcToSats: btcToSats.toDouble(),
    );
  }
}

class CurrencyConversions {
  final double usdToEur;
  final double usdToBrl;
  final double usdToGbp;
  final double usdToChf;
  final double usdToBtc;
  final double eurToUsd;
  final double eurToBrl;
  final double eurToGbp;
  final double eurToChf;
  final double eurToBtc;
  final double brlToUsd;
  final double brlToEur;
  final double brlToGbp;
  final double brlToChf;
  final double brlToBtc;
  final double gbpToUsd;
  final double gbpToEur;
  final double gbpToBrl;
  final double gbpToChf;
  final double gbpToBtc;
  final double chfToUsd;
  final double chfToEur;
  final double chfToBrl;
  final double chfToGbp;
  final double chfToBtc;
  final double btcToUsd;
  final double btcToEur;
  final double btcToBrl;
  final double btcToGbp;
  final double btcToChf;
  final double satsToUsd;
  final double usdToSats;
  final double satsToEur;
  final double eurToSats;
  final double satsToBrl;
  final double brlToSats;
  final double satsToGbp;
  final double gbpToSats;
  final double satsToChf;
  final double chfToSats;
  final double satsToBtc;
  final double btcToSats;

  CurrencyConversions({
    required this.usdToEur,
    required this.usdToBrl,
    required this.usdToGbp,
    required this.usdToChf,
    required this.usdToBtc,
    required this.eurToUsd,
    required this.eurToBrl,
    required this.eurToGbp,
    required this.eurToChf,
    required this.eurToBtc,
    required this.brlToUsd,
    required this.brlToEur,
    required this.brlToGbp,
    required this.brlToChf,
    required this.brlToBtc,
    required this.gbpToUsd,
    required this.gbpToEur,
    required this.gbpToBrl,
    required this.gbpToChf,
    required this.gbpToBtc,
    required this.chfToUsd,
    required this.chfToEur,
    required this.chfToBrl,
    required this.chfToGbp,
    required this.chfToBtc,
    required this.btcToUsd,
    required this.btcToEur,
    required this.btcToBrl,
    required this.btcToGbp,
    required this.btcToChf,
    required this.satsToUsd,
    required this.usdToSats,
    required this.satsToEur,
    required this.eurToSats,
    required this.satsToBrl,
    required this.brlToSats,
    required this.satsToGbp,
    required this.gbpToSats,
    required this.satsToChf,
    required this.chfToSats,
    required this.satsToBtc,
    required this.btcToSats,
  });
}