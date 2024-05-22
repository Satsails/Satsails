import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/currency_conversions.dart';

class BalanceModel extends StateNotifier<Balance>{
  BalanceModel(super.state);

  void updateBtcBalance(int newBtcBalance) {
    state = state.copyWith(btcBalance: newBtcBalance);
  }

  void updateLiquidBalance(int newLiquidBalance) {
    state = state.copyWith(liquidBalance: newLiquidBalance);
  }

  void updateUsdBalance(int newUsdBalance) {
    state = state.copyWith(usdBalance: newUsdBalance);
  }

  void updateEurBalance(int newEurBalance) {
    state = state.copyWith(eurBalance: newEurBalance);
  }

  void updateBrlBalance(int newBrlBalance) {
    state = state.copyWith(brlBalance: newBrlBalance);
  }

}

class Balance {
  late final int btcBalance;
  final int liquidBalance;
  final int usdBalance;
  final int eurBalance;
  final int brlBalance;

  bool get isEmpty {
    return btcBalance == 0 && liquidBalance == 0 && usdBalance == 0 && eurBalance == 0 && brlBalance == 0;
  }

  Balance({
    required this.btcBalance,
    required this.liquidBalance,
    required this.usdBalance,
    required this.eurBalance,
    required this.brlBalance,
  });

  Balance copyWith({
    int? btcBalance,
    int? liquidBalance,
    int? usdBalance,
    int? eurBalance,
    int? brlBalance,
  }) {
    return Balance(
      btcBalance: btcBalance ?? this.btcBalance,
      liquidBalance: liquidBalance ?? this.liquidBalance,
      usdBalance: usdBalance ?? this.usdBalance,
      eurBalance: eurBalance ?? this.eurBalance,
      brlBalance: brlBalance ?? this.brlBalance,
    );
  }

  double totalBtcBalanceInDenomination(String denomination) {
    switch (denomination) {
      case 'sats':
        return totalBtcBalance();
      case 'BTC':
        return totalBtcBalance() / 100000000;
      case 'mBTC':
        return totalBtcBalance() / 100000;
      case 'bits':
        return totalBtcBalance() / 1000000;
      default:
        return 0;
    }
  }
  String liquidBalanceInDenominationFormatted(String denomination) {
    double balance;

    if (liquidBalance == 0) {
      return "0";
    }

    switch (denomination) {
      case 'sats':
        balance = liquidBalance.toDouble();
        return balance.toInt().toString();
      case 'BTC':
        balance = liquidBalance / 100000000;
        return balance.toStringAsFixed(8);
      case 'mBTC':
        balance = (liquidBalance / 100000000) * 1000;
        return balance.toStringAsFixed(5);
      case 'bits':
        balance = (liquidBalance / 100000000) * 1000000;
        return balance.toStringAsFixed(2);
      default:
        return "0";
    }
  }

  String btcBalanceInDenominationFormatted(String denomination) {
    double balance;

    if (btcBalance == 0) {
      return "0";
    }

    switch (denomination) {
      case 'sats':
        balance = btcBalance.toDouble();
        return "${balance.toInt()}";
      case 'BTC':
        balance = btcBalance / 100000000;
        return balance.toStringAsFixed(8);
      case 'mBTC':
        balance = (btcBalance / 100000000) * 1000;
        return balance.toStringAsFixed(5);
      case 'bits':
        balance = (btcBalance / 100000000) * 1000000;
        return balance.toStringAsFixed(2);
      default:
        return "0";
    }
  }


  double totalBtcBalance() {
    return btcBalance.toDouble() + liquidBalance.toDouble();
  }


  Percentage percentageOfEachCurrency(CurrencyConversions conversions) {
    final total = totalBalanceInCurrency('BTC', conversions);
    return Percentage(
      eurPercentage: conversions.eurToBtc * eurBalance.toDouble() / total,
      usdPercentage: conversions.usdToBtc * usdBalance.toDouble() / total,
      brlPercentage: conversions.brlToBtc * brlBalance.toDouble() / total,
      liquidPercentage: (liquidBalance) / total,
      btcPercentage: (btcBalance) / total,
      total: total,
    );
  }


  String totalBalanceInDenominationFormatted(String denomination, CurrencyConversions conversions) {
    double balanceInBTC = totalBalanceInCurrency('BTC', conversions);

    switch (denomination) {
      case 'BTC':
        return balanceInBTC.toStringAsFixed(8);
      case 'sats':
        double balanceInSats = balanceInBTC * 100000000;
        return balanceInSats.toInt().toString();
      case 'mBTC':
        double balanceInMBTC = balanceInBTC * 1000;
        return balanceInMBTC.toStringAsFixed(5);
      case 'bits':
        double balanceInBits = balanceInBTC * 1000000;
        return balanceInBits.toStringAsFixed(2);
      default:
        return "0";
    }
  }

  double currentBitcoinPriceInCurrency(CurrencyParams params, CurrencyConversions conversions) {
    double rate;
    switch (params.currency) {
      case 'BTC':
        rate = 1;
        break;
      case 'USD':
        rate = conversions.btcToUsd;
        break;
      case 'EUR':
        rate = conversions.btcToEur;
        break;
      case 'BRL':
        rate = conversions.btcToBrl;
        break;
      default:
        rate = 0;
    }
    return rate * params.amount / 100000000;
  }

  double totalBalanceInCurrency(String currency, CurrencyConversions conversions) {
    double total = 0;
    double totalInBtc = totalBtcBalanceInDenomination('BTC');

    switch (currency) {
      case 'BTC':
        total += totalInBtc;
        total += conversions.brlToBtc * brlBalance.toDouble() / 100000000;
        total += conversions.eurToBtc * eurBalance.toDouble() / 100000000;
        total += conversions.usdToBtc * usdBalance.toDouble() / 100000000;
        break;
      case 'USD':
        total += usdBalance.toDouble() / 100000000;
        total += conversions.brlToUsd * brlBalance.toDouble() / 100000000;
        total += conversions.eurToUsd * eurBalance.toDouble() / 100000000;
        total += totalInBtc * conversions.btcToUsd;
        break;
      case 'EUR':
        total += eurBalance.toDouble() / 100000000;
        total += conversions.brlToEur * brlBalance.toDouble() / 100000000;
        total += totalInBtc * conversions.btcToEur;
        total += conversions.usdToEur * usdBalance.toDouble() / 100000000;
        break;
      case 'BRL':
        total += brlBalance.toDouble() / 100000000;
        total += totalInBtc * conversions.btcToBrl;
        total += conversions.eurToBrl * eurBalance.toDouble() / 100000000;
        total += conversions.usdToBrl * usdBalance.toDouble() / 100000000;
        break;
    }
    return total;
  }
}

class Percentage {
  final double btcPercentage;
  final double liquidPercentage;
  final double usdPercentage;
  final double eurPercentage;
  final double brlPercentage;
  final double total;

  Percentage({
    required this.btcPercentage,
    required this.liquidPercentage,
    required this.usdPercentage,
    required this.eurPercentage,
    required this.brlPercentage,
    required this.total,
  });
}

class CurrencyParams {
  final String currency;
  final int amount;

  CurrencyParams(this.currency, this.amount);
}