import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/balance_model.dart';
import 'settings_provider.dart';
import 'bitcoin_provider.dart';

final initiliazeBalanceProvider = FutureProvider<Balance>((ref) async {
  final currency = ref.watch(settingsProvider).currency;
  final bitcoin = ref.watch(bitcoinNotifierProvider.notifier);

  return Balance(
    btcBalance: 0,
    liquidBalance: 0,
    usdBalance: 0,
    cadBalance: 0,
    eurBalance: 0,
    brlBalance: 0,
    currency: currency,
  );
});

final balanceNotifierProvider = StateNotifierProvider<BalanceModel, Balance>((ref) {
  final initialBalance = ref.watch(initiliazeBalanceProvider);

  return BalanceModel(initialBalance.when(
    data: (balance) => balance,
    loading: () => Balance(
      btcBalance: 0,
      liquidBalance: 0,
      usdBalance: 0,
      cadBalance: 0,
      eurBalance: 0,
      brlBalance: 0,
      currency: 'USD',
    ),
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});