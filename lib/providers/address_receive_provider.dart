import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';

final isBitcoinInputProvider = StateProvider.autoDispose<bool>((ref) => true);
final inputCurrencyProvider = StateProvider.autoDispose<String>((ref) => 'BTC');
final inputAmountProvider = StateProvider<String>((ref) => '0.0');

String calculateAmountToDisplay(String amount, String currency, currencyConverter) {
  switch (currency) {
    case 'BTC':
      return double.parse(amount).toStringAsFixed(8);
    case 'USD':
      return (double.parse(amount) * currencyConverter.usdToBtc).toStringAsFixed(8);
    case 'EUR':
      return (double.parse(amount) * currencyConverter.eurToBtc).toStringAsFixed(8);
    case 'BRL':
      return (double.parse(amount) * currencyConverter.brlToBtc).toStringAsFixed(8);
    case 'Sats':
      return (double.parse(amount) / 100000000).toStringAsFixed(8);
    case 'mBTC':
      return (double.parse(amount) / 1000).toStringAsFixed(8);
    case 'bits':
      return (double.parse(amount) / 1000000).toStringAsFixed(8);
    default:
      return amount;
  }
}

final bitcoinReceiveAddressAmountProvider = FutureProvider.autoDispose<String>((ref) async {
  final address = await ref.read(bitcoinAddressProvider.future);
  final amount = ref.watch(inputAmountProvider);
  final currency = ref.watch(inputCurrencyProvider);
  final currencyConverter = ref.watch(currencyNotifierProvider);

  if (amount == '' || amount == '0.0') {
    return address;
  } else {
    final amountToDisplay = calculateAmountToDisplay(amount, currency, currencyConverter);
    return 'bitcoin:$address?amount=${amountToDisplay}';
  }
});

final liquidReceiveAddressAmountProvider = FutureProvider.autoDispose<String>((ref) async {
  final address = await ref.read(liquidAddressProvider.future);
  final amount = ref.watch(inputAmountProvider);
  final currency = ref.watch(inputCurrencyProvider);
  final currencyConverter = ref.watch(currencyNotifierProvider);

  if (amount == '' || amount == '0.0') {
    return address;
  } else {
    final amountToDisplay = calculateAmountToDisplay(amount, currency, currencyConverter);
    return 'liquidnetwork:$address?amount=${amountToDisplay}';
  }
});