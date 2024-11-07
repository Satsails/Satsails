import 'dart:async';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/providers/coinos.provider.dart';
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
    return await performSync();
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

        return balance.total;
      },
      onSuccess: () {
        // Optional: Actions on successful sync
        debugPrint('Bitcoin sync successful.');
      },
      onFailure: () {
        // Update the online status on failure
        ref.read(settingsProvider.notifier).setOnline(false);
      },
    );
  }
}

class LiquidSyncNotifier extends SyncNotifier<Balances> {
  @override
  Future<Balances> build() async {
    return await performSync();
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

        return balances; // Assuming balances is of type List<Balances>
      },
      onSuccess: () {
        // Optional: Actions on successful sync
        debugPrint('Liquid sync successful.');
      },
      onFailure: () {
        // Update the online status on failure
        ref.read(settingsProvider.notifier).setOnline(false);
      },
    );
  }
}

class BackgroundSyncNotifier extends SyncNotifier<WalletBalance> {
  Timer? _timer;

  @override
  Future<WalletBalance> build() async {
    // Perform the initial sync when the provider is built
    final initialBalance = await performSync();

    // Set up periodic sync every 2 minutes
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) async {
      await performSync();
    });

    return initialBalance;
  }

  @override
  Future<WalletBalance> performSync() async {
    return await handleSync(
      syncOperation: () async {
        // Indicate that background sync is in progress
        setBackgroundSyncInProgress(true);
        try {
          // Perform Bitcoin and Liquid sync concurrently
          final results = await Future.wait([
            ref.read(liquidSyncNotifierProvider.notifier).performSync(),
            ref.read(bitcoinSyncNotifierProvider.notifier).performSync(),
            ref.refresh(coinosBalanceProvider.future), // Assuming this returns LightningBalance
          ]);

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

          return balanceData;
        } catch (e, stackTrace) {
          // Capture and rethrow errors to be handled by handleSync
          state = AsyncError(e, stackTrace);
          rethrow;
        } finally {
          // Indicate that background sync has completed
          setBackgroundSyncInProgress(false);
        }
      },
      onSuccess: () {
        // Optional: Actions on successful sync
        debugPrint('Background sync successful.');
      },
      onFailure: () {
        // Optional: Actions on sync failure
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
