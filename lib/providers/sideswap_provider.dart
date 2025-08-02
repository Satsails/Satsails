import 'dart:async';
import 'dart:ui';

import 'package:Satsails/models/sideswap/sideswap_markets_model.dart';
import 'package:Satsails/providers/address_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:Satsails/models/sideswap/sideswap_quote_model.dart';
import 'package:Satsails/models/sideswap/sideswap_status_model.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/services/sideswap/sideswap.dart';

final appLifecycleStateProvider = StateProvider.autoDispose<AppLifecycleState>((ref) => AppLifecycleState.resumed);

final sideswapServiceProvider = StateProvider.autoDispose<Sideswap>((ref) {
  ref.watch(appLifecycleStateProvider);
  final service = Sideswap();
  service.connect();
  service.login();

  ref.onDispose(
        () => service.close(),
  );

  return service;
});

final sideswapServerStatusStream = StreamProvider.autoDispose<SideswapStatus>((ref) {
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

final pegInProvider = StateProvider<bool>((ref) => false);
final pegOutBlocksProvider = StateProvider<int>((ref) => 2);

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
  final liquidAddress = ref.read(addressProvider).liquidAddress;
  final bitcoinAddress = ref.read(addressProvider).bitcoinAddress;
  pegIn ? service.peg(recv_addr: liquidAddress, peg_in: pegIn) : service.peg(recv_addr: bitcoinAddress, peg_in: pegIn, blocks: blocks);

  yield* service.pegStream.map((event) => SideswapPeg.fromJson(event));
});


final sideswapPegStatusProvider = StreamProvider.autoDispose<SideswapPegStatus>((ref) async* {
  final orderId = await ref.watch(sideswapPegProvider.future).then((value) => value.orderId ?? "");
  final pegIn = ref.watch(pegInProvider);
  final service = ref.watch(sideswapServiceProvider);
  service.pegStatus(orderId: orderId, pegIn: pegIn);
  yield* service.pegStatusStream.map((event) => SideswapPegStatus.fromJson(event));
});


final sideswapHiveStorageProvider = FutureProvider.autoDispose.family<void, String>((ref, orderId) async {
  final sideswapStatusProvider = await ref.watch(sideswapPegStatusProvider.future).then((value) => value);
  ref.read(sideswapAllPegsProvider.notifier).addOrUpdateSwap(sideswapStatusProvider);
});

