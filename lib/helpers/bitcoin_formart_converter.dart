String btcInDenominationFormatted(double amount, String denomination, [bool isBitcoin = true]) {
  double balance = 0;

  if (!isBitcoin) {
    return (amount / 1000000000).toStringAsFixed(2);
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