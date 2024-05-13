import 'package:Satsails/providers/transactions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:Satsails/models/adapters/transaction_adapters.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:Satsails/models/sideswap/sideswap_price_model.dart';
import 'package:Satsails/models/sideswap/sideswap_status_model.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/services/sideswap/sideswap.dart';

final sideswapServiceProvider = StateProvider.autoDispose<Sideswap>((ref) {
  final service = Sideswap();
  service.connect();
  return service;
});

final sideswapLoginStreamProvider = StreamProvider.autoDispose<void>((ref) {
  final service = ref.watch(sideswapServiceProvider);
  service.login();
  return service.loginStream.map((event) => event);
});

final sideswapServerStatusStream = StreamProvider.autoDispose<SideswapStatus>((ref) {
  ref.watch(sideswapLoginStreamProvider);
  final service = ref.watch(sideswapServiceProvider);
  service.status();
  final stream = service.statusStream;

  return stream.map((event) => SideswapStatus.fromJson(event));
});

final sideswapStatusProvider = StateNotifierProvider.autoDispose<SideswapStatusModel, SideswapStatus>((ref) {
  final status = ref.watch(sideswapServerStatusStream);
  return SideswapStatusModel(status.when(
    data:(value) => value,
    loading: () => SideswapStatus(),
    error: (error, stackTrace) => SideswapStatus(),
  ));
});

final pegInProvider = StateProvider.autoDispose<bool>((ref) => false);
final pegOutBlocksProvider = StateProvider.autoDispose<int>((ref) => 2);

final pegOutBitcoinCostProvider = StateProvider.autoDispose<double>((ref) {
  final chosenBlocks = ref.watch(pegOutBlocksProvider);
  final txSize = ref.watch(sideswapStatusProvider).pegOutBitcoinTxVsize;
  final rates = ref.watch(sideswapStatusProvider).bitcoinFeeRates ?? [];
  for (var rate in rates) {
    if (rate["blocks"] == chosenBlocks) {
      return rate["value"] * txSize;
    }
  }
  return 0.0;
});

final sideswapPegProvider = StreamProvider.autoDispose<SideswapPeg>((ref) async* {
  final pegIn = ref.watch(pegInProvider);
  final blocks = ref.watch(pegOutBlocksProvider);
  final service = ref.watch(sideswapServiceProvider);
  final liquidAddress = await ref.watch(liquidAddressProvider.future);
  final bitcoinAddress = await ref.watch(bitcoinAddressProvider.future);
  pegIn ? service.peg(recv_addr: liquidAddress.confidential, peg_in: pegIn) : service.peg(recv_addr: bitcoinAddress, peg_in: pegIn, blocks: blocks);

  yield* service.pegStream.map((event) => SideswapPeg.fromJson(event));
});


final sideswapPegStatusProvider = StreamProvider.autoDispose<SideswapPegStatus>((ref) async* {
  final orderId = await ref.watch(sideswapPegProvider.future).then((value) => value.orderId ?? "");
  final pegIn = ref.watch(pegInProvider);
  final service = ref.watch(sideswapServiceProvider);
  service.pegStatus(orderId: orderId, pegIn: pegIn);
  yield* service.pegStatusStream.map((event) => SideswapPegStatus.fromJson(event));
});

final closeSideswapProvider = Provider.autoDispose<void>((ref) {
  final service = ref.watch(sideswapServiceProvider);
  service.close();
});

final sideswapHiveStorageProvider = FutureProvider.autoDispose.family<void, String>((ref, orderId) async {
  final sideswapStatusProvider = await ref.watch(sideswapPegStatusProvider.future).then((value) => value);
  final box = await Hive.openBox('sideswapStatus');
  box.put(orderId, sideswapStatusProvider);
});

final sideswapAllPegsProvider = FutureProvider.autoDispose<List<SideswapPegStatus>>((ref) async {
  final box = await Hive.openBox('sideswapStatus');
  final keys = box.keys;
  final List<SideswapPegStatus> swaps = [];
  for (var key in keys) {
    final value = box.get(key);
    if (value != null) {
      swaps.add(value);
    }
  }
  swaps.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  return swaps;
});

final orderIdStatusProvider = StateProvider((ref) => '');
final pegInStatusProvider = StateProvider((ref) => false);

final sideswapStatusDetailsItemProvider = StreamProvider.autoDispose<SideswapPegStatus>((ref) async* {
  final service = ref.watch(sideswapServiceProvider);
  final orderId = ref.watch(orderIdStatusProvider.notifier).state;
  final pegIn = ref.watch(pegInStatusProvider.notifier).state;
  service.pegStatus(orderId: orderId, pegIn: pegIn);
  yield* service.pegStatusStream.map((event) => SideswapPegStatus.fromJson(event));
});

// exchange tokens

