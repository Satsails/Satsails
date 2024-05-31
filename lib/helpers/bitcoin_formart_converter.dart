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
    return balance.toString();
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