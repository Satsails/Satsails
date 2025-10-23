// Import the decimal package
import 'package:decimal/decimal.dart';

import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/currency_conversions.dart';
import 'package:hive_ce/hive.dart';
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

// --- WalletBalance Class (Refactored for Decimal) ---
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

  Decimal totalBtcBalanceInDenomination(String denomination) {
    final totalSats = Decimal.fromInt(totalBtcBalance());
    switch (denomination) {
      case 'sats':
        return totalSats;
      case 'BTC':
        final satsFactor = Decimal.fromInt(100000000);
        return (totalSats / satsFactor).toDecimal();
      default:
        return Decimal.zero;
    }
  }

  /// Returns the Liquid BTC balance formatted as a string.
  String liquidBalanceInDenominationFormatted(String denomination) {
    final sats = Decimal.fromInt(liquidBtcBalance);
    switch (denomination) {
      case 'sats':
        return sats.toString();
      case 'BTC':
        final satsFactor = Decimal.fromInt(100000000);
        final btc = (sats / satsFactor).toDecimal();
        return btc.toStringAsFixed(8);
      default:
        return "0";
    }
  }

  /// Returns the On-chain BTC balance formatted as a string.
  String btcBalanceInDenominationFormatted(String denomination) {
    final sats = Decimal.fromInt(onChainBtcBalance);
    switch (denomination) {
      case 'sats':
        return sats.toString();
      case 'BTC':
        final satsFactor = Decimal.fromInt(100000000);
        final btc = (sats / satsFactor).toDecimal();
        return btc.toStringAsFixed(8);
      default:
        return "0";
    }
  }

  /// Returns the Spark (Lightning) balance formatted as a string.
  String lightningBalanceInDenominationFormatted(String denomination) {
    final sats = Decimal.fromInt(sparkBitcoinbalance ?? 0);
    switch (denomination) {
      case 'sats':
        return sats.toString();
      case 'BTC':
        final satsFactor = Decimal.fromInt(100000000);
        final btc = (sats / satsFactor).toDecimal();
        return btc.toStringAsFixed(8);
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
    Decimal balanceInBTC = totalBalanceInCurrency('BTC', conversions);
    switch (denomination) {
      case 'BTC':
        return balanceInBTC.toStringAsFixed(8);
      case 'sats':
        final satsFactor = Decimal.fromInt(100000000);
        final balanceInSats = balanceInBTC * satsFactor;
        return balanceInSats.toBigInt().toString();
      default:
        return "0";
    }
  }

  double currentBitcoinPriceInCurrency(
      CurrencyParams params, CurrencyConversions conversions) {
    Decimal rate;
    switch (params.currency) {
      case 'BTC':
        rate = Decimal.one;
        break;
      case 'USD':
        rate = Decimal.parse(conversions.btcToUsd.toString());
        break;
      case 'EUR':
        rate = Decimal.parse(conversions.btcToEur.toString());
        break;
      case 'BRL':
        rate = Decimal.parse(conversions.btcToBrl.toString());
        break;
      default:
        rate = Decimal.zero;
    }

    final satsFactor = Decimal.fromInt(100000000);
    final amountDecimal = Decimal.fromInt(params.amount);
    final btcAmount = (amountDecimal / satsFactor).toDecimal();

    return (rate * btcAmount).toDouble();
  }

  Decimal totalBalanceInCurrency(
      String currency, CurrencyConversions conversions) {
    Decimal total = Decimal.zero;
    Decimal totalInBtc = totalBtcBalanceInDenomination('BTC');

    switch (currency) {
      case 'BTC':
        total += totalInBtc;
        break;
      case 'USD':
        total += totalInBtc * Decimal.parse(conversions.btcToUsd.toString());
        break;
      case 'EUR':
        total += totalInBtc * Decimal.parse(conversions.btcToEur.toString());
        break;
      case 'BRL':
        total += totalInBtc * Decimal.parse(conversions.btcToBrl.toString());
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