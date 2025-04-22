import 'dart:async';
import 'dart:ui';

import 'package:Satsails/models/sideswap/sideswap_markets_model.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/sideswap/sideswap_exchange_model.dart';
import 'package:Satsails/models/sideswap/sideswap_peg_model.dart';
import 'package:Satsails/models/sideswap/sideswap_quote_model.dart';
import 'package:Satsails/models/sideswap/sideswap_status_model.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
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

final sideswapMarketsStreamProvider = StreamProvider.autoDispose<List<Market>>((ref) {
  final service = ref.watch(sideswapServiceProvider);
  service.listMarkets();
  return service.listMarketsStream.map((event) {
    final result = event['result']?['list_markets']?['markets'] as List<dynamic>?;
    if (result == null) {
      return [];
    }
    return result.map((market) => Market.fromJson(market)).toList();
  });
});

final sideswapMarketsFutureProvider = FutureProvider.autoDispose<List<Market>>((ref) async {
  final service = ref.watch(sideswapServiceProvider);
  service.listMarkets();
  final stream = service.listMarketsStream;
  final completer = Completer<List<Market>>();

  final subscription = stream.listen(
        (event) {
      final result = event['result']?['list_markets']?['markets'] as List<dynamic>?;
      if (result != null && !completer.isCompleted) {
        final markets = result.map((market) => Market.fromJson(market)).toList();
        completer.complete(markets);
      }
    },
    onError: (error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    },
    onDone: () {
      if (!completer.isCompleted) {
        completer.complete([]);
      }
    },
  );

  ref.onDispose(() {
    subscription.cancel();
  });

  return completer.future;
});


final quoteRequestProvider = FutureProvider.autoDispose<QuoteRequest>((ref) async {
  final markets = await ref.watch(sideswapMarketsFutureProvider.future);
  final assetToPurchase = ref.read(assetToPurchaseProvider);
  final assetToSell = ref.read(assetToSellProvider);
  final receiveAddress = await ref.read(liquidAddressProvider.future).then((value) => value);
  final returnAddress = await ref.read(liquidNextAddressProvider.future).then((value) => value);
  final liquidUnspentUtxos = await ref.refresh(liquidUnspentUtxosProvider.future).then((value) => value);
  final sendAmount = ref.watch(sendTxProvider).amount;

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
      redeemScript: utxo.scriptPubkey,
    ));
  }

  return QuoteRequest(
    baseAsset: baseAsset,
    quoteAsset: quoteAsset,
    assetType: assetToSell == baseAsset ? 'Base' : 'Quote',
    tradeDir: assetToSell == baseAsset ? 'Buy' : 'Sell',
    amount: sendAmount,
    receiveAddress: receiveAddress.confidential,
    changeAddress: returnAddress,
    utxos: formattedUtxos,
  );
});

final sideswapQuoteStreamProvider = StreamProvider.autoDispose<SideswapQuote>((ref) async* {
  final service = ref.watch(sideswapServiceProvider);
  final request = await ref.watch(quoteRequestProvider.future);

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

final sideswapQuoteProvider = StateNotifierProvider<SideswapQuoteModel, SideswapQuote>((ref) {
  return SideswapQuoteModel(ref);
});


final sideswapGetQuotePsetProvider = StreamProvider.autoDispose.family<SideswapQuotePset, int>((ref, quoteId) {
  final service = ref.watch(sideswapServiceProvider);
  service.getQuotePset(quoteId: quoteId);
  return service.quotePsetStream.map((event) => SideswapQuotePset.fromJson(event, quoteId));
});

final sideswapUploadAndSignInputsProvider = FutureProvider.autoDispose.family<SideswapCompletedSwap, QuoteExecutionRequest>((ref, request) async {
  final service = ref.watch(sideswapServiceProvider);
  final quotePset = await ref.watch(sideswapGetQuotePsetProvider(request.quoteId).future);
  final signedPset = await ref.watch(signLiquidPsetStringProvider(quotePset.pset).future);

  // Call signQuotePset, which triggers a WebSocket message
  service.signQuotePset(quoteId: request.quoteId, pset: signedPset);

  // Listen to the signedSwapStream for the response
  final transaction = await service.signedSwapStream.firstWhere((event) {
    return event['result']?['taker_sign'] != null;
  });

  final completedSwap = SideswapCompletedSwap(
    txid: transaction['result']['taker_sign']['txid'],
    sendAsset: request.sendAsset,
    sendAmount: request.sendAmount,
    recvAsset: request.recvAsset,
    recvAmount: request.recvAmount,
    quoteId: request.quoteId,
    timestamp: DateTime.now().millisecondsSinceEpoch,
  );
  ref.read(sideswapGetSwapsProvider.notifier).addOrUpdateSwap(completedSwap);
  return completedSwap;
});

final sideswapGetSwapsProvider = StateNotifierProvider.autoDispose<SideswapSwapsNotifier, List<SideswapCompletedSwap>>((ref) {
  return SideswapSwapsNotifier();
});

// final sideswapUploadAndSignInputsProvider = FutureProvider.autoDispose<SideswapCompletedSwap>((ref) async {
//   final state = await ref.read(sideswapStartExchangeProvider.future).then((value) => value);
//   final receiveAddress = await ref.read(liquidAddressProvider.future).then((value) => value);
//   final returnAddress = await ref.read(liquidNextAddressProvider.future).then((value) => value);
//   final liquidUnspentUtxos = await ref.refresh(liquidUnspentUtxosProvider.future).then((value) => value);
//   final sendAmount = ref.read(sideswapPriceProvider).sendAmount!;
//   final inputsUpload =  await state.uploadInputs(returnAddress, liquidUnspentUtxos, receiveAddress.confidential, sendAmount).then((value) => value);
//   final signedPset = await ref.read(signLiquidPsetStringProvider(inputsUpload.pset).future).then((value) => value);
//   final transaction = await state.uploadPset(signedPset, inputsUpload.submitId).then((value) => value);
//   ref.read(sideswapGetSwapsProvider.notifier).addOrUpdateSwap(transaction);
//   return transaction;
// });
