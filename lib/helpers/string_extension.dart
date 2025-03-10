import 'package:currency_formatter/currency_formatter.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}


String formatLimit(double value) {
  if (value == value.floor()) {
    return value.toInt().toString();
  } else {
    return value.toStringAsFixed(2);
  }
}

String currencyFormat(double value, String currency, {int decimalPlaces = 2}) {
  switch (currency) {
    case 'USD':
      CurrencyFormat usdSettings = const CurrencyFormat(
        code: 'usd',
        symbol: '\$',
        symbolSide: SymbolSide.left,
        thousandSeparator: ',',
        decimalSeparator: '.',
        symbolSeparator: ' ',
      );
      return CurrencyFormatter.format(value, usdSettings, decimal: decimalPlaces);

    case 'BRL':
      CurrencyFormat brlSettings = const CurrencyFormat(
        code: 'brl',
        symbol: 'R\$',
        symbolSide: SymbolSide.left,
        thousandSeparator: '.',
        decimalSeparator: ',',
        symbolSeparator: ' ',
      );
      return CurrencyFormatter.format(value, brlSettings, decimal: decimalPlaces);

    case 'EUR':
      CurrencyFormat eurSettings = const CurrencyFormat(
        code: 'eur',
        symbol: '€',
        symbolSide: SymbolSide.left,
        thousandSeparator: '.',
        decimalSeparator: ',',
        symbolSeparator: ' ',
      );
      return CurrencyFormatter.format(value, eurSettings, decimal: decimalPlaces);

    default:
      return value.toString();
  }
}

String stripTrailingZeros(String value) {
  // Remove trailing zeros
  value = value.replaceAll(RegExp(r'0+$'), '');
  // If the string ends with '.', remove that too
  if (value.endsWith('.')) {
    value = value.substring(0, value.length - 1);
  }
  return value;
}



