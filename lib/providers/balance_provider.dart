import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';

final balanceNotifierProvider = StateNotifierProvider<BalanceNotifier, WalletBalance>((ref) {
  return BalanceNotifier(ref);
});

final balanceChangeProvider = StateProvider<BalanceChange?>((ref) => null);

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

final lightningBalanceInFormatProvider = StateProvider.family.autoDispose<String, String>((ref, denomination) {
  final balance = ref.watch(balanceNotifierProvider);
  return balance.lightningBalanceInDenominationFormatted(denomination);
});