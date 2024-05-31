import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/currency_conversions.dart';
import 'package:Satsails/providers/settings_provider.dart';

final initializeCurrencyProvider = FutureProvider.autoDispose<CurrencyConversions>((ref) async {
  final currencyBox = await Hive.openBox('currency');
  final usdtoBrl = currencyBox.get('usdToBrl', defaultValue: 5.08) as double;
  final usdtoEur = currencyBox.get('usdToEur', defaultValue: 0.93) as double;
  final usdtoBtc = currencyBox.get('usdToBtc', defaultValue: 0.000014) as double;
  final eurtoUsd = currencyBox.get('eurToUsd', defaultValue: 1/usdtoEur) as double;
  final eurtoBrl = currencyBox.get('eurToBrl', defaultValue: 5.45) as double;
  final eurtoBtc = currencyBox.get('eurToBtc', defaultValue: 0.000015) as double;
  final brltoUsd = currencyBox.get('brlToUsd', defaultValue: 1/usdtoBrl) as double;
  final brltoEur = currencyBox.get('brlToEur', defaultValue: 1/eurtoBrl) as double;
  final brltoBtc = currencyBox.get('brlToBtc', defaultValue: 0.0000028) as double;


  return CurrencyConversions(
    usdToEur: usdtoEur,
    usdToBrl: usdtoBrl,
    usdToBtc: usdtoBtc,
    eurToUsd: eurtoUsd,
    eurToBrl: eurtoBrl,
    eurToBtc: eurtoBtc,
    brlToUsd: brltoUsd,
    brlToEur: brltoEur,
    brlToBtc: brltoBtc,
    btcToUsd: 1/usdtoBtc,
    btcToEur: 1/eurtoBtc,
    btcToBrl: 1/brltoBtc,
  );
});

final currencyNotifierProvider = StateNotifierProvider.autoDispose<CurrencyExchangeRatesModel, CurrencyConversions>((ref) {
  final initialCurrency = ref.watch(initializeCurrencyProvider);

  return CurrencyExchangeRatesModel(initialCurrency.when(
    data: (currency) => currency,
    loading: () => CurrencyConversions(
      usdToEur: 5.08,
      usdToBrl: 0.93,
      usdToBtc: 0.000014,
      eurToUsd: 1/0.93,
      eurToBrl: 5.45,
      eurToBtc: 0.000015,
      brlToUsd: 1/5.08,
      brlToEur: 1/5.45,
      brlToBtc: 0.0000028,
      btcToUsd: 1/0.000014,
      btcToEur: 1/0.000015,
      btcToBrl: 1/0.0000028,
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
    default:
      return 0.0;
  }
});

final updateCurrencyProvider = FutureProvider.autoDispose<void>((ref) async {
  final currencyModel = ref.watch(currencyNotifierProvider.notifier);
  final settingsModel = ref.read(settingsProvider.notifier);
  bool success = false;

    try {
      await currencyModel.updateRates();
      success = true;
    } catch (e) {}

  if (!success) {
    settingsModel.setOnline(false);
  }
});