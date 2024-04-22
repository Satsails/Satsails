import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:satsails/helpers/asset_mapper.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/bitcoin_provider.dart';
import 'package:satsails/providers/liquid_provider.dart';
import 'package:satsails/providers/settings_provider.dart';
import 'package:satsails/providers/transactions_provider.dart';

class BackgroundSyncNotifier extends StateNotifier<void> {
  final Ref ref;

  BackgroundSyncNotifier(this.ref) : super(null) {
    _performSync();
    Timer.periodic(const Duration(seconds: 60), (timer) {
      _performSync();
    });
  }

  Future<void> _performSync() async {
    const maxAttempts = 3;
    int attempt = 0;

    while (attempt < maxAttempts) {
      try {
        final bitcoinBox = await Hive.openBox('bitcoin');
        final balanceModel = ref.read(balanceNotifierProvider.notifier);
        await ref.read(syncBitcoinProvider);
        final bitcoinBalance = await ref.refresh(getBitcoinBalanceProvider.future);
        if (bitcoinBalance.total != 0) {
          bitcoinBox.put('bitcoin', bitcoinBalance.total);
          balanceModel.updateBtcBalance(bitcoinBalance.total);
        }
        ref.read(syncLiquidProvider);
        final liquidBalance = await ref.refresh(liquidBalanceProvider.future);
        updateLiquidBalances(liquidBalance);
        ref.read(updateTransactionsProvider);
        ref.read(settingsProvider.notifier).setOnline(true);

        break;
      } catch (e) {
        if (attempt == maxAttempts - 1) {
          ref.read(settingsProvider.notifier).setOnline(false);
          rethrow;
        }
        attempt++;
      }
    }
  }

  void updateLiquidBalances(balances) async {
    final balanceModel = ref.read(balanceNotifierProvider.notifier);
    final liquidBox = await Hive.openBox('liquid');
    for (var balance in balances){
      switch (AssetMapper.mapAsset(balance.assetId)){
        case AssetId.USD:
          balance = balance.value ~/ 100000000;
          if (balance == 0){
            break;
          }
          liquidBox.put('usd', balance);
          balanceModel.updateUsdBalance(balance);
          break;
        case AssetId.EUR:
          balance = balance.value ~/ 100000000;
          if (balance == 0){
            break;
          }
          liquidBox.put('eur', balance);
          balanceModel.updateEurBalance(balance);
          break;
        case AssetId.BRL:
          balance = balance.value ~/ 100000000;
          if (balance == 0){
            break;
          }
          liquidBox.put('brl', balance);
          balanceModel.updateBrlBalance(balance);
          break;
        case AssetId.LBTC:
          if (balance.value == 0){
            break;
          }
          liquidBox.put('liquid', balance.value);
          balanceModel.updateLiquidBalance(balance.value);
          break;
        default:
          break;
      }
    }
  }
}

final backgroundSyncNotifierProvider = StateProvider((ref) {
  return BackgroundSyncNotifier(ref);
});
