import 'dart:async';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/coinos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:lwk_dart/lwk_dart.dart';

final syncOnAppOpenProvider = StateProvider<bool>((ref) => false);

/// Abstract class to define common sync behavior
abstract class SyncNotifier<T> extends AsyncNotifier<T> {
  /// Performs the sync operation
  Future<T> performSync();

  /// Handles the sync with retry logic
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
    return balance.total;
  }

  @override
  Future<int> performSync() async {
    return await handleSync(
      syncOperation: () async {
        // Await the Bitcoin sync operation
        await ref.read(syncBitcoinProvider.future);

        // Refresh and retrieve the last used Bitcoin address
        final address = await ref.refresh(lastUsedAddressProvider.future);
        ref.read(addressProvider.notifier).setBitcoinAddress(address);

        // Retrieve the Bitcoin balance
        final balance = await ref.read(getBitcoinBalanceProvider.future);

        // Update the online status
        await ref.read(claimAndDeleteAllBitcoinBoltzProvider.future);

        ref.read(balanceNotifierProvider.notifier).updateBtcBalance(balance.total);

        return balance.total;
      },
      onSuccess: () {
        // Optional: Actions on successful sync
        debugPrint('Bitcoin sync successful.');
      },
      onFailure: () {
        // Update the online status on failure
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
        // Await the Liquid sync operation
        await ref.read(syncLiquidProvider.future);

        // Refresh and retrieve the last used Liquid address
        final liquidAddress = await ref.refresh(liquidLastUsedAddressProvider.future);
        ref.read(addressProvider.notifier).setLiquidAddress(liquidAddress);

        // Retrieve the Liquid balances
        final balances = await ref.read(liquidBalanceProvider.future);

        await ref.read(claimAndDeleteAllBoltzProvider.future);

        for (var balance in balances) {
          switch (AssetMapper.mapAsset(balance.assetId)) {
            case AssetId.USD:
              ref.read(balanceNotifierProvider.notifier).updateUsdBalance(balance.value);
              break;
            case AssetId.EUR:
              ref.read(balanceNotifierProvider.notifier).updateEurBalance(balance.value);
              break;
            case AssetId.BRL:
              ref.read(balanceNotifierProvider.notifier).updateBrlBalance(balance.value);
              break;
            case AssetId.LBTC:
              ref.read(balanceNotifierProvider.notifier).updateLiquidBalance(balance.value);
              break;
            default:
              break;
          }
        }

        return balances;
      },
      onSuccess: () {
        // Optional: Actions on successful sync
        debugPrint('Liquid sync successful.');
      },
      onFailure: () {
        // Update the online status on failure
      },
    );
  }
}

class BackgroundSyncNotifier extends SyncNotifier<WalletBalance> {
  Timer? _timer;

  @override
  Future<WalletBalance> build() async {
    // Perform the initial sync when the provider is built
    final initialBalance = ref.read(balanceNotifierProvider);

    // Set up periodic sync every 2 minutes
    _timer ??= Timer.periodic(const Duration(minutes: 2), (timer) async {
      await performSync();
    });

    return initialBalance;
  }

  @override
  Future<WalletBalance> performSync() async {
    return await handleSync(
      syncOperation: () async {
        setBackgroundSyncInProgress(true);
        try {

          final futures = [
            ref.read(liquidSyncNotifierProvider.notifier).performSync().catchError((e) {
              // Handle liquid sync error
              debugPrint('Liquid sync failed: $e');
              return null; // Return null or a default Balances instance
            }),
            ref.read(bitcoinSyncNotifierProvider.notifier).performSync().catchError((e) {
              // Handle bitcoin sync error
              debugPrint('Bitcoin sync failed: $e');
              return null; // Return null or a default value
            }),
            ref.refresh(coinosBalanceProvider.future).catchError((e) {
              // Handle coinos balance error
              debugPrint('Coinos balance fetch failed: $e');
              return null; // Return null or a default value
            }),
          ];

          final results = await Future.wait(futures);

          // Extract results from Future.wait
          final liquidBalances = results[0] as Balances;
          final bitcoinBalance = results[1] as int;
          final lightningBalance = results[2] as int?;

          // Update the WalletBalance model
          final balanceData = WalletBalance.updateFromAssets(
            liquidBalances,
            bitcoinBalance,
            lightningBalance ?? 0,
          );

          ref.read(balanceNotifierProvider.notifier).updateBalance(balanceData);

          return balanceData;
        } catch (e, stackTrace) {
          // Capture and rethrow errors to be handled by handleSync
          state = AsyncError(e, stackTrace);
          rethrow;
        } finally {
          setBackgroundSyncInProgress(false);
        }
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

  /// Updates the background sync progress state
  void setBackgroundSyncInProgress(bool inProgress) {
    Future.microtask(() {
      ref.read(backgroundSyncInProgressProvider.notifier).state = inProgress;
    });
  }

  @override
  void onDispose() {
    _timer?.cancel();
  }
}

/// Providers for the sync notifiers
final bitcoinSyncNotifierProvider =
AsyncNotifierProvider<BitcoinSyncNotifier, int>(BitcoinSyncNotifier.new);

final liquidSyncNotifierProvider =
AsyncNotifierProvider<LiquidSyncNotifier, Balances>(LiquidSyncNotifier.new);

final backgroundSyncNotifierProvider =
AsyncNotifierProvider<BackgroundSyncNotifier, WalletBalance>(BackgroundSyncNotifier.new);

/// Provider to track background sync progress
final backgroundSyncInProgressProvider = StateProvider<bool>((ref) => false);