final sideswapAllPegsProvider = StateNotifierProvider<SideswapPegNotifier, List<SideswapPegStatus>>((ref) {
  return SideswapPegNotifier();
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

final sendBitcoinProvider = StateProvider<bool>((ref) => false);
final assetToSellProvider = StateProvider<String>((ref) => '02f22f8d9c76ab41661a2729e4752e2c5d1a263012141b86ea98af5472df5189');
final assetToPurchaseProvider = StateProvider<String>((ref) => '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d');

final sideswapMarketsFutureProvider = FutureProvider.autoDispose<List<Market>>((ref) async {
  final service = ref.watch(sideswapServiceProvider);
  service.listMarkets();

  final event = await service.listMarketsStream.first;

  final result = event['result']?['list_markets']?['markets'] as List<dynamic>?;
  if (result != null) {
    return result.map((market) => Market.fromJson(market)).toList();
  }
  return [];
});


final sideswapGetQuotePsetProvider = FutureProvider.autoDispose<SideswapQuotePset>((ref) async {
  final service = ref.read(sideswapServiceProvider);
  final quoteId = ref.read(sideswapQuoteProvider).quoteId ?? 0;

  if (quoteId == 0) {
    throw Exception('Invalid Quote ID. Please try again or contact support.');
  }

  service.getQuotePset(quoteId: quoteId);

  final event = await service.quotePsetStream.first;

  return SideswapQuotePset.fromJson(event, quoteId);
});

final sideswapUploadAndSignInputsProvider = FutureProvider.autoDispose<SideswapCompletedSwap>((ref) async {
  final service = ref.read(sideswapServiceProvider);
  final quoteRequest = await ref.watch(quoteRequestProvider.future);
  final quoteId = ref.read(sideswapQuoteProvider).quoteId ?? 0;

  if (quoteId == 0) {
    throw Exception('Invalid Quote ID. Cannot sign swap.');
  }

  final quotePset = await ref.watch(sideswapGetQuotePsetProvider.future);

  final signedPset = await ref.read(signLiquidPsetStringProvider(quotePset.pset).future);

  service.signQuotePset(quoteId: quoteId, pset: signedPset);

  final event = await service.signedSwapStream.firstWhere(
        (event) => event['result']?['taker_sign'] != null,
    orElse: () => throw Exception('Signed swap stream closed without a taker_sign event'),
  );

  final completedSwap = SideswapCompletedSwap(
    txid: event['result']['taker_sign']['txid'],
    sendAsset: quoteRequest.assetType == 'Base' ? quoteRequest.baseAsset : quoteRequest.quoteAsset,
    sendAmount: quoteRequest.amount,
    recvAsset: quoteRequest.assetType == 'Base' ? quoteRequest.quoteAsset : quoteRequest.baseAsset,
    recvAmount: quoteRequest.amount, // Adjust if needed
    quoteId: quoteId,
    timestamp: DateTime.now().millisecondsSinceEpoch,
  );

  ref.read(sideswapGetSwapsProvider.notifier).addOrUpdateSwap(completedSwap);

  return completedSwap;
});


final quoteRequestProvider = FutureProvider.autoDispose<QuoteRequest>((ref) async {
  final sendAmount = ref.watch(sendTxProvider).amount;
  final markets = await ref.watch(sideswapMarketsFutureProvider.future);
  final assetToPurchase = ref.read(assetToPurchaseProvider);
  final assetToSell = ref.read(assetToSellProvider);
  final receiveAddress = await ref.read(liquidAddressProvider.future).then((value) => value);
  final returnAddress = await ref.read(liquidNextAddressProvider.future).then((value) => value);
  final liquidUnspentUtxos = await ref.refresh(liquidUnspentUtxosProvider.future).then((value) => value);

  if (markets.isEmpty) {
    return QuoteRequest.empty();
  }

  Market? selectedMarket;

  // Select a market by matching asset IDs, without swapping based on tradeDir
  try {
    selectedMarket = markets.firstWhere(
          (market) => market.baseAsset == assetToSell && market.quoteAsset == assetToPurchase,
    );
  } catch (e) {
    try {
      selectedMarket = markets.firstWhere(
            (market) => market.baseAsset == assetToPurchase && market.quoteAsset == assetToSell,
      );
    } catch (e) {
      return QuoteRequest.empty();
    }
  }

  final baseAsset = selectedMarket.baseAsset;
  final quoteAsset = selectedMarket.quoteAsset;

  // Filter and format UTXOs for the send asset (baseAsset for Sell, quoteAsset for Buy)
  final assetUtxos = liquidUnspentUtxos.where((utxo) => utxo.unblinded.asset == assetToSell).toList();

  // Select UTXOs to cover the amount
  List<Utxo> formattedUtxos = [];
  int total = 0;

  for (var utxo in assetUtxos) {
    if (total >= sendAmount) {
      break;
    }
    total += utxo.unblinded.value.toInt();
    formattedUtxos.add(Utxo(
      txid: utxo.outpoint.txid,
      vout: utxo.outpoint.vout,
      asset: utxo.unblinded.asset,
      value: utxo.unblinded.value.toInt(),
      assetBf: utxo.unblinded.assetBf,
      valueBf: utxo.unblinded.valueBf,
    ));
  }

  return QuoteRequest(
    baseAsset: baseAsset,
    quoteAsset: quoteAsset,
    assetType: assetToSell == baseAsset ? 'Base' : 'Quote',
    tradeDir: 'Sell',
    amount: sendAmount,
    receiveAddress: receiveAddress.confidential,
    changeAddress: returnAddress,
    utxos: formattedUtxos,
  );
});

final sideswapQuoteStreamProvider = StreamProvider.autoDispose<SideswapQuote>((ref) async* {
  final service = ref.watch(sideswapServiceProvider);
  final request = await ref.watch(quoteRequestProvider.future);

  if (request.amount == 0) {
    throw Exception('Amount cannot be zero');
  }

  service.startQuotes(
    baseAsset: request.baseAsset,
    quoteAsset: request.quoteAsset,
    assetType: request.assetType,
    tradeDir: request.tradeDir,
    amount: request.amount,
    utxos: request.utxos,
    receiveAddress: request.receiveAddress,
    changeAddress: request.changeAddress,
  );
  yield* service.quoteStream.map((event) => SideswapQuote.fromJson(event));
});

final sideswapQuoteProvider = StateNotifierProvider.autoDispose<SideswapQuoteModel, SideswapQuote>((ref) {
  return SideswapQuoteModel(ref);
});


final sideswapGetSwapsProvider = StateNotifierProvider<SideswapSwapsNotifier, List<SideswapCompletedSwap>>((ref) {
  return SideswapSwapsNotifier();
});

final isPayjoin = StateProvider.autoDispose<bool>((ref) => false);
