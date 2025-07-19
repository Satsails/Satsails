import 'package:Satsails/helpers/string_extension.dart';
import 'package:decimal/decimal.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/currency_conversions.dart';
import 'package:Satsails/providers/settings_provider.dart';

final initializeCurrencyProvider = FutureProvider<CurrencyConversions>((ref) async {
  final currencyBox = await Hive.openBox('currency');

  final usdToEur = currencyBox.get('USDToEUR', defaultValue: 0.93) as double;
  final usdToBrl = currencyBox.get('USDToBRL', defaultValue: 5.08) as double;
  final usdToGbp = currencyBox.get('USDToGBP', defaultValue: 0.78) as double;
  final usdToChf = currencyBox.get('USDToCHF', defaultValue: 0.91) as double;
  final usdToBtc = currencyBox.get('USDToBTC', defaultValue: 0.00002) as double;
  final eurToUsd = currencyBox.get('EURToUSD', defaultValue: 1.075) as double;
  final eurToBrl = currencyBox.get('EURToBRL', defaultValue: 5.45) as double;
  final eurToGbp = currencyBox.get('EURToGBP', defaultValue: 0.84) as double;
  final eurToChf = currencyBox.get('EURToCHF', defaultValue: 0.98) as double;
  final eurToBtc = currencyBox.get('EURToBTC', defaultValue: 0.0000215) as double;
  final brlToUsd = currencyBox.get('BRLToUSD', defaultValue: 0.197) as double;
  final brlToEur = currencyBox.get('BRLToEUR', defaultValue: 0.183) as double;
  final brlToGbp = currencyBox.get('BRLToGBP', defaultValue: 0.154) as double;
  final brlToChf = currencyBox.get('BRLToCHF', defaultValue: 0.179) as double;
  final brlToBtc = currencyBox.get('BRLToBTC', defaultValue: 0.0000039) as double;
  final gbpToUsd = currencyBox.get('GBPToUSD', defaultValue: 1.282) as double;
  final gbpToEur = currencyBox.get('GBPToEUR', defaultValue: 1.190) as double;
  final gbpToBrl = currencyBox.get('GBPToBRL', defaultValue: 6.50) as double;
  final gbpToChf = currencyBox.get('GBPToCHF', defaultValue: 1.17) as double;
  final gbpToBtc = currencyBox.get('GBPToBTC', defaultValue: 0.0000256) as double;
  final chfToUsd = currencyBox.get('CHFToUSD', defaultValue: 1.099) as double;
  final chfToEur = currencyBox.get('CHFToEUR', defaultValue: 1.020) as double;
  final chfToBrl = currencyBox.get('CHFToBRL', defaultValue: 5.58) as double;
  final chfToGbp = currencyBox.get('CHFToGBP', defaultValue: 0.855) as double;
  final chfToBtc = currencyBox.get('CHFToBTC', defaultValue: 0.0000219) as double;

  // BTC-to-fiat rates
  final btcToUsd = currencyBox.get('BTCToUSD', defaultValue: 50000.0) as double;
  final btcToEur = currencyBox.get('BTCToEUR', defaultValue: 46500.0) as double;
  final btcToBrl = currencyBox.get('BTCToBRL', defaultValue: 254000.0) as double;
  final btcToGbp = currencyBox.get('BTCToGBP', defaultValue: 39000.0) as double;
  final btcToChf = currencyBox.get('BTCToCHF', defaultValue: 45500.0) as double;

  // Satoshis rates, derived from BTC where applicable
  final satsToBtc = currencyBox.get('SATSToBTC', defaultValue: 0.00000001) as double;
  final btcToSats = currencyBox.get('BTCToSATS', defaultValue: 100000000.0) as double;
  final satsToUsd = currencyBox.get('SATSToUSD', defaultValue: btcToUsd / 100000000.0) as double;
  final usdToSats = currencyBox.get('USDToSATS', defaultValue: 1 / (btcToUsd / 100000000.0)) as double;
  final satsToEur = currencyBox.get('SATSToEUR', defaultValue: btcToEur / 100000000.0) as double;
  final eurToSats = currencyBox.get('EURToSATS', defaultValue: 1 / (btcToEur / 100000000.0)) as double;
  final satsToBrl = currencyBox.get('SATSToBRL', defaultValue: btcToBrl / 100000000.0) as double;
  final brlToSats = currencyBox.get('BRLToSATS', defaultValue: 1 / (btcToBrl / 100000000.0)) as double;
  final satsToGbp = currencyBox.get('SATSToGBP', defaultValue: btcToGbp / 100000000.0) as double;
  final gbpToSats = currencyBox.get('GBPToSATS', defaultValue: 1 / (btcToGbp / 100000000.0)) as double;
  final satsToChf = currencyBox.get('SATSToCHF', defaultValue: btcToChf / 100000000.0) as double;
  final chfToSats = currencyBox.get('CHFToSATS', defaultValue: 1 / (btcToChf / 100000000.0)) as double;

  return CurrencyConversions(
    usdToEur: usdToEur,
    usdToBrl: usdToBrl,
    usdToGbp: usdToGbp,
    usdToChf: usdToChf,
    usdToBtc: usdToBtc,
    eurToUsd: eurToUsd,
    eurToBrl: eurToBrl,
    eurToGbp: eurToGbp,
    eurToChf: eurToChf,
    eurToBtc: eurToBtc,
    brlToUsd: brlToUsd,
    brlToEur: brlToEur,
    brlToGbp: brlToGbp,
    brlToChf: brlToChf,
    brlToBtc: brlToBtc,
    gbpToUsd: gbpToUsd,
    gbpToEur: gbpToEur,
    gbpToBrl: gbpToBrl,
    gbpToChf: gbpToChf,
    gbpToBtc: gbpToBtc,
    chfToUsd: chfToUsd,
    chfToEur: chfToEur,
    chfToBrl: chfToBrl,
    chfToGbp: chfToGbp,
    chfToBtc: chfToBtc,
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
    btcToSats: btcToSats,
  );
});

