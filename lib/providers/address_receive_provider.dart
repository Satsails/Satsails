import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';

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
  if (amount.isEmpty || (double.tryParse(amount) ?? 0.0) == 0.0) {
    return '0.00000000';
  }

  final amountDecimal = Decimal.parse(amount);
  final satsFactor = Decimal.fromInt(100000000);
  Decimal btcResult;

  switch (currency) {
    case 'BTC':
      btcResult = amountDecimal;
      break;
    case 'USD':
      btcResult = amountDecimal * Decimal.parse(currencyConverter.usdToBtc.toString());
      break;
    case 'GBP':
      btcResult = amountDecimal * Decimal.parse(currencyConverter.gbpToBtc.toString());
      break;
    case 'CHF':
      btcResult = amountDecimal * Decimal.parse(currencyConverter.chfToBtc.toString());
      break;
    case 'EUR':
      btcResult = amountDecimal * Decimal.parse(currencyConverter.eurToBtc.toString());
      break;
    case 'BRL':
      btcResult = amountDecimal * Decimal.parse(currencyConverter.brlToBtc.toString());
      break;
    case 'Sats':
      btcResult = (amountDecimal / satsFactor).toDecimal();
      break;
    default:
      btcResult = amountDecimal; // Assuming default is BTC
      break;
  }
  return btcResult.toStringAsFixed(8);
}

int calculateAmountInSatsToDisplay(String amount, String currency, currencyConverter) {
  if (amount.isEmpty || (double.tryParse(amount) ?? 0.0) == 0.0) {
    return 0;
  }

  final amountDecimal = Decimal.parse(amount);
  final satsFactor = Decimal.fromInt(100000000);
  Decimal result;

  switch (currency) {
    case 'BTC':
      result = amountDecimal * satsFactor;
      break;
    case 'USD':
      result = amountDecimal * Decimal.parse(currencyConverter.usdToBtc.toString()) * satsFactor;
      break;
    case 'EUR':
      result = amountDecimal * Decimal.parse(currencyConverter.eurToBtc.toString()) * satsFactor;
      break;
    case 'GBP':
      result = amountDecimal * Decimal.parse(currencyConverter.gbpToBtc.toString()) * satsFactor;
      break;
    case 'CHF':
      result = amountDecimal * Decimal.parse(currencyConverter.chfToBtc.toString()) * satsFactor;
      break;
    case 'BRL':
      result = amountDecimal * Decimal.parse(currencyConverter.brlToBtc.toString()) * satsFactor;
      break;
    case 'Sats':
      result = amountDecimal;
      break;
    default:
      result = amountDecimal * satsFactor; // Assuming default is BTC
      break;
  }
  return result.toBigInt().toInt();
}

/// Calculates the BTC amount from a fiat input, formatted to 8 decimal places.
String calculateAmountToDisplayFromFiat(String amount, String currency, currencyConverter) {
  if (amount.isEmpty || (double.tryParse(amount) ?? 0.0) == 0.0) {
    return '0.00000000';
  }

  final amountDecimal = Decimal.parse(amount);
  Decimal btcResult;

  switch (currency) {
    case 'USD':
      btcResult = amountDecimal * Decimal.parse(currencyConverter.usdToBtc.toString());
      break;
    case 'EUR':
      btcResult = amountDecimal * Decimal.parse(currencyConverter.eurToBtc.toString());
      break;
    case 'GBP':
      btcResult = amountDecimal * Decimal.parse(currencyConverter.gbpToBtc.toString());
      break;
    case 'CHF':
      btcResult = amountDecimal * Decimal.parse(currencyConverter.chfToBtc.toString());
      break;
    case 'BRL':
      btcResult = amountDecimal * Decimal.parse(currencyConverter.brlToBtc.toString());
      break;
    default:
      btcResult = Decimal.zero;
      break;
  }
  return btcResult.toStringAsFixed(8);
}

