import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/currency_conversions.dart';
import 'package:hive/hive.dart';
import 'package:lwk/lwk.dart';
import 'package:riverpod/riverpod.dart';

part 'balance_model.g.dart';

class BalanceNotifier extends StateNotifier<WalletBalance> {
  BalanceNotifier(this.ref) : super(
      WalletBalance(
        btcBalance: 0,
        liquidBalance: 0,
        usdBalance: 0,
        eurBalance: 0,
        brlBalance: 0,
        lightningBalance: 0,
      )) {
    _initialize();
  }

  final Ref ref;

  void _initialize() {
    Future.microtask(() async {
      // Open Hive box
      final hiveBox = await Hive.openBox<WalletBalance>('balanceBox');

      // Load the cached balance
      final cachedBalance = hiveBox.get('balance');

      if (cachedBalance != null) {
        // Update the state with the cached balance
        state = cachedBalance;
      }

      // Listen for changes in the Hive box
      hiveBox.watch(key: 'balance').listen((event) {
        if (event.value != null && event.value is WalletBalance) {
          state = event.value as WalletBalance;
        }
      });
    });
  }


  void updateLightningBalance(int newLightningBalance) {
    state = WalletBalance(
      btcBalance: state.btcBalance,
      liquidBalance: state.liquidBalance,
      usdBalance: state.usdBalance,
      eurBalance: state.eurBalance,
      brlBalance: state.brlBalance,
      lightningBalance: newLightningBalance,
    );
  }

  void updateBalance(WalletBalance newBalance) {
    state = newBalance;
  }

  void updateBtcBalance(int newBtcBalance) {
    state = WalletBalance(
      btcBalance: newBtcBalance,
      liquidBalance: state.liquidBalance,
      usdBalance: state.usdBalance,
      eurBalance: state.eurBalance,
      brlBalance: state.brlBalance,
      lightningBalance: state.lightningBalance,
    );
  }

  void updateLiquidBalance(int newLiquidBalance) {
    state = WalletBalance(
      btcBalance: state.btcBalance,
      liquidBalance: newLiquidBalance,
      usdBalance: state.usdBalance,
      eurBalance: state.eurBalance,
      brlBalance: state.brlBalance,
      lightningBalance: state.lightningBalance,
    );
  }

  void updateUsdBalance(int newUsdBalance) {
    state = WalletBalance(
      btcBalance: state.btcBalance,
      liquidBalance: state.liquidBalance,
      usdBalance: newUsdBalance,
      eurBalance: state.eurBalance,
      brlBalance: state.brlBalance,
      lightningBalance: state.lightningBalance,
    );
  }

  void updateEurBalance(int newEurBalance) {
    state = WalletBalance(
      btcBalance: state.btcBalance,
      liquidBalance: state.liquidBalance,
      usdBalance: state.usdBalance,
      eurBalance: newEurBalance,
      brlBalance: state.brlBalance,
      lightningBalance: state.lightningBalance,
    );
  }

  void updateBrlBalance(int newBrlBalance) {
    state = WalletBalance(
      btcBalance: state.btcBalance,
      liquidBalance: state.liquidBalance,
      usdBalance: state.usdBalance,
      eurBalance: state.eurBalance,
      brlBalance: newBrlBalance,
      lightningBalance: state.lightningBalance,
    );
  }
}

@HiveType(typeId: 26)
class WalletBalance {
  @HiveField(0)
  final int btcBalance;
  @HiveField(1)
  final int liquidBalance;
  @HiveField(2)
  final int usdBalance;
  @HiveField(3)
  final int eurBalance;
  @HiveField(4)
  final int brlBalance;
  @HiveField(5)
  int? lightningBalance;

  bool get isEmpty {
    return btcBalance == 0 && liquidBalance == 0 && usdBalance == 0 && eurBalance == 0 && brlBalance == 0 && lightningBalance == 0;
  }

  WalletBalance({
    required this.btcBalance,
    required this.liquidBalance,
    required this.usdBalance,
    required this.eurBalance,
    required this.brlBalance,
    int? lightningBalance,
  }) : lightningBalance = lightningBalance ?? 0;

  factory WalletBalance.updateFromAssets(Balances balances, int bitcoinBalance, int lightningBalance) {
    int usdBalance = 0;
    int eurBalance = 0;
    int brlBalance = 0;
    int liquidBalance = 0;

    for (var balance in balances) {
      switch (AssetMapper.mapAsset(balance.assetId)) {
        case AssetId.USD:
          usdBalance = balance.value;
          break;
        case AssetId.EUR:
          eurBalance = balance.value;
          break;
        case AssetId.BRL:
          brlBalance = balance.value;
          break;
        case AssetId.LBTC:
          liquidBalance = balance.value;
          break;
        default:
          break;
      }
    }

    return WalletBalance(
      btcBalance: bitcoinBalance,
      liquidBalance: liquidBalance,
      usdBalance: usdBalance,
      eurBalance: eurBalance,
      brlBalance: brlBalance,
      lightningBalance: lightningBalance,
    );
  }

  double totalBtcBalanceInDenomination(String denomination) {
    switch (denomination) {
      case 'sats':
        return totalBtcBalance();
      case 'BTC':
        return totalBtcBalance() / 100000000;
      default:
        return 0;
    }
  }
  String liquidBalanceInDenominationFormatted(String denomination) {
    double balance;

    switch (denomination) {
      case 'sats':
        balance = liquidBalance.toDouble();
        return balance.toInt().toString();
      case 'BTC':
        balance = liquidBalance / 100000000;
        return balance.toStringAsFixed(8);
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
        return balance.toStringAsFixed(8);
      default:
        return "0";
    }
  }

  String lightningBalanceInDenominationFormatted(String denomination) {
    double balance;

    switch (denomination) {
      case 'sats':
        balance = lightningBalance!.toDouble();
        return balance.toInt().toString();
      case 'BTC':
        balance = lightningBalance! / 100000000;
        return balance.toStringAsFixed(8);
      default:
        return "0";
    }
  }


  double totalBtcBalance() {
    return btcBalance.toDouble() + liquidBalance.toDouble() + lightningBalance!.toDouble();
  }

  Percentage percentageOfEachCurrency(CurrencyConversions conversions) {
    final total = totalBalanceInCurrency('BTC', conversions);
    return Percentage(
      eurPercentage: conversions.eurToBtc * eurBalance.toDouble() / total,
      usdPercentage: conversions.usdToBtc * usdBalance.toDouble() / total,
      brlPercentage: conversions.brlToBtc * brlBalance.toDouble() / total,
      lightningPercentage: (lightningBalance!) / total,
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
        break;
      case 'USD':
        total += totalInBtc * conversions.btcToUsd;
        break;
      case 'EUR':
        total += totalInBtc * conversions.btcToEur;
        break;
      case 'BRL':
        total += totalInBtc * conversions.btcToBrl;
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
  final double lightningPercentage;
  final double total;

  Percentage({
    required this.btcPercentage,
    required this.liquidPercentage,
    required this.usdPercentage,
    required this.eurPercentage,
    required this.brlPercentage,
    required this.lightningPercentage,
    required this.total,
  });
}

class CurrencyParams {
  final String currency;
  final int amount;

  CurrencyParams(this.currency, this.amount);
}


class BalanceChange {
  final String asset;
  final int amount;

  BalanceChange({required this.asset, required this.amount});
}