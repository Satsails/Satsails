import 'dart:async';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/sideshift_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:lwk/lwk.dart';
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;

class BitcoinSyncResult {
  final int balance;
  final String address;
  final int addressIndex;
  final List<bdk.TransactionDetails> transactions;

  BitcoinSyncResult({
    required this.balance,
    required this.address,
    required this.addressIndex,
    required this.transactions,
  });
}

abstract class SyncNotifier<T> extends AsyncNotifier<T> {
  Future<T> performSync();

  @protected
  Future<T> handleSync({
    required Future<T> Function() syncOperation,
    required void Function() onSuccess,
    required void Function() onFailure,
    int maxAttempts = 3,
  }) async {
    int attempt = 0;
    while (attempt < maxAttempts) {
      try {
        final result = await syncOperation();
        onSuccess();
        return result;
      } catch (e, stackTrace) {
        attempt++;
        if (attempt >= maxAttempts) {
          onFailure();
          state = AsyncError(e, stackTrace);
          rethrow;
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    throw Exception('handleSync failed after $maxAttempts attempts');
  }
}

class BitcoinSyncNotifier extends SyncNotifier<BitcoinSyncResult?> {
  @override
  Future<BitcoinSyncResult?> build() async {
    return null;
  }

  @override
  Future<BitcoinSyncResult?> performSync() async {
    return await handleSync(
      syncOperation: () async {
        final bitcoinModel = await ref.read(bitcoinModelProvider.future);

        await bitcoinModel.sync();
        final addressIndex = await bitcoinModel.getAddress();
        final address = await bitcoinModel.getAddressString();
        final balance = await bitcoinModel.getBalance();
        final transactions = await bitcoinModel.getTransactions();

        ref.read(addressProvider.notifier).setBitcoinAddress(addressIndex, address);
        ref.read(balanceNotifierProvider.notifier).updateOnChainBtcBalance(balance.total.toInt());

        return BitcoinSyncResult(
          balance: balance.total.toInt(),
          address: address,
          addressIndex: addressIndex,
          transactions: transactions,
        );
      },
      onSuccess: () => debugPrint('Bitcoin sync successful.'),
      onFailure: () => debugPrint('Bitcoin sync failed.'),
    );
  }
}

class LiquidSyncNotifier extends SyncNotifier<Balances> {
  @override
  Future<Balances> build() async {
    return [];
  }

  @override
  Future<Balances> performSync() async {
    return await handleSync(
      syncOperation: () async {
        final liquidModel = await ref.read(liquidModelProvider.future);
        await liquidModel.sync();
        final liquidAddressIndex = await liquidModel.getAddress();
        final liquidAddress = await liquidModel.getLatestAddress();
        final balances = await liquidModel.balance();

        ref.read(addressProvider.notifier).setLiquidAddress(liquidAddressIndex, liquidAddress);
        final balanceNotifier = ref.read(balanceNotifierProvider.notifier);

        for (var balance in balances) {
          switch (AssetMapper.mapAsset(balance.assetId)) {
            case AssetId.USD:
              balanceNotifier.updateLiquidUsdtBalance(balance.value);
              break;
            case AssetId.EUR:
              balanceNotifier.updateLiquidEuroxBalance(balance.value);
              break;
            case AssetId.BRL:
              balanceNotifier.updateLiquidDepixBalance(balance.value);
              break;
            case AssetId.LBTC:
              balanceNotifier.updateLiquidBtcBalance(balance.value);
              break;
            default:
              break;
          }
        }
        return balances;
      },
      onSuccess: () => debugPrint('Liquid sync successful.'),
      onFailure: () => debugPrint('Liquid sync failed.'),
    );
  }
}

class BackgroundSyncNotifier extends SyncNotifier<WalletBalance> {
  @override
  Future<WalletBalance> build() async {
    return WalletBalance.empty();
  }

  @override
  Future<WalletBalance> performSync() async {
    return await handleSync(
      syncOperation: () async {
        final previousBalance = await ref.refresh(balanceFutureProvider.future);
        List<bdk.TransactionDetails>? syncedBitcoinTxs;

        try {
          await ref.read(getFiatPurchasesProvider.future);
        } catch (e) {
          // ignore
        }

        try {
          final bitcoinResult = await ref.read(bitcoinSyncNotifierProvider.notifier).performSync();
          if (bitcoinResult != null) {
            syncedBitcoinTxs = bitcoinResult.transactions;
          }
        } catch (e) {
          debugPrint('Bitcoin sync failed within background sync: $e');
        }

        try {
          await ref.read(liquidSyncNotifierProvider.notifier).performSync();
        } catch (e) {
          debugPrint('Liquid sync failed within background sync: $e');
        }

        final latestBalance = ref.read(balanceNotifierProvider);
        await _updateSideShiftShifts();
        await ref.read(claimAllBoltzProvider.future);
        _compareBalances(previousBalance, latestBalance);

        final hiveBox = await Hive.openBox<WalletBalance>('balanceBox');
        await hiveBox.put('balance', latestBalance);

        await ref.read(transactionNotifierProvider.notifier).refreshAndMergeTransactions(btcTxs: syncedBitcoinTxs);
        return latestBalance;
      },
      onSuccess: () {
        ref.read(settingsProvider.notifier).setOnline(true);
        debugPrint('Background sync successful.');
      },
      onFailure: () {
        ref.read(settingsProvider.notifier).setOnline(false);
        debugPrint('Background sync failed.');
      },
    );
  }

  Future<void> performFullUpdate() async {
    if (ref.read(backgroundSyncInProgressProvider)) {
      return;
    }

    try {
      setBackgroundSyncInProgress(true);
      await performSync();
    } catch (e) {
      // ignore
    } finally {
      setBackgroundSyncInProgress(false);
    }

    try {
      await ref.read(updateCurrencyProvider.future);
    } catch (e) {
      // ignore
    }

  }

  Future<void> _updateSideShiftShifts() async {
    try {
      final box = await Hive.openBox<SideShift>('sideShiftShifts');
      final shiftIds = box.keys.cast<String>().toList();
      if (shiftIds.isNotEmpty) {
        await ref.read(updateSideShiftShiftsProvider(shiftIds).future);
      }
    } catch (e) {
      debugPrint('Failed to update SideShift shifts: $e');
    }
  }

  void setBackgroundSyncInProgress(bool inProgress) {
    Future.microtask(() {
      ref.read(backgroundSyncInProgressProvider.notifier).state = inProgress;
    });
  }

  void _compareBalances(WalletBalance previous, WalletBalance current) {
    final assets = [
      {'name': 'Bitcoin', 'previous': previous.onChainBtcBalance, 'current': current.onChainBtcBalance},
      {'name': 'Liquid Bitcoin', 'previous': previous.liquidBtcBalance, 'current': current.liquidBtcBalance},
      {'name': 'USD', 'previous': previous.liquidUsdtBalance, 'current': current.liquidUsdtBalance},
      {'name': 'EUR', 'previous': previous.liquidEuroxBalance, 'current': current.liquidEuroxBalance},
      {'name': 'BRL', 'previous': previous.liquidDepixBalance, 'current': current.liquidDepixBalance},
      {'name': 'Lightning', 'previous': previous.sparkBitcoinbalance ?? 0, 'current': current.sparkBitcoinbalance ?? 0},
    ];

    for (var asset in assets) {
      _checkAndNotify(
        assetName: asset['name'] as String,
        previousAmount: asset['previous'] as int,
        currentAmount: asset['current'] as int,
      );
    }
  }

  void _checkAndNotify({ required String assetName, required int previousAmount, required int currentAmount}) {
    if (previousAmount < currentAmount) {
      final Map<String, String> assetTickerMap = {
        'USD': 'USDT',
        'EUR': 'EUROX',
        'BRL': 'DEPIX',
      };
      final balanceChange = BalanceChange(
        asset: assetTickerMap[assetName] ?? assetName,
        amount: currentAmount - previousAmount,
      );
      ref.read(balanceChangeProvider.notifier).state = balanceChange;
    }
  }
}

final bitcoinSyncNotifierProvider =
AsyncNotifierProvider<BitcoinSyncNotifier, BitcoinSyncResult?>(BitcoinSyncNotifier.new);

final liquidSyncNotifierProvider =
AsyncNotifierProvider<LiquidSyncNotifier, Balances>(LiquidSyncNotifier.new);

final backgroundSyncNotifierProvider =
AsyncNotifierProvider<BackgroundSyncNotifier, WalletBalance>(
    BackgroundSyncNotifier.new);

final backgroundSyncInProgressProvider = StateProvider<bool>((ref) => false);