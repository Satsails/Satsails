import 'dart:async';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/boltz_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';

class BitcoinSyncNotifier extends StateNotifier<void> {
  final Ref ref;

  BitcoinSyncNotifier(this.ref) : super(null) {
    _initializeSync();
  }

  void _initializeSync() {
    performSync();
  }

  Future<void> performSync() async {
    const maxAttempts = 3;
    int attempt = 0;

    try {
      while (attempt < maxAttempts) {
        try {
          _setBackgroundSyncInProgress(true);
          await ref.watch(syncBitcoinProvider.future);
          final address = await ref.refresh(lastUsedAddressProvider.future);
          ref.read(addressProvider.notifier).setBitcoinAddress(address);
          ref.read(updateBitcoinTransactionsProvider);
          await ref.read(claimAndDeleteAllBoltzProvider.future);

          break;
        } catch (e) {
          if (attempt == maxAttempts - 1) {
            ref.read(settingsProvider.notifier).setOnline(false);
            rethrow;
          }
          attempt++;
        }
      }
    } finally {
      _setBackgroundSyncInProgress(false);
    }
  }

  void _setBackgroundSyncInProgress(bool inProgress) {
    Future.microtask(() {
      ref.read(backgroundSyncInProgressProvider.notifier).state = inProgress;
    });
  }
}

class LiquidSyncNotifier extends StateNotifier<void> {
  final Ref ref;

  LiquidSyncNotifier(this.ref) : super(null) {
    _initializeSync();
  }

  void _initializeSync() {
    performSync();
  }

  Future<void> performSync() async {
    const maxAttempts = 3;
    int attempt = 0;

    try {
      while (attempt < maxAttempts) {
        try {
          _setBackgroundSyncInProgress(true);
          await ref.read(syncLiquidProvider.future);
          final liquidAddress = await ref.refresh(liquidLastUsedAddressProvider.future);
          ref.read(addressProvider.notifier).setLiquidAddress(liquidAddress);
          ref.read(updateLiquidTransactionsProvider);
          ref.read(settingsProvider.notifier).setOnline(true);
          await ref.read(claimAndDeleteAllBitcoinBoltzProvider.future);

          break;
        } catch (e) {
          if (attempt == maxAttempts - 1) {
            ref.read(settingsProvider.notifier).setOnline(false);
            rethrow;
          }
          attempt++;
        }
      }
    } finally {
      _setBackgroundSyncInProgress(false);
    }
  }


  void _setBackgroundSyncInProgress(bool inProgress) {
    Future.microtask(() {
      ref.read(backgroundSyncInProgressProvider.notifier).state = inProgress;
    });
  }
}

class BackgroundSyncNotifier extends StateNotifier<void> {
  final Ref ref;

  BackgroundSyncNotifier(this.ref) : super(null) {
    _initializeSync();
  }

  void _initializeSync() {
    performSync();
  }

  Future<void> performSync() async {
    await Future.wait([
      ref.read(bitcoinSyncNotifierProvider).performSync(),
      ref.read(liquidSyncNotifierProvider).performSync(),
    ]);
  }
}

final backgroundSyncNotifierProvider = Provider((ref) {
  final notifier = BackgroundSyncNotifier(ref);
  ref.onDispose(() {
    notifier.dispose();
  });
  return notifier;
});

final bitcoinSyncNotifierProvider = Provider((ref) {
  return BitcoinSyncNotifier(ref);
});

final liquidSyncNotifierProvider = Provider((ref) {
  return LiquidSyncNotifier(ref);
});


