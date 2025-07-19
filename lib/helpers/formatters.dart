import 'dart:math';
import 'dart:math' as math;
import 'package:decimal/decimal.dart';

String fiatInDenominationFormatted(int amount) {
  final amountDecimal = Decimal.fromInt(amount);
  final divisor = Decimal.fromInt(100000000);
  final rationalValue = amountDecimal / divisor;
  final decimalValue = rationalValue.toDecimal(scaleOnInfinitePrecision: 8);
  return decimalValue.toStringAsFixed(2);
}

num truncateToDecimalPlaces(num number, int decimalPlaces) {
  num mod = math.pow(10.0, decimalPlaces);
  return ((number * mod).floor() / mod);
}


num btcInDenominationNum(num amount, String denomination, [bool isBitcoin = true]) {
  num balance = 0;

  if (!isBitcoin) {
    return truncateToDecimalPlaces(amount / 100000000, 2);
  }

  switch (denomination) {
    case 'sats':
      balance = amount;
      break;
    case 'BTC':
      balance = (amount / 100000000);
      balance = truncateToDecimalPlaces(balance, 8);
      break;
    default:
      return 0;
  }

  return balance;
}

String btcInDenominationFormatted(int amount, String denomination, [bool isBitcoin = true]) {
  final amountDecimal = Decimal.fromInt(amount);

  if (!isBitcoin) {
    final rationalValue = amountDecimal / Decimal.fromInt(100000000);
    final decimalValue = rationalValue.toDecimal(scaleOnInfinitePrecision: 8);
    return decimalValue.toStringAsFixed(2);
  }

  Decimal balance;

  switch (denomination) {
    case 'sats':
      balance = amountDecimal;
      break;
    case 'BTC':
      balance = (amountDecimal / Decimal.fromInt(100000000))
          .toDecimal(scaleOnInfinitePrecision: 8);
      break;
    default:
      return "0";
  }

  if (balance.isInteger) {
    return balance.toBigInt().toString();
  } else {
    switch (denomination) {
      case 'BTC':
        return balance.toStringAsFixed(8);
      default:
        return balance.round().toBigInt().toString();
    }
  }
}

const cryptoAssets = ['L-BTC'];
const fiatLikeAssets = ['USDT', 'Eurox', 'Depix'];

String formatAssetAmount(String asset, int amount, String btcFormat) {
  int precision;
  bool isSats = btcFormat == 'sats' && cryptoAssets.contains(asset);

  if (cryptoAssets.contains(asset)) {
    precision = isSats ? 0 : 8;
  } else if (fiatLikeAssets.contains(asset)) {
    precision = 8;
  } else {
    precision = 8;
  }

  final value = isSats ? amount.toDouble() : amount / pow(10, precision);
  String formatted = value.toStringAsFixed(precision);
  if (!isSats) {
    formatted = formatted.replaceAll(RegExp(r'0+$'), '');
    if (formatted.endsWith('.')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
  }
  return '$formatted $asset';
}