String btcInDenominationFormatted(double amount, String denomination) {
  double balance;

  switch (denomination) {
    case 'sats':
      balance = amount;
      return balance.toStringAsFixed(0);
    case 'BTC':
      balance = (amount / 100000000);
      return balance.toStringAsFixed(8);
    case 'mBTC':
      balance = (amount / 100000000) * 1000;
      return balance.toStringAsFixed(5);
    case 'bits':
      balance = (amount / 100000000) * 1000000;
      return balance.toStringAsFixed(2);
    default:
      return "0";
  }
}