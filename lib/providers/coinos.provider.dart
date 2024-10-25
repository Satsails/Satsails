import 'package:Satsails/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/coinos_ln_model.dart';

final coinosLnProvider = StateNotifierProvider<CoinosLnModel, CoinosLn?>((ref) {
  return CoinosLnModel();
});

final loginProvider = FutureProvider<void>((ref) async {
  final username = ref.read(userProvider).paymentId;
  final password = ref.read(userProvider).recoveryCode;
  await ref.read(coinosLnProvider.notifier).login(username, password);
});

final registerProvider = FutureProvider.family<void, Map<String, String>>((ref, credentials) async {
  final username = ref.read(userProvider).paymentId;
  final password = ref.read(userProvider).recoveryCode;
  await ref.read(coinosLnProvider.notifier).register(username, password);
});

final createInvoiceProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, params) async {
  await ref.read(coinosLnProvider.notifier).createInvoice(params['amount'], params['memo']);
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
  return ref.read(userProvider).paymentId + '@coinos.com';
});
