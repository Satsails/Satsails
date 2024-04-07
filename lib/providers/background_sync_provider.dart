import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/bitcoin_provider.dart';

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
        final box = await Hive.openBox('bitcoin');
        ref.read(syncBitcoinProvider);
        final balance = await ref.read(getBalanceProvider.future);
        if (balance.total != 0) {
          box.put('balance', balance.total);
          final balanceModel = ref.read(balanceNotifierProvider.notifier);
          balanceModel.updateBtcBalance(balance.total);
        }
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

final backgroundSyncNotifierProvider = StateProvider.autoDispose((ref) {
  return BackgroundSyncNotifier(ref);
});
