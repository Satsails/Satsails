import 'dart:math';

String fiatInDenominationFormatted(int amount) {
  double balance = amount / 100000000;

  if (balance == balance.floor() || (balance * 100).floor() / 100 == 0.0) {
    return balance.toInt().toString();
  } else {
    double truncated = (balance * 100).floor() / 100;
    return truncated.toStringAsFixed(2);
  }
}

const cryptoAssets = ['L-BTC'];
const fiatLikeAssets = ['USDT', 'Eurox', 'Depix'];

String formatAssetAmount(String asset, int amount, String btcFormat) {
  int precision;
  bool isSats = btcFormat == 'sats' && cryptoAssets.contains(asset);

  if (cryptoAssets.contains(asset)) {
    precision = isSats ? 0 : 8;
  } else if (fiatLikeAssets.contains(asset)) {
    precision = 8;
  } else {
    precision = 8; // Default precision for unrecognized assets
  }

  final value = isSats ? amount.toDouble() : amount / pow(10, precision);
  String formatted = value.toStringAsFixed(precision);
  if (!isSats) {
    formatted = formatted.replaceAll(RegExp(r'0+$'), ''); // Remove trailing zeros
    if (formatted.endsWith('.')) {
      formatted = formatted.substring(0, formatted.length - 1); // Remove trailing decimal point
    }
  }
  return '$formatted $asset';
}