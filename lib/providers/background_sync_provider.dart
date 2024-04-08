import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/bitcoin_provider.dart';
import 'package:satsails/providers/liquid_provider.dart';

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
        final liquidBox = await Hive.openBox('liquid');
        final balanceModel = ref.read(bitcoinBalanceNotifierProvider.notifier);
        ref.read(syncBitcoinProvider);
        final bitcoinBalance = await ref.read(getBitcoinBalanceProvider.future);
        if (bitcoinBalance.total != 0) {
          bitcoinBox.put('balance', bitcoinBalance.total);
          balanceModel.updateBtcBalance(bitcoinBalance.total);
        }
        ref.read(syncLiquidProvider);
        final liquidBalance = await ref.read(liquidBalanceProvider.future);
        // update liquid balances from here and in the box
        break;
      } catch (e) {
        if (attempt == maxAttempts - 1) {
          rethrow;
        }
        attempt++;
      }
    }
  }
}

final backgroundSyncNotifierProvider = StateProvider((ref) {
  return BackgroundSyncNotifier(ref);
});
