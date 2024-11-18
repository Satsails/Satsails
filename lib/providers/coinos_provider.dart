import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart' as bdk;
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

final updateUserProvider = FutureProvider.autoDispose.family<void, String>((ref, username) async {
  await ref.read(coinosLnProvider.notifier).updateUser(username);
});

final shouldMigrateProvider = FutureProvider.autoDispose<bool>((ref) async {
  return await ref.read(coinosLnProvider.notifier).shouldMigrateUsernameAndPassword();
});

final migrateUsernameAndPasswordProvider = FutureProvider.autoDispose<void>((ref) async {
  await ref.read(coinosLnProvider.notifier).migrateUsernameAndPassword();
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

final createInvoiceForSwapProvider = FutureProvider.autoDispose.family<String, String>((ref, type) async {
  final amount = ref.watch(sendTxProvider).amount;
  return await ref.read(coinosLnProvider.notifier).createInvoice(amount, type: type);
});

final sendPaymentProvider = FutureProvider.autoDispose<void>((ref) async {
  final address = ref.watch(sendTxProvider).address;
  final amount = ref.watch(sendTxProvider).amount;
  await ref.read(coinosLnProvider.notifier).sendPayment(address, amount);
});

final sendCoinosBitcoinProvider = FutureProvider.autoDispose<void>((ref) async {
  final address = ref.watch(sendTxProvider).address;
  final amount = ref.watch(sendTxProvider).amount;
  final fee = await ref.watch(bdk.getCustomFeeRateProvider.future);
  await ref.read(coinosLnProvider.notifier).sendBitcoinPayment(address, amount, fee);
});

final sendCoinosLiquidProvider = FutureProvider.autoDispose<void>((ref) async {
  final address = ref.watch(sendTxProvider).address;
  final amount = ref.watch(sendTxProvider).amount;
  // final fee = await ref.watch(lwk.getCustomFeeRateProvider.future);
  await ref.read(coinosLnProvider.notifier).sendLiquidPayment(address, amount, 0.1);
});

final coinosBalanceProvider = FutureProvider<int>((ref) async {
  return await ref.read(coinosLnProvider.notifier).getBalance();
});

final getTransactionsProvider = FutureProvider.autoDispose<List<CoinosPayment>>((ref) async {
  final response = await ref.read(coinosLnProvider.notifier).getTransactions();

  return response;
});

final getPaymentsProvider = FutureProvider.autoDispose<List<CoinosPayment>>((ref) async {
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