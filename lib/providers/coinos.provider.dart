import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/currency_conversions_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/services/coinos/coinos_push_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/coinos_ln_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();

final initialCoinosProvider = FutureProvider.autoDispose<CoinosLn>((ref) async {
  final token = await _storage.read(key: 'coinosToken') ?? '';
  final username = await _storage.read(key: 'coinosUsername') ?? '';
  final password = await _storage.read(key: 'coinosPassword') ?? '';
  return CoinosLn(token: token, username: username, password: password);
});

final coinosLnProvider = StateNotifierProvider.autoDispose<CoinosLnModel, CoinosLn>((ref) {
  final initialCoinos = ref.watch(initialCoinosProvider);

  return initialCoinos.when(
    data: (coinos) => CoinosLnModel(CoinosLn(token: coinos.token, username: coinos.username, password: coinos.password)),
    loading: () => CoinosLnModel(CoinosLn(token: '', username: '', password: '')),
    error: (error, stackTrace) {
      throw error;
    },
  );
});

final loginProvider = FutureProvider.autoDispose<void>((ref) async {
  await ref.read(coinosLnProvider.notifier).login();
});

final registerProvider = FutureProvider.autoDispose<void>((ref) async {
  await ref.read(coinosLnProvider.notifier).register();
  await ref.read(loginProvider.future);
});

final createInvoiceProvider = FutureProvider.autoDispose<String>((ref) async {
  final amount = ref.watch(inputAmountProvider);
  final currency = ref.watch(inputCurrencyProvider);
  final currencyConverter = ref.read(currencyNotifierProvider);

  if (amount.isEmpty || amount == '0.0') {
    return ref.read(lnurlProvider);
  }

  final amountToDisplay = calculateAmountInSatsToDisplay(amount, currency, currencyConverter);
  return await ref.read(coinosLnProvider.notifier).createInvoice(amountToDisplay);
});

final sendPaymentProvider = FutureProvider.autoDispose<void>((ref) async {
  final address = ref.watch(sendTxProvider).address;
  final amount = ref.watch(sendTxProvider).amount;
  await ref.read(coinosLnProvider.notifier).sendPayment(address, amount);
});

final coinosBalanceProvider = FutureProvider<int>((ref) async {
  return await ref.refresh(getTransactionsProvider.future).then((value) => value?['balance'] ?? 0);
});

final getTransactionsProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final response = await ref.read(coinosLnProvider.notifier).getTransactions();

  return response;
});

final lnurlProvider = StateProvider.autoDispose<String>((ref) {
  final username = ref.watch(coinosLnProvider).username;
  return '$username@coinos.io';
});

final loginIntoWebsocketProvider = FutureProvider.autoDispose<CoisosPushNotifications>((ref) async {
  final token = ref.watch(coinosLnProvider).token;
  final service = CoisosPushNotifications();
  service.connect(token);

  ref.onDispose(() => service.close());

  return service;
});

final coinosPaymentStreamProvider = StreamProvider.autoDispose<Map<String, dynamic>>((ref) async* {
  final pushNotificationsService = await ref.watch(loginIntoWebsocketProvider.future);
  yield* pushNotificationsService.paymentStream;
});


