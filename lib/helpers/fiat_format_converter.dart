String fiatInDenominationFormatted(int amount) {
  double balance = amount / 100000000;

  if (balance == balance.floor() || (balance * 100).floor() / 100 == 0.0) {
    return balance.toInt().toString();
  } else {
    double truncated = (balance * 100).floor() / 100;
    return truncated.toStringAsFixed(2);
  }
}