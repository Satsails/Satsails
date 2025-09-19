import 'dart:async';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/models/breez/lnurl_webhook_manager.dart';
import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/providers/balance_provider.dart';
import 'package:Satsails/providers/breez_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/providers/sideshift_provider.dart';
import 'package:Satsails/providers/transactions_provider.dart';
import 'package:bdk_flutter/bdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:lwk/lwk.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart' as breez;

import 'package:Satsails/providers/eulen_transfer_provider.dart';
import 'package:Satsails/providers/nox_transfer_provider.dart';
import 'package:Satsails/providers/sideswap_provider.dart';

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

class BitcoinSyncNotifier extends SyncNotifier<void> {
  @override
  Future<void> build() async {}

  @override
  Future<void> performSync() async {
    return await handleSync(
        syncOperation: () async {
          final bitcoinModel = await ref.read(bitcoinModelProvider.future);
          await bitcoinModel.sync();
          final addressIndex = bitcoinModel.getAddress();
          final address = bitcoinModel.getAddressString();
          final balance = bitcoinModel.getBalance();

          ref.read(addressProvider.notifier).setBitcoinAddress(addressIndex, address);
          ref.read(balanceNotifierProvider.notifier).updateOnChainBtcBalance(balance.total.toInt());
        },
        onSuccess: () => debugPrint('Bitcoin sync successful.'),
        onFailure: () {
          debugPrint('Bitcoin sync failed after all retries. Refreshing provider.');
          ref.refresh(bitcoinProvider);
        });
  }
}

class LiquidSyncNotifier extends SyncNotifier<Balances> {
  @override
  Future<Balances> build() async => [];

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
        final currentBalance = ref.read(balanceNotifierProvider);
        final newBalancesMap = {for (var balance in balances) AssetMapper.mapAsset(balance.assetId): balance.value};
        final newWalletState = currentBalance.copyWith(
          liquidBtcBalance: newBalancesMap[AssetId.LBTC] ?? 0,
          liquidUsdtBalance: newBalancesMap[AssetId.USD] ?? 0,
          liquidEuroxBalance: newBalancesMap[AssetId.EUR] ?? 0,
          liquidDepixBalance: newBalancesMap[AssetId.BRL] ?? 0,
        );
        balanceNotifier.updateBalance(newWalletState);
        return balances;
      },
      onSuccess: () => debugPrint('Liquid sync successful.'),
      onFailure: () => debugPrint('Liquid sync failed.'),
    );
  }
}

class BackgroundSyncNotifier extends SyncNotifier<WalletBalance> {
  @override
  Future<WalletBalance> build() async => WalletBalance.empty();

  /// Gathers all transaction data from various sources and updates the UI.
  /// The async fetches within this method are run in parallel.
  Future<void> _gatherAndUpdateTransactions() async {
    // Run all async transaction fetches in parallel for speed.
    final transactionFutures = await Future.wait([
      ref.refresh(getBitcoinTransactionsProvider.future),
      ref.refresh(liquidTransactionsProvider.future),
      ref.read(listLightningPaymentsProvider(const breez.ListPaymentsRequest()).future),
    ]);

    // Read synchronous providers (local data)
    final sideswapPegTxs = ref.read(sideswapAllPegsProvider);
    final eulenPurchases = ref.read(eulenTransferProvider);
    final noxPurchases = ref.read(noxTransferProvider);
    final sideShiftShifts = ref.read(sideShiftShiftsProvider);

    final bitcoinTx = transactionFutures[0] as List<TransactionDetails>;
    final liquidTx = transactionFutures[1] as List<Tx>;
    final allLightningPayments = transactionFutures[2] as List<breez.Payment>;

    final rawData = RawTransactionData(
      bitcoinTxs: bitcoinTx,
      liquidTxs: liquidTx,
      sideswapPegTxs: sideswapPegTxs,
      eulenTxs: eulenPurchases,
      noxTxs: noxPurchases,
      lightningPayments: allLightningPayments,
      sideShiftShifts: sideShiftShifts,
    );

    ref.read(rawTransactionDataProvider.notifier).state = rawData;
    ref.read(transactionNotifierProvider.notifier).updateTransactions(rawData);
  }

