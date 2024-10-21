import 'dart:math' as math;

String btcInDenominationFormatted(num amount, String denomination, [bool isBitcoin = true]) {
  num balance = 0;

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
    default:
      return "0";
  }

  if (balance == balance.floor()) {
    return balance.toInt().toString();
  } else {
    switch (denomination) {
      case 'BTC':
        return balance.toStringAsFixed(8);
      default:
        return balance.toStringAsFixed(0);
    }
  }
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