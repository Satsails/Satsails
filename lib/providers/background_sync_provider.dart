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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:hive/hive.dart';
import 'package:lwk/lwk.dart';

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

class BitcoinSyncNotifier extends SyncNotifier<int> {
  @override
  Future<int> build() async {
    final balance = await ref.read(getBitcoinBalanceProvider.future);
    return balance.total.toInt();
  }

  @override
  Future<int> performSync() async {
    return await handleSync(
      syncOperation: () async {
        await ref.refresh(syncBitcoinProvider.future);

        final addressIndex = await ref.refresh(lastUsedAddressProvider.future);
        final address = await ref.refresh(bitcoinAddressProvider.future);
        ref.read(addressProvider.notifier).setBitcoinAddress(addressIndex, address);

        final balance = await ref.read(getBitcoinBalanceProvider.future);

        ref.read(balanceNotifierProvider.notifier).updateBtcBalance(balance.total.toInt());

        return balance.total.toInt();
      },
      onSuccess: () {
        debugPrint('Bitcoin sync successful.');
      },
      onFailure: () {
        debugPrint('Bitcoin sync failed.');
      },
    );
  }
}

class LiquidSyncNotifier extends SyncNotifier<Balances> {
  @override
  Future<Balances> build() async {
    final balances = await ref.read(liquidBalanceProvider.future);
    return balances;
  }

  @override
  Future<Balances> performSync() async {
    return await handleSync(
      syncOperation: () async {
        await ref.refresh(syncLiquidProvider.future);

        final liquidAddressIndex = await ref.refresh(liquidLastUsedAddressProvider.future);
        final liquidAddress = await ref.refresh(liquidAddressProvider.future);
        ref.read(addressProvider.notifier).setLiquidAddress(liquidAddressIndex, liquidAddress.confidential);

        final balances = await ref.read(liquidBalanceProvider.future);

        final balanceNotifier = ref.read(balanceNotifierProvider.notifier);
        for (var balance in balances) {
          switch (AssetMapper.mapAsset(balance.assetId)) {
            case AssetId.USD:
              balanceNotifier.updateUsdBalance(balance.value);
              break;
            case AssetId.EUR:
              balanceNotifier.updateEurBalance(balance.value);
              break;
            case AssetId.BRL:
              balanceNotifier.updateBrlBalance(balance.value);
              break;
            case AssetId.LBTC:
              balanceNotifier.updateLiquidBalance(balance.value);
              break;
            default:
              break;
          }
        }

        return balances;
      },
      onSuccess: () {
        debugPrint('Liquid sync successful.');
      },
      onFailure: () {
        debugPrint('Liquid sync failed.');
      },
    );
  }
}

class BackgroundSyncNotifier extends SyncNotifier<WalletBalance> {
  @override
  Future<WalletBalance> build() async {
    return ref.read(balanceNotifierProvider);
  }

  @override
  Future<WalletBalance> performSync() async {
    return await handleSync(
      syncOperation: () async {
        final balanceNotifier = ref.read(balanceNotifierProvider.notifier);
        final previousBalance = balanceNotifier.state;

        Balances? liquidBalances;
        int? bitcoinBalance;

        try {
          liquidBalances = await ref.read(liquidSyncNotifierProvider.notifier).performSync();
        } catch (e) {
          debugPrint('Liquid sync failed within background sync: $e');
        }

        try {
          bitcoinBalance = await ref.read(bitcoinSyncNotifierProvider.notifier).performSync();
        } catch (e) {
          debugPrint('Bitcoin sync failed within background sync: $e');
        }

        if (liquidBalances == null && bitcoinBalance == null) {
          throw Exception('Both Bitcoin and Liquid syncs failed.');
        }

        const lightningBalance = 0;

        final balanceData = WalletBalance.updateFromAssets(
          liquidBalances as Balances,
          bitcoinBalance ?? previousBalance.btcBalance,
          lightningBalance,
        );

        balanceNotifier.updateBalance(balanceData);
        _compareBalances(previousBalance, balanceData);

        await _updateSideShiftShifts();
        await ref.read(claimAllBoltzProvider.future);
        await ref.read(transactionNotifierProvider.notifier).refreshTransactions();

        final hiveBox = await Hive.openBox<WalletBalance>('balanceBox');
        await hiveBox.put('balance', balanceData);

        return balanceData;
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

      try {
        await performSync();
      } catch (e) {
        // ignore
      }

      try {
        await ref.read(updateCurrencyProvider.future);
      } catch (e) {
        // ignore
      }

      try {
        await ref.read(getFiatPurchasesProvider.future);
      } catch (e) {
        // ignore
      }

    } finally {
      setBackgroundSyncInProgress(false);
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
      {'name': 'Bitcoin', 'previous': previous.btcBalance, 'current': current.btcBalance},
      {'name': 'Liquid Bitcoin', 'previous': previous.liquidBalance, 'current': current.liquidBalance},
      {'name': 'USD', 'previous': previous.usdBalance, 'current': current.usdBalance},
      {'name': 'EUR', 'previous': previous.eurBalance, 'current': current.eurBalance},
      {'name': 'BRL', 'previous': previous.brlBalance, 'current': current.brlBalance},
      {'name': 'Lightning', 'previous': previous.lightningBalance ?? 0, 'current': current.lightningBalance ?? 0},
    ];

    for (var asset in assets) {
      switch (asset['name']) {
        case 'Bitcoin':
          _checkAndNotify(
            assetName: asset['name'] as String,
            previousAmount: asset['previous'] as int,
            currentAmount: asset['current'] as int,
          );
          break;
        case 'Liquid Bitcoin':
          _checkAndNotify(
            assetName: asset['name'] as String,
            previousAmount: asset['previous'] as int,
            currentAmount: asset['current'] as int,
          );
          break;
        case 'USD':
          _checkAndNotify(
            assetName: 'USDT',
            previousAmount: asset['previous'] as int,
            currentAmount: asset['current'] as int,
          );
          break;
        case 'EUR':
          _checkAndNotify(
            assetName: 'EUROX',
            previousAmount: asset['previous'] as int,
            currentAmount: asset['current'] as int,
          );
          break;
        case 'BRL':
          _checkAndNotify(
            assetName: 'DEPIX',
            previousAmount: asset['previous'] as int,
            currentAmount: asset['current'] as int,
          );
          break;
        case 'Lightning':
          _checkAndNotify(
            assetName: asset['name'] as String,
            previousAmount: asset['previous'] as int,
            currentAmount: asset['current'] as int,
          );
          break;
        default:
          break;
      }
    }
  }

  void _checkAndNotify({
    required String assetName,
    required int previousAmount,
    required int currentAmount,
  }) {
    if (previousAmount < currentAmount) {
      final balanceChange = BalanceChange(
        asset: assetName,
        amount: currentAmount - previousAmount,
      );
      ref.read(balanceChangeProvider.notifier).state = balanceChange;
    }
  }
}

final bitcoinSyncNotifierProvider = AsyncNotifierProvider<BitcoinSyncNotifier, int>(BitcoinSyncNotifier.new);

final liquidSyncNotifierProvider = AsyncNotifierProvider<LiquidSyncNotifier, Balances>(LiquidSyncNotifier.new);

final backgroundSyncNotifierProvider = AsyncNotifierProvider<BackgroundSyncNotifier, WalletBalance>(BackgroundSyncNotifier.new);

final backgroundSyncInProgressProvider = StateProvider<bool>((ref) => false);

final shouldUpdateMemoryProvider = StateProvider<bool>((ref) => true);