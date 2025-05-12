import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';

final isBitcoinInputProvider = StateProvider.autoDispose<bool>((ref) => true);
final defaultDropdownValueProvider = StateProvider.autoDispose<String>((ref) {
  final format = ref.watch(settingsProvider).btcFormat;
  switch (format) {
    case 'BTC':
      return 'BTC';
    case 'sats':
      return 'Sats';
    default:
      return 'BTC';
  }
});
final inputCurrencyProvider = StateProvider.autoDispose<String>((ref) => ref.watch(defaultDropdownValueProvider));
final inputAmountProvider = StateProvider<String>((ref) => '0.0');
final shouldUpdateBoltzLiquidReceive = StateProvider.autoDispose<bool>((ref) => true);

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
    default:
      return amount;
  }
}

int calculateAmountInSatsToDisplay(String amount, String currency, currencyConverter) {
  if (amount == '' || amount == '0.0') {
    return 0;
  }

  switch (currency) {
    case 'BTC':
      return (double.parse(amount) * 100000000).toInt();
    case 'USD':
      return (double.parse(amount) * currencyConverter.usdToBtc * 100000000).toInt();
    case 'EUR':
      return (double.parse(amount) * currencyConverter.eurToBtc * 100000000).toInt();
    case 'BRL':
      return (double.parse(amount) * currencyConverter.brlToBtc * 100000000).toInt();
    case 'Sats':
      return (double.parse(amount)).toInt();
    default:
      return (double.parse(amount) * 100000000).toInt();
  }
}

String calculateAmountToDisplayFromFiat(String amount, String currency, currencyConverter) {
  switch (currency) {
    case 'USD':
      return (double.parse(amount) * currencyConverter.usdToBtc).toStringAsFixed(8);
    case 'EUR':
      return (double.parse(amount) * currencyConverter.usdToBtc).toStringAsFixed(8);
    case 'BRL':
      return (double.parse(amount) * currencyConverter.brlToBtc).toStringAsFixed(8);
    default:
      return "0";
  }
}

String calculateAmountToDisplayFromFiatInSats(String amount, String currency, currencyConverter) {
  switch (currency) {
    case 'USD':
      return (double.parse(amount) * currencyConverter.usdToBtc * 100000000).toStringAsFixed(0);
    case 'EUR':
      return (double.parse(amount) * currencyConverter.eurToBtc * 100000000).toStringAsFixed(0);
    case 'BRL':
      return (double.parse(amount) * currencyConverter.brlToBtc * 100000000).toStringAsFixed(0);
    default:
      return "0";
  }
}

String calculateAmountInSelectedCurrency(int sats, String currency, currencyConverter) {
  switch (currency) {
    case 'BTC':
      return (sats / 100000000).toStringAsFixed(8);
    case 'USD':
      return (sats / 100000000 / currencyConverter.usdToBtc).toString();
    case 'EUR':
      return (sats / 100000000 / currencyConverter.eurToBtc).toString();
    case 'BRL':
      return (sats / 100000000 / currencyConverter.brlToBtc).toString();
    case 'Sats':
      return sats.toString();
    default:
      return (sats / 100000000).toStringAsFixed(8);
  }
}

final bitcoinReceiveAddressAmountProvider = Provider.autoDispose<String>((ref) {
  final address = ref.read(addressProvider).bitcoinAddress;
  final amount = ref.watch(inputAmountProvider);
  final currency = ref.watch(inputCurrencyProvider);
  final currencyConverter = ref.read(currencyNotifierProvider);

  if (amount == '' || amount == '0.0') {
    return address;
  } else {
    final amountToDisplay = calculateAmountToDisplay(amount, currency, currencyConverter);
    return 'bitcoin:$address?amount=$amountToDisplay';
  }
});

final liquidReceiveAddressAmountProvider = FutureProvider.autoDispose<String>((ref) async {
  final address = await ref.read(liquidAddressProvider.future).then((value) => value.confidential);
  final amount = ref.watch(inputAmountProvider);
  final currency = ref.watch(inputCurrencyProvider);
  final currencyConverter = ref.read(currencyNotifierProvider);

  if (amount == '' || amount == '0.0') {
    return address ;
  } else {
    final amountToDisplay = calculateAmountToDisplay(amount, currency, currencyConverter);
    return 'liquidnetwork:$address?amount=$amountToDisplay';
  }
});

final lnAmountProvider = FutureProvider.autoDispose<int>((ref) async {
  final amount = ref.watch(inputAmountProvider);
  final currency = ref.watch(inputCurrencyProvider);
  final currencyConverter = ref.read(currencyNotifierProvider);
  return calculateAmountInSatsToDisplay(amount, currency, currencyConverter);
});