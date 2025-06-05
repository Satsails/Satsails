import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/currency_conversions.dart';
import 'package:hive/hive.dart';
import 'package:lwk/lwk.dart';
import 'package:riverpod/riverpod.dart';

part 'balance_model.g.dart';

class BalanceNotifier extends StateNotifier<WalletBalance> {
  BalanceNotifier(this.ref)
      : super(
    WalletBalance(
      onChainBtcBalance: 0,
      liquidBtcBalance: 0,
      liquidUsdtBalance: 0,
      liquidEuroxBalance: 0,
      liquidDepixBalance: 0,
      sparkBitcoinbalance: 0,
    ),
  ) {
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
    state = WalletBalance(
      onChainBtcBalance: newBalance,
      liquidBtcBalance: state.liquidBtcBalance,
      liquidUsdtBalance: state.liquidUsdtBalance,
      liquidEuroxBalance: state.liquidEuroxBalance,
      liquidDepixBalance: state.liquidDepixBalance,
      sparkBitcoinbalance: state.sparkBitcoinbalance,
    );
  }

  void updateLiquidBtcBalance(int newBalance) {
    state = WalletBalance(
      onChainBtcBalance: state.onChainBtcBalance,
      liquidBtcBalance: newBalance,
      liquidUsdtBalance: state.liquidUsdtBalance,
      liquidEuroxBalance: state.liquidEuroxBalance,
      liquidDepixBalance: state.liquidDepixBalance,
      sparkBitcoinbalance: state.sparkBitcoinbalance,
    );
  }

  void updateLiquidUsdtBalance(int newBalance) {
    state = WalletBalance(
      onChainBtcBalance: state.onChainBtcBalance,
      liquidBtcBalance: state.liquidBtcBalance,
      liquidUsdtBalance: newBalance,
      liquidEuroxBalance: state.liquidEuroxBalance,
      liquidDepixBalance: state.liquidDepixBalance,
      sparkBitcoinbalance: state.sparkBitcoinbalance,
    );
  }

  void updateLiquidEuroxBalance(int newBalance) {
    state = WalletBalance(
      onChainBtcBalance: state.onChainBtcBalance,
      liquidBtcBalance: state.liquidBtcBalance,
      liquidUsdtBalance: state.liquidUsdtBalance,
      liquidEuroxBalance: newBalance,
      liquidDepixBalance: state.liquidDepixBalance,
      sparkBitcoinbalance: state.sparkBitcoinbalance,
    );
  }

  void updateLiquidDepixBalance(int newBalance) {
    state = WalletBalance(
      onChainBtcBalance: state.onChainBtcBalance,
      liquidBtcBalance: state.liquidBtcBalance,
      liquidUsdtBalance: state.liquidUsdtBalance,
      liquidEuroxBalance: state.liquidEuroxBalance,
      liquidDepixBalance: newBalance,
      sparkBitcoinbalance: state.sparkBitcoinbalance,
    );
  }

  void updateSparkBitcoinbalance(int newBalance) {
    state = WalletBalance(
      onChainBtcBalance: state.onChainBtcBalance,
      liquidBtcBalance: state.liquidBtcBalance,
      liquidUsdtBalance: state.liquidUsdtBalance,
      liquidEuroxBalance: state.liquidEuroxBalance,
      liquidDepixBalance: state.liquidDepixBalance,
      sparkBitcoinbalance: newBalance,
    );
  }

  void updateBalance(WalletBalance newBalance) {
    state = newBalance;
  }
}

// The WalletBalance class remains unchanged, included here for completeness
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

  double totalBalanceInCurrency(String currency, CurrencyConversions conversions) {
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