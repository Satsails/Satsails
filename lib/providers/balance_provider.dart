import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';

final initializeBalanceProvider = FutureProvider.autoDispose<Balance>((ref) async {
  final online = ref.watch(settingsProvider).online;
  final bitcoinBox = await Hive.openBox('bitcoin');
  final liquidBox = await Hive.openBox('liquid');
  final bitcoinBalance = bitcoinBox.get('bitcoin', defaultValue: 0) as int;
  final liquidBalance = liquidBox.get('liquid', defaultValue: 0) as int;
  final usdBalance = liquidBox.get('usd', defaultValue: 0) as int;
  final eurBalance = liquidBox.get('eur', defaultValue: 0) as int;
  final brlBalance = liquidBox.get('brl', defaultValue: 0) as int;
  if (online) {
    await ref.read(updateCurrencyProvider.future);
    ref.read(backgroundSyncNotifierProvider);
  }
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

final totalBalanceInFiatProvider = StateProvider.family.autoDispose<String, String>((ref, currency)  {
  final balanceModel = ref.watch(balanceNotifierProvider);
  final conversions = ref.watch(currencyNotifierProvider);

  return balanceModel.totalBalanceInCurrency(currency, conversions).toStringAsFixed(2);
});

final totalBalanceInDenominationProvider = StateProvider.family.autoDispose<String, String>((ref, denomination){
  final balanceModel = ref.watch(balanceNotifierProvider);
  final conversions = ref.watch(currencyNotifierProvider);
  return balanceModel.totalBalanceInDenominationFormatted(denomination, conversions);
});

final currentBitcoinPriceInCurrencyProvider = StateProvider.family.autoDispose<double, CurrencyParams>((ref, params) {
  final balanceModel = ref.watch(balanceNotifierProvider);
  return balanceModel.currentBitcoinPriceInCurrency(params, ref.watch(currencyNotifierProvider));
});

final percentageChangeProvider = StateProvider.autoDispose<Percentage>((ref)  {
  final balanceModel = ref.watch(balanceNotifierProvider);
  final conversions = ref.watch(currencyNotifierProvider);
  return balanceModel.percentageOfEachCurrency(conversions);
});

final btcBalanceInFormatProvider = StateProvider.family.autoDispose<String, String>((ref, denomination) {
  final balance = ref.watch(balanceNotifierProvider);
  return balance.btcBalanceInDenominationFormatted(denomination);
});

final liquidBalanceInFormatProvider = StateProvider.family.autoDispose<String, String>((ref, denomination) {
  final balance = ref.watch(balanceNotifierProvider);
  return balance.liquidBalanceInDenominationFormatted(denomination);
});