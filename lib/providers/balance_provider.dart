import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:satsails/models/balance_model.dart';
import 'package:satsails/providers/background_sync_provider.dart';

final initializeBalanceProvider = FutureProvider.autoDispose<Balance>((ref) async {
  final bitcoinBox = await Hive.openBox('bitcoin');
  final liquidBox = await Hive.openBox('liquid');
  final bitcoinBalance = bitcoinBox.get('bitcoin', defaultValue: 0) as int;
  final liquidBalance = liquidBox.get('liquid', defaultValue: 0) as int;
  final usdBalance = liquidBox.get('usd', defaultValue: 0) as int;
  final eurBalance = liquidBox.get('eur', defaultValue: 0) as int;
  final brlBalance = liquidBox.get('brl', defaultValue: 0) as int;
  ref.read(backgroundSyncNotifierProvider);

  return Balance(
    btcBalance: bitcoinBalance,
    liquidBalance: liquidBalance,
    usdBalance: usdBalance,
    eurBalance: eurBalance,
    brlBalance: brlBalance,
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
      eurBalance: 0,
      brlBalance: 0,
    ),
    error: (Object error, StackTrace stackTrace) {
      throw error;
    },
  ));
});

final totalBalanceInCurrencyProvider = FutureProvider.family.autoDispose<double, String>((ref, currency) async {
  final balanceModel = ref.watch(balanceNotifierProvider);
  return await balanceModel.totalBalanceInCurrency(currency);
});

final totalBalanceInDenominationProvider = FutureProvider.family.autoDispose<String, String>((ref, denomination) async {
  final balanceModel = ref.watch(balanceNotifierProvider);
  return balanceModel.totalBalanceInDenominationFormatted(denomination);
});

final currentBitcoinPriceInCurrencyProvider = FutureProvider.family.autoDispose<double, String>((ref, currency) async {
  final balanceModel = ref.watch(balanceNotifierProvider);
  return await balanceModel.currentBitcoinPriceInCurrency(currency);
});

final percentageChangeProvider = FutureProvider.autoDispose<Percentage>((ref) async {
  final balanceModel = ref.watch(balanceNotifierProvider);
  return await balanceModel.percentageOfEachCurrency();
});

final btcBalanceInFormatProvider = StateProvider.family.autoDispose<String, String>((ref, denomination) {
  final balance = ref.watch(balanceNotifierProvider);
  return balance.btcBalanceInDenominationFormatted(denomination);
});

final liquidBalanceInFormatProvider = StateProvider.family.autoDispose<String, String>((ref, denomination) {
  final balance = ref.watch(balanceNotifierProvider);
  return balance.liquidBalanceInDenominationFormatted(denomination);
});