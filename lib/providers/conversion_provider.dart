import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';

final conversionProvider = StateProvider.autoDispose.family<String, int>((ref, amount) {
  final settings = ref.watch(settingsProvider);
  final num balance;

  switch (settings.btcFormat) {
    case 'sats':
      balance = amount;
      return "${balance.toInt()}";
    case 'BTC':
      balance = amount / 100000000;
      return balance.toStringAsFixed(8);
    default:
      return "Invalid format";
  }
});

final conversionToFiatProvider = StateProvider.autoDispose.family<String, int>((ref, amount) {
  final settings = ref.watch(settingsProvider);
  final rates = ref.watch(currencyNotifierProvider);
  final double balance;

  switch (settings.currency) {
    case 'USD':
      balance = amount * rates.btcToUsd;
      return balance.toStringAsFixed(2);
    case 'BRL':
      balance = amount * rates.btcToBrl;
      return balance.toStringAsFixed(2);
    case 'EUR':
      balance = amount * rates.btcToEur;
      return balance.toStringAsFixed(2);
    case 'CHF':
      balance = amount * rates.btcToChf;
      return balance.toStringAsFixed(2);
    case 'GBP':
      balance = amount * rates.btcToGbp;
      return balance.toStringAsFixed(2);
    default:
      return "Invalid format";
  }
});