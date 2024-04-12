import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:satsails/helpers/asset_mapper.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/bitcoin_provider.dart';
import 'package:satsails/providers/liquid_provider.dart';
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
        final bitcoinBalance = await ref.read(getBitcoinBalanceProvider.future);
        if (bitcoinBalance.total != 0) {
          bitcoinBox.put('bitcoin', bitcoinBalance.total);
          balanceModel.updateBtcBalance(bitcoinBalance.total);
        }
        await ref.read(syncLiquidProvider);
        final liquidBalance = await ref.read(liquidBalanceProvider.future);
        updateLiquidBalances(liquidBalance);
        ref.read(updateTransactionsProvider);

        break;
      } catch (e) {
        if (attempt == maxAttempts - 1) {
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
      switch (AssetMapper.mapAsset(balance.$1)){
        case 'USD':
          balance = balance.$2 ~/ 100000000;
          if (balance == 0){
            break;
          }
          liquidBox.put('usd', balance);
          balanceModel.updateUsdBalance(balance);
          break;
        case 'EUR':
          balance = balance.$2 ~/ 100000000;
          if (balance == 0){
            break;
          }
          liquidBox.put('eur', balance);
          balanceModel.updateEurBalance(balance);
          break;
        case 'BRL':
          balance = balance.$2 ~/ 100000000;
          if (balance == 0){
            break;
          }
          liquidBox.put('brl', balance);
          balanceModel.updateBrlBalance(balance);
          break;
        case 'L-BTC':
          if (balance.$2 == 0){
            break;
          }
          liquidBox.put('liquid', balance.$2);
          balanceModel.updateLiquidBalance(balance.$2);
          break;

      }
    }
  }
}

final backgroundSyncNotifierProvider = StateProvider((ref) {
  return BackgroundSyncNotifier(ref);
});