// Currency notifier provider
final currencyNotifierProvider = StateNotifierProvider<CurrencyExchangeRatesModel, CurrencyConversions>((ref) {
  final initialCurrency = ref.watch(initializeCurrencyProvider);

  return CurrencyExchangeRatesModel(initialCurrency.when(
    data: (currency) => currency,
    loading: () {
      // Default BTC rates
      const btcToUsd = 50000.0;
      const btcToEur = 46500.0;
      const btcToBrl = 254000.0;
      const btcToGbp = 39000.0;
      const btcToChf = 45500.0;

      // Satoshis defaults
      const satsToBtc = 0.00000001;
      const btcToSats = 100000000.0;
      final satsToUsd = btcToUsd / 100000000.0;
      final usdToSats = 1 / satsToUsd;
      final satsToEur = btcToEur / 100000000.0;
      final eurToSats = 1 / satsToEur;
      final satsToBrl = btcToBrl / 100000000.0;
      final brlToSats = 1 / satsToBrl;
      final satsToGbp = btcToGbp / 100000000.0;
      final gbpToSats = 1 / satsToGbp;
      final satsToChf = btcToChf / 100000000.0;
      final chfToSats = 1 / satsToChf;

      return CurrencyConversions(
        usdToEur: 0.93,
        usdToBrl: 5.08,
        usdToGbp: 0.78,
        usdToChf: 0.91,
        usdToBtc: 0.00002,
        eurToUsd: 1.075,
        eurToBrl: 5.45,
        eurToGbp: 0.84,
        eurToChf: 0.98,
        eurToBtc: 0.0000215,
        brlToUsd: 0.197,
        brlToEur: 0.183,
        brlToGbp: 0.154,
        brlToChf: 0.179,
        brlToBtc: 0.0000039,
        gbpToUsd: 1.282,
        gbpToEur: 1.190,
        gbpToBrl: 6.50,
        gbpToChf: 1.17,
        gbpToBtc: 0.0000256,
        chfToUsd: 1.099,
        chfToEur: 1.020,
        chfToBrl: 5.58,
        chfToGbp: 0.855,
        chfToBtc: 0.0000219,
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
        btcToSats: btcToSats,
      );
    },
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});

final updateCurrencyProvider = FutureProvider.autoDispose<void>((ref) async {
  final currencyModel = ref.watch(currencyNotifierProvider.notifier);
  final settingsModel = ref.read(settingsProvider.notifier);
  bool success = false;

  try {
    await currencyModel.updateRates();
    success = true;
  } catch (e) {
  }

  if (!success) {
    settingsModel.setOnline(false);
  }
});

final formattedCurrencyProvider = Provider.family<String, ({
String amount,
String sourceCurrency,
String targetCurrency,
bool useSymbol,
})>((ref, params) {
  final conversions = ref.watch(currencyNotifierProvider);
  final source = params.sourceCurrency.toUpperCase();
  final target = params.targetCurrency.toUpperCase();
  final useSymbol = params.useSymbol;

  Decimal amountDecimal;
  try {
    amountDecimal = Decimal.parse(params.amount);
  } on FormatException {
    return 'Invalid amount';
  }

  if (source == target) {
    return currencyFormat(amountDecimal, target, useSymbol: useSymbol);
  }

  double rate;
  try {
    rate = _getRate(conversions, source, target);
  } catch (e) {
    return 'Unsupported conversion';
  }
  final Decimal rateDecimal = Decimal.parse(rate.toString());
  final Decimal convertedAmount = amountDecimal * rateDecimal;

  return currencyFormat(convertedAmount, target, useSymbol: useSymbol);
});

double _getRate(CurrencyConversions conversions, String source, String target) {
  if (source == target) return 1.0;
  switch ('${source}To${target}') {
    case 'USDToEUR': return conversions.usdToEur;
    case 'USDToBRL': return conversions.usdToBrl;
    case 'USDToGBP': return conversions.usdToGbp;
    case 'USDToCHF': return conversions.usdToChf;
    case 'USDToBTC': return conversions.usdToBtc;
    case 'EURToUSD': return conversions.eurToUsd;
    case 'EURToBRL': return conversions.eurToBrl;
    case 'EURToGBP': return conversions.eurToGbp;
    case 'EURToCHF': return conversions.eurToChf;
    case 'EURToBTC': return conversions.eurToBtc;
    case 'BRLToUSD': return conversions.brlToUsd;
    case 'BRLToEUR': return conversions.brlToEur;
    case 'BRLToGBP': return conversions.brlToGbp;
    case 'BRLToCHF': return conversions.brlToChf;
    case 'BRLToBTC': return conversions.brlToBtc;
    case 'GBPToUSD': return conversions.gbpToUsd;
    case 'GBPToEUR': return conversions.gbpToEur;
    case 'GBPToBRL': return conversions.gbpToBrl;
    case 'GBPToCHF': return conversions.gbpToChf;
    case 'GBPToBTC': return conversions.gbpToBtc;
    case 'CHFToUSD': return conversions.chfToUsd;
    case 'CHFToEUR': return conversions.chfToEur;
    case 'CHFToBRL': return conversions.chfToBrl;
    case 'CHFToGBP': return conversions.chfToGbp;
    case 'CHFToBTC': return conversions.chfToBtc;
    case 'BTCToUSD': return conversions.btcToUsd;
    case 'BTCToEUR': return conversions.btcToEur;
    case 'BTCToBRL': return conversions.btcToBrl;
    case 'BTCToGBP': return conversions.btcToGbp;
    case 'BTCToCHF': return conversions.btcToChf;
    case 'SATSToUSD': return conversions.satsToUsd;
    case 'USDToSATS': return conversions.usdToSats;
    case 'SATSToEUR': return conversions.satsToEur;
    case 'EURToSATS': return conversions.eurToSats;
    case 'SATSToBRL': return conversions.satsToBrl;
    case 'BRLToSATS': return conversions.brlToSats;
    case 'SATSToGBP': return conversions.satsToGbp;
    case 'GBPToSATS': return conversions.gbpToSats;
    case 'SATSToCHF': return conversions.satsToChf;
    case 'CHFToSATS': return conversions.chfToSats;
    case 'SATSToBTC': return conversions.satsToBtc;
    case 'BTCToSATS': return conversions.btcToSats;
    default: throw Exception('Unsupported conversion from $source to $target');
  }
}

final selectedCurrencyProvider = StateProvider.autoDispose.family<double, String>((ref, currency) {
  final currencyModel = ref.watch(currencyNotifierProvider);

  switch (currency) {
    case 'USD':
      return currencyModel.btcToUsd;
    case 'EUR':
      return currencyModel.btcToEur;
    case 'BRL':
      return currencyModel.btcToBrl;
    case 'CHF':
      return currencyModel.btcToChf;
    case 'GBP':
      return currencyModel.btcToGbp;
    default:
      return 0.0;
  }
});

final conversionProvider = StateProvider.autoDispose.family<String, int>((ref, amount) {
  final settings = ref.watch(settingsProvider);
  final amountDecimal = Decimal.fromInt(amount);

  switch (settings.btcFormat) {
    case 'sats':
      return amountDecimal.toBigInt().toString();
    case 'BTC':
      final btcValue = (amountDecimal / Decimal.fromInt(100000000)).toDecimal(scaleOnInfinitePrecision: 8);
      return btcValue.toStringAsFixed(8);
    default:
      return "Invalid format";
  }
});

final conversionToFiatProvider = StateProvider.autoDispose.family<String, int>((ref, amount) {
  final settings = ref.watch(settingsProvider);
  final rates = ref.watch(currencyNotifierProvider);
  final amountDecimal = Decimal.fromInt(amount);

  final btcAmount = (amountDecimal / Decimal.fromInt(100000000)).toDecimal(scaleOnInfinitePrecision: 8);

  Decimal fiatValue;

  switch (settings.currency) {
    case 'USD':
      fiatValue = btcAmount * Decimal.parse(rates.btcToUsd.toString());
      break;
    case 'BRL':
      fiatValue = btcAmount * Decimal.parse(rates.btcToBrl.toString());
      break;
    case 'EUR':
      fiatValue = btcAmount * Decimal.parse(rates.btcToEur.toString());
      break;
    case 'CHF':
      fiatValue = btcAmount * Decimal.parse(rates.btcToChf.toString());
      break;
    case 'GBP':
      fiatValue = btcAmount * Decimal.parse(rates.btcToGbp.toString());
      break;
    default:
      return "Invalid format";
  }

  return fiatValue.toStringAsFixed(2);
});

final selectedCurrencyProviderFromUSD = StateProvider.autoDispose.family<double, String>((ref, currency) {
  final currencyModel = ref.watch(currencyNotifierProvider);

  switch (currency) {
    case 'USD':
      return 1;
    case 'EUR':
      return currencyModel.usdToEur;
    case 'GBP':
      return currencyModel.usdToGbp;
    case 'CHF':
      return currencyModel.usdToChf;
    case 'BRL':
      return currencyModel.usdToBrl;
    default:
      return 0.0;
  }
});