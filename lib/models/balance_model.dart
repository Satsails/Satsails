import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/currency_conversions.dart';
import 'package:hive/hive.dart';
import 'package:lwk/lwk.dart';
import 'package:riverpod/riverpod.dart';

part 'balance_model.g.dart';

class BalanceNotifier extends StateNotifier<WalletBalance> {
  BalanceNotifier(this.ref) : super(WalletBalance.empty()) {
    _initialize();
  }

  final Ref ref;

  void _initialize() {
    Future.microtask(() async {
      final hiveBox = await Hive.openBox<WalletBalance>('balanceBox');
      final cachedBalance = hiveBox.get('balance');
      if (cachedBalance != null) {
        state = cachedBalance;
      }
      hiveBox.watch(key: 'balance').listen((event) {
        if (event.value != null && event.value is WalletBalance) {
          state = event.value as WalletBalance;
        }
      });
    });
  }

  void updateOnChainBtcBalance(int newBalance) {
    state = state.copyWith(onChainBtcBalance: newBalance);
  }

  void updateLiquidBtcBalance(int newBalance) {
    state = state.copyWith(liquidBtcBalance: newBalance);
  }

  void updateLiquidUsdtBalance(int newBalance) {
    state = state.copyWith(liquidUsdtBalance: newBalance);
  }

  void updateLiquidEuroxBalance(int newBalance) {
    state = state.copyWith(liquidEuroxBalance: newBalance);
  }

  void updateLiquidDepixBalance(int newBalance) {
    state = state.copyWith(liquidDepixBalance: newBalance);
  }

  void updateSparkBitcoinbalance(int newBalance) {
    state = state.copyWith(sparkBitcoinbalance: newBalance);
  }

  void updateBalance(WalletBalance newBalance) {
    state = newBalance;
  }
}

@HiveType(typeId: 26)
class WalletBalance {
  @HiveField(0)
  final int onChainBtcBalance;

  @HiveField(1)
  final int liquidBtcBalance;

  @HiveField(2)
  final int liquidUsdtBalance;

  @HiveField(3)
  final int liquidEuroxBalance;

  @HiveField(4)
  final int liquidDepixBalance;

  @HiveField(5)
  int? sparkBitcoinbalance;

  bool get isEmpty {
    return onChainBtcBalance == 0 &&
        liquidBtcBalance == 0 &&
        liquidUsdtBalance == 0 &&
        liquidEuroxBalance == 0 &&
        liquidDepixBalance == 0 &&
        (sparkBitcoinbalance ?? 0) == 0;
  }

  WalletBalance({
    required this.onChainBtcBalance,
    required this.liquidBtcBalance,
    required this.liquidUsdtBalance,
    required this.liquidEuroxBalance,
    required this.liquidDepixBalance,
    int? sparkBitcoinbalance,
  }) : sparkBitcoinbalance = sparkBitcoinbalance ?? 0;

  WalletBalance copyWith({
    int? onChainBtcBalance,
    int? liquidBtcBalance,
    int? liquidUsdtBalance,
    int? liquidEuroxBalance,
    int? liquidDepixBalance,
    int? sparkBitcoinbalance,
  }) {
    return WalletBalance(
      onChainBtcBalance: onChainBtcBalance ?? this.onChainBtcBalance,
      liquidBtcBalance: liquidBtcBalance ?? this.liquidBtcBalance,
      liquidUsdtBalance: liquidUsdtBalance ?? this.liquidUsdtBalance,
      liquidEuroxBalance: liquidEuroxBalance ?? this.liquidEuroxBalance,
      liquidDepixBalance: liquidDepixBalance ?? this.liquidDepixBalance,
      sparkBitcoinbalance: sparkBitcoinbalance ?? this.sparkBitcoinbalance,
    );
  }

  factory WalletBalance.empty() {
    return WalletBalance(
      onChainBtcBalance: 0,
      liquidBtcBalance: 0,
      liquidUsdtBalance: 0,
      liquidEuroxBalance: 0,
      liquidDepixBalance: 0,
      sparkBitcoinbalance: 0,
    );
  }

  factory WalletBalance.updateFromAssets(
      Balances balances, int bitcoinBalance, int sparkBitcoinbalance) {
    int liquidUsdtBalance = 0;
    int liquidEuroxBalance = 0;
    int liquidDepixBalance = 0;
    int liquidBtcBalance = 0;

    for (var balance in balances) {
      switch (AssetMapper.mapAsset(balance.assetId)) {
        case AssetId.USD:
          liquidUsdtBalance = balance.value;
          break;
        case AssetId.EUR:
          liquidEuroxBalance = balance.value;
          break;
        case AssetId.BRL:
          liquidDepixBalance = balance.value;
          break;
        case AssetId.LBTC:
          liquidBtcBalance = balance.value;
          break;
        default:
          break;
      }
    }

    return WalletBalance(
      onChainBtcBalance: bitcoinBalance,
      liquidBtcBalance: liquidBtcBalance,
      liquidUsdtBalance: liquidUsdtBalance,
      liquidEuroxBalance: liquidEuroxBalance,
      liquidDepixBalance: liquidDepixBalance,
      sparkBitcoinbalance: sparkBitcoinbalance,
    );
  }

  num totalBtcBalanceInDenomination(String denomination) {
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
        balance = liquidBtcBalance.toDouble();
        return balance.toInt().toString();
      case 'BTC':
        balance = liquidBtcBalance / 100000000;
        return balance.toStringAsFixed(8);
      default:
        return "0";
    }
  }

  String btcBalanceInDenominationFormatted(String denomination) {
    double balance;
    switch (denomination) {
      case 'sats':
        balance = onChainBtcBalance.toDouble();
        return balance.toInt().toString();
      case 'BTC':
        balance = onChainBtcBalance / 100000000;
        return balance.toStringAsFixed(8);
      default:
        return "0";
    }
  }

  String lightningBalanceInDenominationFormatted(String denomination) {
    double balance;
    switch (denomination) {
      case 'sats':
        balance = (sparkBitcoinbalance ?? 0).toDouble();
        return balance.toInt().toString();
      case 'BTC':
        balance = (sparkBitcoinbalance ?? 0) / 100000000;
        return balance.toStringAsFixed(8);
      default:
        return "0";
    }
  }

  int totalBtcBalance() {
    return onChainBtcBalance +
        liquidBtcBalance +
        (sparkBitcoinbalance ?? 0);
  }

  String totalBalanceInDenominationFormatted(
      String denomination, CurrencyConversions conversions) {
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

  double currentBitcoinPriceInCurrency(
      CurrencyParams params, CurrencyConversions conversions) {
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

  double totalBalanceInCurrency(
      String currency, CurrencyConversions conversions) {
    double total = 0;
    num totalInBtc = totalBtcBalanceInDenomination('BTC');
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