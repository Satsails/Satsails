import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/bitcoin_model.dart';
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
    final settings = ref.read(onlineProvider.notifier).state;
    if (settings) {
      try {
        final bitcoinModel = await ref.read(bitcoinProvider.future);
        await BitcoinModel(bitcoinModel).asyncSync();
        await ref.read(getBalanceProvider.future);
      } catch (e) {
        print("Error during sync: $e");
      }
    }
  }
}

final backgroundSyncNotifierProvider = Provider((ref) {
  return BackgroundSyncNotifier(ref);
});
