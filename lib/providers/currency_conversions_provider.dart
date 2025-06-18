import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/currency_conversions.dart';
import 'package:Satsails/providers/settings_provider.dart';


final initializeCurrencyProvider = FutureProvider<CurrencyConversions>((ref) async {
  final currencyBox = await Hive.openBox('currency');

  // Read all 30 rates from Hive with default values, using uppercase keys
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
  final btcToUsd = currencyBox.get('BTCToUSD', defaultValue: 50000.0) as double;
  final btcToEur = currencyBox.get('BTCToEUR', defaultValue: 46500.0) as double;
  final btcToBrl = currencyBox.get('BTCToBRL', defaultValue: 254000.0) as double;
  final btcToGbp = currencyBox.get('BTCToGBP', defaultValue: 39000.0) as double;
  final btcToChf = currencyBox.get('BTCToCHF', defaultValue: 45500.0) as double;

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
  );
});

final currencyNotifierProvider = StateNotifierProvider<CurrencyExchangeRatesModel, CurrencyConversions>((ref) {
  final initialCurrency = ref.watch(initializeCurrencyProvider);

  return CurrencyExchangeRatesModel(initialCurrency.when(
    data: (currency) => currency,
    loading: () => CurrencyConversions(
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
      btcToUsd: 50000.0,
      btcToEur: 46500.0,
      btcToBrl: 254000.0,
      btcToGbp: 39000.0,
      btcToChf: 45500.0,
    ),
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});

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

final updateCurrencyProvider = FutureProvider<void>((ref) async {
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