  @override
  Future<WalletBalance> performSync() async {
    bool anySyncFailed = false;

    return await handleSync(
      syncOperation: () async {
        final previousBalance = await ref.refresh(balanceFutureProvider.future);

        // --- STEP 1: INSTANTLY LOAD LOCAL DATA ---
        debugPrint("Performing initial fast transaction load...");
        await _gatherAndUpdateTransactions();

        // --- STEP 2: RUN SLOW NETWORK SYNCS IN PARALLEL ---
        debugPrint("Starting slow network syncs in parallel...");
        final syncResults = await Future.wait([
          Future(() async {
            try {
              await ref.read(liquidSyncNotifierProvider.notifier).performSync();
              return true; // Success
            } catch (e) {
              debugPrint('Liquid sync failed within background sync: $e');
              return false; // Failure
            }
          }),
          Future(() async {
            try {
              await ref.read(bitcoinSyncNotifierProvider.notifier).performSync();
              return true; // Success
            } catch (e) {
              debugPrint('Bitcoin sync failed within background sync: $e');
              return false; // Failure
            }
          }),
          Future(() async {
            try {
              await ref.read(getFiatPurchasesProvider.future);
              return true; // Success
            } catch (e) {
              debugPrint('Fiat purchase fetch failed within background sync: $e');
              return true; // Not a critical failure
            }
          }),
        ]);

        // Check the results of the critical syncs
        anySyncFailed = !syncResults[0] || !syncResults[1];

        // --- STEP 3: RE-LOAD DATA AFTER SYNC ---
        debugPrint("Performing final transaction load after syncs...");
        await _gatherAndUpdateTransactions();

        // --- FINAL STEPS ---
        final latestBalance = ref.read(balanceNotifierProvider);
        _compareBalances(previousBalance, latestBalance);

        final hiveBox = await Hive.openBox<WalletBalance>('balanceBox');
        await hiveBox.put('balance', latestBalance);

        // Run final independent tasks in parallel
        debugPrint("Starting final background tasks in parallel...");
        await Future.wait([
          _updateSideShiftShifts(),
          Future(() async {
            try {
              await ref.read(setupLnAddressProvider.future);
            } on NotificationPermissionException catch (e) {
              debugPrint('Notification permission error: $e');
            } catch (e) {
              debugPrint('Error setting up LN address: $e');
            }
          }),
        ]);

        return latestBalance;
      },
      onSuccess: () {
        if (anySyncFailed) {
          ref.read(settingsProvider.notifier).setOnline(false);
          debugPrint('Background sync completed, but with failures. App is offline.');
        } else {
          ref.read(settingsProvider.notifier).setOnline(true);
          debugPrint('Background sync successful. App is online.');
        }
      },
      onFailure: () {
        ref.read(settingsProvider.notifier).setOnline(false);
        setBackgroundSyncInProgress(false);
        debugPrint('Background sync failed critically.');
      },
    );
  }

  Future<void> performFullUpdate() async {
    if (ref.read(backgroundSyncInProgressProvider)) return;
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
    ref.read(backgroundSyncInProgressProvider.notifier).state = inProgress;
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

  void _checkAndNotify({required String assetName, required int previousAmount, required int currentAmount}) {
    if (previousAmount < currentAmount) {
      final Map<String, String> assetTickerMap = {'USD': 'USDT', 'EUR': 'EUROX', 'BRL': 'DEPIX'};
      final balanceChange = BalanceChange(asset: assetTickerMap[assetName] ?? assetName, amount: currentAmount - previousAmount);
      ref.read(balanceChangeProvider.notifier).state = balanceChange;
    }
  }
}

final bitcoinSyncNotifierProvider = AsyncNotifierProvider<BitcoinSyncNotifier, void>(BitcoinSyncNotifier.new);
final liquidSyncNotifierProvider = AsyncNotifierProvider<LiquidSyncNotifier, Balances>(LiquidSyncNotifier.new);
final backgroundSyncNotifierProvider = AsyncNotifierProvider<BackgroundSyncNotifier, WalletBalance>(BackgroundSyncNotifier.new);
final backgroundSyncInProgressProvider = StateProvider<bool>((ref) => false);

