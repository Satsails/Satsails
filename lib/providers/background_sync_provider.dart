import 'dart:async';
import 'package:Satsails/providers/coinos.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';

final syncOnAppOpenProvider = StateProvider<bool>((ref) => false);

/// Abstract class to define common sync behavior
abstract class SyncNotifier extends AsyncNotifier<void> {
  /// Performs the sync operation
  Future<void> performSync();

  /// Handles the sync with retry logic
  @protected
  Future<void> handleSync({
    required Future<void> Function() syncOperation,
    required void Function() onSuccess,
    required void Function() onFailure,
    int maxAttempts = 3,
  }) async {
    int attempt = 0;
    while (attempt < maxAttempts) {
      try {
        await syncOperation();
        onSuccess();
        break;
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
  }
}

class BitcoinSyncNotifier extends SyncNotifier {
  @override
  Future<void> performSync() async {
    await handleSync(
      syncOperation: () async {
        await ref.read(syncBitcoinProvider.future);
        final address = await ref.refresh(lastUsedAddressProvider.future);
        ref.read(addressProvider.notifier).setBitcoinAddress(address);
        await ref.read(claimAndDeleteAllBitcoinBoltzProvider.future);
      },
      onSuccess: () {
      },
      onFailure: () {
        ref.read(settingsProvider.notifier).setOnline(false);
      },
    );
  }

  @override
  FutureOr<void> build() {}
}

class LiquidSyncNotifier extends SyncNotifier {
  @override
  Future<void> performSync() async {
    await handleSync(
      syncOperation: () async {
        await ref.read(syncLiquidProvider.future);
        final liquidAddress = await ref.refresh(liquidLastUsedAddressProvider.future);
        ref.read(addressProvider.notifier).setLiquidAddress(liquidAddress);
        ref.read(settingsProvider.notifier).setOnline(true);
        await ref.read(claimAndDeleteAllBoltzProvider.future);
      },
      onSuccess: () {
      },
      onFailure: () {
        ref.read(settingsProvider.notifier).setOnline(false);
      },
    );
  }

  @override
  FutureOr<void> build() {}
}

class BackgroundSyncNotifier extends AsyncNotifier<void> {
  Timer? _timer;

  @override
  Future<void> build() async {
    // Perform initial sync when the app starts
    await performSync();

    // Set up periodic sync every 2 minutes
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) async {
      await performSync();
    });
  }

  /// Performs Bitcoin, Liquid, and transactions sync operations
  Future<void> performSync() async {
    setBackgroundSyncInProgress(true);
    try {
      // Perform Bitcoin and Liquid sync concurrently
      await Future.wait([
        ref.read(liquidSyncNotifierProvider.notifier).performSync(),
        ref.read(bitcoinSyncNotifierProvider.notifier).performSync(),
      ]);

      // Fetch transactions and update the balance
      await ref.refresh(getTransactionsProvider.future);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    } finally {
      setBackgroundSyncInProgress(false);
    }
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
AsyncNotifierProvider<BitcoinSyncNotifier, void>(BitcoinSyncNotifier.new);

final liquidSyncNotifierProvider =
AsyncNotifierProvider<LiquidSyncNotifier, void>(LiquidSyncNotifier.new);

final backgroundSyncNotifierProvider =
AsyncNotifierProvider<BackgroundSyncNotifier, void>(BackgroundSyncNotifier.new);

/// Provider to track background sync progress
final backgroundSyncInProgressProvider = StateProvider<bool>((ref) => false);
