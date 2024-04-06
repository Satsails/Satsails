import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:satsails/models/bitcoin_model.dart';
import 'package:satsails/providers/balance_provider.dart';
import 'package:satsails/providers/bitcoin_provider.dart';
import 'package:satsails/providers/settings_provider.dart';

class BackgroundSyncNotifier extends StateNotifier<void> {
  final Ref ref;

  BackgroundSyncNotifier(this.ref) : super(null) {
    Timer.periodic(Duration(seconds: 15), (timer) {
      _performSync();
    });
  }

  Future<void> _performSync() async {
    final settings = ref.read(onlineProvider);
    if (settings) {
      final box = await Hive.openBox('bitcoin');
      final bitcoinModel = await ref.read(bitcoinProvider.future);
      await BitcoinModel(bitcoinModel).asyncSync();
      final balance = await ref.read(getBalanceProvider.future);
      if (balance.total == 0) {
        return null;
      } else {
        box.put('balance', balance.total);
        final balanceModel = ref.read(balanceNotifierProvider.notifier);
        balanceModel.updateBtcBalance(balance.total);
      }
    }
  }
}

final backgroundSyncNotifierProvider = Provider((ref) {
  return BackgroundSyncNotifier(ref);
});
