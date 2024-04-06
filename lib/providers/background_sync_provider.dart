import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:satsails/models/bitcoin_model.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/bitcoin_provider.dart';

class BackgroundSyncNotifier extends StateNotifier<void> {
  final Ref ref;

  BackgroundSyncNotifier(this.ref) : super(null) {
    Timer.periodic(Duration(seconds: 15), (timer) {
      _performSync();
    });
  }

  Future<void> _performSync() async {
    const maxAttempts = 3;
    int attempt = 0;

    while (attempt < maxAttempts) {
      try {
        final box = await Hive.openBox('bitcoin');
        final bitcoinModel = await ref.read(bitcoinProvider.future);
        await BitcoinModel(bitcoinModel).sync();
        final balance = await ref.read(getBalanceProvider.future);
        if (balance.total != 0) {
          box.put('balance', balance.total);
          final balanceModel = ref.read(balanceNotifierProvider.notifier);
          balanceModel.updateBtcBalance(balance.total);
        }
        break; // If the sync operation is successful, break the loop
      } catch (e) {
        if (attempt == maxAttempts - 1) {
          rethrow; // If this was the last attempt, rethrow the exception
        }
        attempt++;
      }
    }
  }
}

final backgroundSyncNotifierProvider = Provider.autoDispose((ref) {
  return BackgroundSyncNotifier(ref);
});
