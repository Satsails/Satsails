String fiatInDenominationFormatted(int amount) {
  double balance = 0;

  balance = (amount / 100000000);

  return balance.toStringAsFixed(2);
}