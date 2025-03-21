import 'package:Satsails/models/currency_conversions.dart';
import 'package:Satsails/providers/coingecko_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/settings_provider.dart'; // Assuming this exists
import 'package:Satsails/providers/currency_conversions_provider.dart'; // Assuming this exists

class BalanceCard extends ConsumerWidget {
  final String assetName;
  final Color color;

  const BalanceCard({required this.assetName, required this.color, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletBalance = ref.watch(balanceNotifierProvider);
    final settings = ref.watch(settingsProvider);
    final conversions = ref.watch(currencyNotifierProvider);

    // Determine native balance and equivalent
    String nativeBalance;
    String equivalentBalance;

    switch (assetName) {
      case 'BTC':
        nativeBalance =
            walletBalance.btcBalanceInDenominationFormatted(settings.btcFormat);
        double balanceInBtc = walletBalance.btcBalance / 100000000;
        double equivalent = balanceInBtc *
            _getRate(settings.currency, conversions);
        equivalentBalance =
        '${equivalent.toStringAsFixed(2)} ${settings.currency}';
        break;
      case 'LBTC':
        nativeBalance = walletBalance.liquidBalanceInDenominationFormatted(
            settings.btcFormat);
        double balanceInBtc = walletBalance.liquidBalance / 100000000;
        double equivalent = balanceInBtc *
            _getRate(settings.currency, conversions);
        equivalentBalance =
        '${equivalent.toStringAsFixed(2)} ${settings.currency}';
        break;
      case 'Lightning':
        nativeBalance =
            walletBalance.lightningBalanceInDenominationFormatted('sats');
        double balanceInBtc = walletBalance.lightningBalance! / 100000000;
        double equivalent = balanceInBtc *
            _getRate(settings.currency, conversions);
        equivalentBalance =
        '${equivalent.toStringAsFixed(2)} ${settings.currency}';
        break;
      case 'USD':
        nativeBalance =
            (walletBalance.usdBalance / 100).toStringAsFixed(2) + ' USD';
        double balanceInBtc = (walletBalance.usdBalance / 100) *
            conversions.usdToBtc;
        double equivalent = balanceInBtc *
            _getRate(settings.currency, conversions);
        equivalentBalance =
        '${equivalent.toStringAsFixed(2)} ${settings.currency}';
        break;
      case 'EUR':
        nativeBalance =
            (walletBalance.eurBalance / 100).toStringAsFixed(2) + ' EUR';
        double balanceInBtc = (walletBalance.eurBalance / 100) *
            conversions.eurToBtc;
        double equivalent = balanceInBtc *
            _getRate(settings.currency, conversions);
        equivalentBalance =
        '${equivalent.toStringAsFixed(2)} ${settings.currency}';
        break;
      case 'BRL':
        nativeBalance =
            (walletBalance.brlBalance / 100).toStringAsFixed(2) + ' BRL';
        double balanceInBtc = (walletBalance.brlBalance / 100) *
            conversions.brlToBtc;
        double equivalent = balanceInBtc *
            _getRate(settings.currency, conversions);
        equivalentBalance =
        '${equivalent.toStringAsFixed(2)} ${settings.currency}';
        break;
      default:
        nativeBalance = '0';
        equivalentBalance = '0 ${settings.currency}';
    }

    // Price change ticker
    AsyncValue<double> changeProvider;
    switch (assetName) {
      case 'BTC':
      case 'LBTC':
      case 'Lightning':
        changeProvider = ref.watch(coinGeckoBitcoinChange);
        break;
      default:
        changeProvider =
            AsyncValue.data(0.0); // No price change for fiat assets
    }

    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              assetName,
              style: const TextStyle(fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              nativeBalance,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            Text(
              equivalentBalance,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  double _getRate(String currency, CurrencyConversions conversions) {
    switch (currency) {
      case 'BTC':
        return 1;
      case 'USD':
        return conversions.btcToUsd;
      case 'EUR':
        return conversions.btcToEur;
      case 'BRL':
        return conversions.btcToBrl;
      default:
        return 0;
    }
  }
}