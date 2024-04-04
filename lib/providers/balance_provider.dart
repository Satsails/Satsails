import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/balance_model.dart';
import 'bitcoin_provider.dart';

final initializeBalanceProvider = FutureProvider.autoDispose<Balance>((ref) async {
  final balance = await ref.watch(updateBitcoinBalanceProvider.future);

  return Balance(
    btcBalance: balance,
    liquidBalance: 0,
    usdBalance: 0,
    cadBalance: 0,
    eurBalance: 0,
    brlBalance: 0,
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
    ),
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});

final totalBalanceInCurrencyProvider = FutureProvider.family.autoDispose<double, String>((ref, currency) async {
  final balanceModel = ref.watch(balanceNotifierProvider.notifier);
  return await balanceModel.totalBalanceInCurrency(currency);
});

final updateBtcBalanceProvider = FutureProvider.autoDispose<BalanceModel>((ref) async {
  final balanceModel = ref.read(balanceNotifierProvider.notifier);
  final updatedBalance = await ref.watch(updateBitcoinBalanceProvider.future);
  balanceModel.updateBtcBalance(updatedBalance);
  return balanceModel;
});

final currentBitcoinPriceInCurrencyProvider = FutureProvider.family.autoDispose<double, String>((ref, currency) async {
  final balanceModel = ref.watch(balanceNotifierProvider.notifier);
  return await balanceModel.currentBitcoinPriceInCurrency(currency);
});