final sendBitcoinProvider = StateProvider.autoDispose<bool>((ref) => false);
final assetExchangeProvider = StateProvider.autoDispose<String>((ref) => '02f22f8d9c76ab41661a2729e4752e2c5d1a263012141b86ea98af5472df5189');

final sideswapPriceStreamProvider = StreamProvider.autoDispose<SideswapPrice>((ref) {
  final service = ref.watch(sideswapServiceProvider);
  final sendBitcoin = ref.watch(sendBitcoinProvider);
  final asset = ref.watch(assetExchangeProvider);
  final sendAmount = ref.watch(sendTxProvider).amount;
  if (sendAmount == 0) {
    return const Stream<SideswapPrice>.empty();
  }
  service.streamPrices(asset: asset, sendBitcoins: sendBitcoin, sendAmount: sendAmount);
  return service.priceStream.map((event) => SideswapPrice.fromJson(event));
});

final sideswapPriceUnsubscribeProvider = StreamProvider.autoDispose<void>((ref) {
  final service = ref.watch(sideswapServiceProvider);
  final asset = ref.watch(assetExchangeProvider);
  service.unsubscribePrice(asset: asset);
  return const Stream<void>.empty();
});

final sideswapPriceProvider = StateNotifierProvider.autoDispose<SideswapPriceModel, SideswapPrice>((ref) {
  final price = ref.watch(sideswapPriceStreamProvider);
  return SideswapPriceModel(price.when(
    data: (value) => value,
    loading: () => SideswapPrice(),
    error: (error, stackTrace) => SideswapPrice(),
  ));
});

final sideswapStartExchangeProvider = StreamProvider.autoDispose<SideswapStartExchange>((ref) {
  final service = ref.watch(sideswapServiceProvider);
  final asset = ref.watch(assetExchangeProvider);
  final price = ref.watch(sideswapPriceProvider);
  final sendBitcoin = ref.watch(sendBitcoinProvider);
  service.startExchange(asset: asset, price: price.price!, sendBitcoins: sendBitcoin, sendAmount: price.sendAmount!, recvAmount: price.recvAmount!);
  return service.exchangeStream.map((event) => SideswapStartExchange.fromJson(event));
});


final sideswapUploadInputsProvider = FutureProvider.autoDispose<SideswapPsetToSign>((ref) async {
  final state = await ref.read(sideswapStartExchangeProvider.future).then((value) => value);
  final receiveAddress = await ref.read(liquidAddressProvider.future).then((value) => value);
  final returnAddress = await ref.read(liquidNextAddressProvider.future).then((value) => value);
  final liquidUnspentUtxos = await ref.read(liquidUnspentUtxosProvider.future).then((value) => value);
  final sendAmount = ref.read(sideswapPriceProvider).sendAmount!;
  return await state.uploadInputs(returnAddress, liquidUnspentUtxos, receiveAddress.confidential, sendAmount).then((value) => value);
});

final sideswapSignPsetProvider = FutureProvider.autoDispose<String>((ref) async {
  final state = await ref.read(sideswapStartExchangeProvider.future).then((value) => value);
  final result = await ref.read(sideswapUploadInputsProvider.future).then((value) => value);
  final signedPset = await ref.read(signLiquidPsetStringProvider(result.pset).future).then((value) => value);
  final txId = await state.uploadPset(signedPset, result.submitId).then((value) => value);
  final box = await Hive.openBox('sideswapSwaps');
  box.put(state.orderId, txId);
  return txId;
});

final sideswapGetLiquidTxProvider = FutureProvider.autoDispose<List<Tx>>((ref) async {
  final box = await Hive.openBox('sideswapStatus');
  final liquidTransactions = ref.read(transactionNotifierProvider).liquidTransactions;

  final matchingTransactions = box.values.where((boxValue) {
    return liquidTransactions.any((liquidTransaction) => liquidTransaction.txid == boxValue.txid);
  }).cast<Tx>().toList();

  return Future.value(matchingTransactions);
});

final sideswapExchangeCompletionProvider = StreamProvider.autoDispose<SideswapExchangeState>((ref) {
  final service = ref.watch(sideswapServiceProvider);
  return service.exchangeDoneStream.map((event) => SideswapExchangeState.fromJson(event));
});

final sideswapExchangeStateProvider = StateNotifierProvider.autoDispose<SideswapExchangeStateModel, SideswapExchangeState>((ref) {
  final state = ref.watch(sideswapExchangeCompletionProvider);
  return SideswapExchangeStateModel(state.when(
    data: (value) => value,
    loading: () => SideswapExchangeState(orderId: '', status: '', price: 0, sendAsset: '', sendAmount: 0, recvAsset: '', recvAmount: 0),
    error: (error, stackTrace) => SideswapExchangeState(orderId: '', status: '', price: 0, sendAsset: '', sendAmount: 0, recvAsset: '', recvAmount: 0),
  ));
});