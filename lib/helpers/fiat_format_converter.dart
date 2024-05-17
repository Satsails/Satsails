String fiatInDenominationFormatted(int amount) {
  double balance = amount / 100000000;

  if (balance == balance.floor()) {
    return balance.toInt().toString();
  } else {
    double truncated = (balance * 100).floor() / 100;
    return truncated.toStringAsFixed(2);
  }
}