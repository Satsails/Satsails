import 'package:currency_formatter/currency_formatter.dart';
import 'package:decimal/decimal.dart';

// Currency format settings defined as constants
const CurrencyFormat usdSettings = CurrencyFormat(
  code: 'usd',
  symbol: '\$',
  symbolSide: SymbolSide.left,
  thousandSeparator: ',',
  decimalSeparator: '.',
  symbolSeparator: ' ',
);

const CurrencyFormat brlSettings = CurrencyFormat(
  code: 'brl',
  symbol: 'R\$',
  symbolSide: SymbolSide.left,
  thousandSeparator: '.',
  decimalSeparator: ',',
  symbolSeparator: ' ',
);

const CurrencyFormat eurSettings = CurrencyFormat(
  code: 'eur',
  symbol: '€',
  symbolSide: SymbolSide.left,
  thousandSeparator: '.',
  decimalSeparator: ',',
  symbolSeparator: ' ',
);

const CurrencyFormat gbpSettings = CurrencyFormat(
  code: 'gbp',
  symbol: '£',
  symbolSide: SymbolSide.left,
  thousandSeparator: '.',
  decimalSeparator: ',',
  symbolSeparator: ' ',
);

// New FIAT settings for generic formatting without a symbol
const CurrencyFormat fiatSettings = CurrencyFormat(
  code: 'fiat',
  symbol: '',
  symbolSide: SymbolSide.left,
  thousandSeparator: '.',
  decimalSeparator: ',',
  symbolSeparator: '',
);


const CurrencyFormat chfSettings = CurrencyFormat(
  code: 'chf',
  symbol: 'CHF',
  symbolSide: SymbolSide.left,
  thousandSeparator: '.',
  decimalSeparator: ',',
  symbolSeparator: ' ',
);

const CurrencyFormat btcSettings = CurrencyFormat(
  code: 'btc',
  symbol: 'BTC',
  symbolSide: SymbolSide.right,
  thousandSeparator: '',
  decimalSeparator: '.',
  symbolSeparator: ' ',
);

const CurrencyFormat satsSettings = CurrencyFormat(
  code: 'sats',
  symbol: 'sats',
  symbolSide: SymbolSide.right,
  thousandSeparator: ',',
  decimalSeparator: '',
  symbolSeparator: ' ',
);

// String extension for capitalization (unchanged)
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

String currencyFormat(Decimal value, String currency, {int decimalPlaces = 2, bool useSymbol = true}) {
  String upperCurrency = currency.toUpperCase();
  CurrencyFormat settings;

  switch (upperCurrency) {
    case 'USD':
      settings = usdSettings;
      break;
    case 'BRL':
      settings = brlSettings;
      break;
    case 'EUR':
      settings = eurSettings;
      break;
    case 'GBP':
      settings = gbpSettings;
      break;
    case 'CHF':
      settings = chfSettings;
      break;
    case 'FIAT':
      settings = fiatSettings;
      decimalPlaces = 2;
      useSymbol = false;
      break;
    case 'BTC':
      String formatted = CurrencyFormatter.format(value, btcSettings, decimal: 8);
      List<String> parts = formatted.split(' ');
      String numericPart = parts[0];
      String stripped = stripTrailingZeros(numericPart);
      return useSymbol && parts.length > 1 ? '$stripped ${parts[1]}' : stripped;
    case 'SATS':
      Decimal satsValue = value; // Ensure integer value for satoshis
      String formatted = CurrencyFormatter.format(satsValue, satsSettings, decimal: 0);
      if (!useSymbol) {
        return formatted.split(' ')[0];
      }
      return formatted;
    default:
      return value.toString();
  }

  String formatted = CurrencyFormatter.format(value, settings, decimal: decimalPlaces);
  if (!useSymbol) {
    String symbol = settings.symbol;
    String separator = settings.symbolSeparator;
    if (settings.symbolSide == SymbolSide.left) {
      formatted = formatted.replaceFirst('$symbol$separator', '');
    } else {
      formatted = formatted.replaceFirst('$separator$symbol', '');
    }
  }
  return formatted;
}

String stripTrailingZeros(String value) {
  value = value.replaceAll(RegExp(r'0+$'), '');
  if (value.endsWith('.')) {
    value = value.substring(0, value.length - 1);
  }
  return value;
}