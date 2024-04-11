import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/providers/settings_provider.dart';

final conversionProvider = StateProvider.autoDispose.family<String, int>((ref, amount) {
  final settings = ref.watch(settingsProvider);
  final balance;

  switch (settings.btcFormat) {
    case 'sats':
      balance = amount;
      return "${balance.toInt()}";
    case 'BTC':
      balance = amount / 100000000;
      return balance.toStringAsFixed(8);
    case 'mBTC':
      balance = (amount / 100000000) * 1000;
      return balance.toStringAsFixed(5);
    case 'bits':
      balance = (amount / 100000000) * 1000000;
      return balance.toStringAsFixed(2);
    default:
      return "Invalid format";
  }
});