/// Calculates the Sats amount from a fiat input, formatted to 0 decimal places.
String calculateAmountToDisplayFromFiatInSats(String amount, String currency, currencyConverter) {
  if (amount.isEmpty || (double.tryParse(amount) ?? 0.0) == 0.0) {
    return '0';
  }

  final amountDecimal = Decimal.parse(amount);
  final satsFactor = Decimal.fromInt(100000000);
  Decimal satsResult;

  switch (currency) {
    case 'USD':
      satsResult = amountDecimal * Decimal.parse(currencyConverter.usdToBtc.toString()) * satsFactor;
      break;
    case 'EUR':
      satsResult = amountDecimal * Decimal.parse(currencyConverter.eurToBtc.toString()) * satsFactor;
      break;
    case 'GBP':
      satsResult = amountDecimal * Decimal.parse(currencyConverter.gbpToBtc.toString()) * satsFactor;
      break;
    case 'CHF':
      satsResult = amountDecimal * Decimal.parse(currencyConverter.chfToBtc.toString()) * satsFactor;
      break;
    case 'BRL':
      satsResult = amountDecimal * Decimal.parse(currencyConverter.brlToBtc.toString()) * satsFactor;
      break;
    default:
      satsResult = Decimal.zero;
      break;
  }
  // Use toStringAsFixed(0) for correct rounding to a whole number string
  return satsResult.toStringAsFixed(0);
}

String calculateAmountInSelectedCurrency(int sats, String currency, currencyConverter) {
  if (sats == 0) {
    switch (currency) {
      case 'BTC':
        return '0.00000000';
      case 'Sats':
        return '0';
      case 'USD':
      case 'EUR':
      case 'GBP':
      case 'CHF':
      case 'BRL':
        return '0.00';
      default:
        return '0.00000000';
    }
  }

  final satsDecimal = Decimal.fromInt(sats);
  final satsFactor = Decimal.fromInt(100000000);

  final btcAmount = (satsDecimal / satsFactor).toDecimal();

  Decimal result;

  Decimal _getRate(String rateString) {
    final rate = Decimal.tryParse(rateString);
    if (rate == null || rate == Decimal.zero) {
      return Decimal.zero;
    }
    return rate;
  }

  const int precisionScale = 20;

  switch (currency) {
    case 'BTC':
      return btcAmount.toStringAsFixed(8);

    case 'USD':
      final rate = _getRate(currencyConverter.usdToBtc.toString());
      if (rate == Decimal.zero) return '0.00';

      result = (btcAmount / rate).toDecimal(scaleOnInfinitePrecision: precisionScale);
      return result.toStringAsFixed(2);

    case 'EUR':
      final rate = _getRate(currencyConverter.eurToBtc.toString());
      if (rate == Decimal.zero) return '0.00';

      result = (btcAmount / rate).toDecimal(scaleOnInfinitePrecision: precisionScale);
      return result.toStringAsFixed(2);

    case 'GBP':
      final rate = _getRate(currencyConverter.gbpToBtc.toString());
      if (rate == Decimal.zero) return '0.00';

      // FIX 2 (Applied here):
      result = (btcAmount / rate).toDecimal(scaleOnInfinitePrecision: precisionScale);
      return result.toStringAsFixed(2);

    case 'CHF':
      final rate = _getRate(currencyConverter.chfToBtc.toString());
      if (rate == Decimal.zero) return '0.00';

      // FIX 2 (Applied here):
      result = (btcAmount / rate).toDecimal(scaleOnInfinitePrecision: precisionScale);
      return result.toStringAsFixed(2);

    case 'BRL':
      final rate = _getRate(currencyConverter.brlToBtc.toString());
      if (rate == Decimal.zero) return '0.00';

      // FIX 2 (Applied here):
      result = (btcAmount / rate).toDecimal(scaleOnInfinitePrecision: precisionScale);
      return result.toStringAsFixed(2);

    case 'Sats':
      return satsDecimal.toStringAsFixed(0);

    default:
    // This now works because btcAmount is a Decimal
      return btcAmount.toStringAsFixed(8); // Assume default is BTC
  }
}

final bitcoinReceiveAddressAmountProvider = StateProvider.autoDispose<String>((ref) {
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

final liquidReceiveAddressAmountProvider = StateProvider.autoDispose<String>((ref) {
  final address = ref.read(addressProvider).liquidAddress;
  final amount = ref.watch(inputAmountProvider);
  final currency = ref.watch(inputCurrencyProvider);
  final currencyConverter = ref.read(currencyNotifierProvider);

  if (amount == '' || amount == '0.0') {
    return address;
  } else {
    final amountToDisplay = calculateAmountToDisplay(amount, currency, currencyConverter);
    return 'liquidnetwork:$address?amount=$amountToDisplay';
  }
});

final lnAmountProvider = StateProvider.autoDispose<int>((ref) {
  final amount = ref.watch(inputAmountProvider);
  final currency = ref.watch(inputCurrencyProvider);
  final currencyConverter = ref.read(currencyNotifierProvider);
  return calculateAmountInSatsToDisplay(amount, currency, currencyConverter);
});