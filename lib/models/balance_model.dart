import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forex_currency_conversion/forex_currency_conversion.dart';

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


  String liquidBalanceInDenominationFormatted(String denomination) {
    double balance;

    switch (denomination) {
      case 'sats':
        balance = liquidBalance * 100000000;
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

    switch (denomination) {
      case 'sats':
        balance = btcBalance.toDouble();
        return "${balance.toInt()}";
      case 'BTC':
        balance = btcBalance / 100000000;
        return "${balance.toStringAsFixed(8)}";
      case 'mBTC':
        balance = (btcBalance / 100000000) * 1000;
        return "${balance.toStringAsFixed(5)}";
      case 'bits':
        balance = (btcBalance / 100000000) * 1000000;
        return "${balance.toStringAsFixed(2)}";
      default:
        return "0";
    }
  }

  double totalBtcBalance() {
    return btcBalance.toDouble() + liquidBalance.toDouble();
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

  Future<Percentage> percentageOfEachCurrency() async {
    final total = await totalBalanceInCurrency('BTC') * 100000000;
    return Percentage(
      eurPercentage: await getConvertedBalance('EUR', 'BTC', eurBalance.toDouble() * 100000000) / total,
      brlPercentage: await getConvertedBalance('BRL', 'BTC', brlBalance.toDouble() * 100000000) / total,
      usdPercentage: await getConvertedBalance('USD', 'BTC', usdBalance.toDouble() * 100000000) / total,
      liquidPercentage: (liquidBalance).toDouble() / total,
      btcPercentage: (btcBalance).toDouble() / total,
      total: total,
    );
  }

  Future<String> totalBalanceInDenominationFormatted(String? denomination) async {
    double balanceInBTC = await totalBalanceInCurrency('BTC');

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


  Future<double> currentBitcoinPriceInCurrency(String currency) {
    return getConvertedBalance('BTC', currency, 1);
  }

  Future<double> totalBalanceInCurrency(String currency) async {
    double total = 0;
    double totalInBtc = totalBtcBalanceInDenomination('BTC');

    switch (currency) {
      case 'BTC':
        total += totalInBtc;
        total += await getConvertedBalance('BRL', 'BTC', brlBalance.toDouble());
        total += await getConvertedBalance('EUR', 'BTC', eurBalance.toDouble());
        total += await getConvertedBalance('USD', 'BTC', usdBalance.toDouble());
        break;
      case 'USD':
        total += usdBalance.toDouble();
        total += await getConvertedBalance('BRL', 'USD', brlBalance.toDouble());
        total += await getConvertedBalance('EUR', 'USD', eurBalance.toDouble());
        total += await getConvertedBalance('BTC', 'USD', totalInBtc);
        break;
      case 'EUR':
        total += eurBalance.toDouble();
        total += await getConvertedBalance('BRL', 'EUR', brlBalance.toDouble());
        total += await getConvertedBalance('USD', 'EUR', usdBalance.toDouble());
        total += await getConvertedBalance('BTC', 'EUR', totalInBtc);
        break;
      case 'BRL':
        total += brlBalance.toDouble();
        total += await getConvertedBalance('EUR', 'BRL', eurBalance.toDouble());
        total += await getConvertedBalance('USD', 'BRL', usdBalance.toDouble());
        total += await getConvertedBalance('BTC', 'BRL', totalInBtc);
        break;
    }
    return total;
  }
  Future<double> getConvertedBalance(String sourceCurrency, String destinationCurrency, double sourceAmount) async {
    if (sourceCurrency == destinationCurrency) {
      return sourceAmount;
    }

    if (sourceAmount == 0) {
      return 0;
    }


    final fx = Forex();
    final result = await fx.getCurrencyConverted(sourceCurrency: sourceCurrency, destinationCurrency: destinationCurrency, sourceAmount: sourceAmount);
    final error = fx.getErrorNotifier.value;

    if (error != null){
      throw 'No internet connection';
    }
    return result;
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