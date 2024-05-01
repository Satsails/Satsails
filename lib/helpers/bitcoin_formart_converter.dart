String btcInDenominationFormatted(double amount, String denomination) {
  double balance = 0;

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
    return balance.toString(); // You can adjust the number of digits after the decimal point
  }
}