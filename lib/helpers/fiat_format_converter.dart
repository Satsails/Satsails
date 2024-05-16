String fiatInDenominationFormatted(int amount) {
  double balance = amount / 100000000;

  if (balance == balance.floor()) {
    return balance.toInt().toString();
  } else {
    return balance.toStringAsFixed(2);
  }
}