import 'dart:math' as math;

String btcInDenominationFormatted(double amount, String denomination, [bool isBitcoin = true]) {
  double balance = 0;

  if (!isBitcoin) {
    return (amount / 100000000).toStringAsFixed(2);
  }

  switch (denomination) {
    case 'sats':
      balance = amount;
      break;
    case 'BTC':
      balance = (amount / 100000000);
      break;
    case 'mBTC':
      balance = (amount / 100000000) * 1000;
      break;
    case 'bits':
      balance = (amount / 100000000) * 1000000;
      break;
    default:
      return "0";
  }

  if (balance == balance.floor()) {
    return balance.toInt().toString();
  } else {
    switch (denomination) {
      case 'BTC':
        return balance.toStringAsFixed(8);
      case 'mBTC':
        return balance.toStringAsFixed(5);
      case 'bits':
        return balance.toStringAsFixed(2);
      default:
        return balance.toStringAsFixed(0);
    }
  }
}

num truncateToDecimalPlaces(num number, int decimalPlaces) {
  num mod = math.pow(10.0, decimalPlaces);
  return ((number * mod).toInt().toDouble() / mod);
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
      break;
    case 'mBTC':
      balance = (amount / 100000000) * 1000;
      break;
    case 'bits':
      balance = (amount / 100000000) * 1000000;
      break;
    default:
      return 0;
  }

  return truncateToDecimalPlaces(balance, 8);
}