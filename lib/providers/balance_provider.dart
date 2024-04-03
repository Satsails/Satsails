import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/balance_model.dart';
import 'settings_provider.dart';
import 'bitcoin_provider.dart';

final initializeBalanceProvider = FutureProvider.autoDispose<Balance>((ref) async {
  final currency = ref.watch(settingsProvider).currency;
  ref.watch(syncBitcoinProvider);
  final balance = await ref.watch(getBalanceProvider.future);

  return Balance(
    btcBalance: balance.total,
    liquidBalance: 0,
    usdBalance: 0,
    cadBalance: 0,
    eurBalance: 0,
    brlBalance: 0,
    currency: currency,
  );
});

final balanceNotifierProvider = StateNotifierProvider.autoDispose<BalanceModel, Balance>((ref) {
  final initialBalance = ref.watch(initializeBalanceProvider);

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

final totalBalanceInCurrencyProvider = FutureProvider.autoDispose<double>((ref) async {
  final balanceModel = ref.watch(balanceNotifierProvider.notifier);
  return await balanceModel.totalBalanceInCurrency();
});