import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/coinos_ln_model.dart';

final coinosLnProvider = AsyncNotifierProvider<CoinosLnModel, CoinosLn>(CoinosLnModel.new);

final loginProvider = FutureProvider.family<void, Map<String, String>>((ref, credentials) async {
  final password = ref.read(coinosLnProvider).value?.password ?? '';
  await ref.read(coinosLnProvider.notifier).login(credentials['username']!, password);
});

final registerProvider = FutureProvider.family<void, Map<String, String>>((ref, credentials) async {
  await ref.read(coinosLnProvider.notifier).register(credentials['username']!);
  ref.read(loginProvider(credentials));
});


final createInvoiceProvider = FutureProvider.autoDispose<String>((ref) async {
  final amount = ref.watch(inputAmountProvider);
  final currency = ref.watch(inputCurrencyProvider);
  final currencyConverter = ref.read(currencyNotifierProvider);

  if (amount == '' || amount == '0.0') {
    return ref.read(lnurlProvider);
  }

  final amountToDisplay = calculateAmountInSatsToDisplay(amount, currency, currencyConverter);

  final invoice = await ref.read(coinosLnProvider.notifier).createInvoice(amountToDisplay);

  return invoice;
});

final getInvoicesProvider = FutureProvider<List<dynamic>?>((ref) async {
  return await ref.read(coinosLnProvider.notifier).getInvoices();
});

final sendPaymentProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
  await ref.read(coinosLnProvider.notifier).sendPayment(params['address'], params['amount']);
});

final getTransactionsProvider = FutureProvider<List<dynamic>?>((ref) async {
  return await ref.read(coinosLnProvider.notifier).getTransactions();
});

final lnurlProvider = StateProvider<String>((ref) {
  final username = ref.watch(coinosLnProvider).value?.username ?? '';
  return '$username@coinos.io';
});
