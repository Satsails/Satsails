import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/coinos.provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/balance_model.dart';
import 'package:Satsails/providers/background_sync_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';

final initializeBalanceProvider = FutureProvider<WalletBalance>((ref) async {
  final online = ref.watch(settingsProvider).online;
  if (online) {
    await ref.read(backgroundSyncNotifierProvider.future);
    await ref.read(updateCurrencyProvider.future);
  }

  final bitcoinBalance = await ref.watch(getBitcoinBalanceProvider.future);
  final liquidBalances = await ref.watch(liquidBalanceProvider.future);
  final lightningBalance = await ref.refresh(coinosBalanceProvider.future);

  final balanceData = WalletBalance.updateFromAssets(liquidBalances, bitcoinBalance.total, lightningBalance);

  return balanceData;
});


final balanceNotifierProvider = StateNotifierProvider<BalanceNotifier, WalletBalance>((ref) {
  return BalanceNotifier(ref);
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

final lightningBalanceInFormatProvider = StateProvider.family.autoDispose<String, String>((ref, denomination) {
  final balance = ref.watch(balanceNotifierProvider);
  return balance.lightningBalanceInDenominationFormatted(denomination);
});