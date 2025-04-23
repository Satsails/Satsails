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


final sideswapGetQuotePsetProvider = FutureProvider.autoDispose<SideswapQuotePset>((ref) async {
  final completer = Completer<SideswapQuotePset>();
  final service = ref.read(sideswapServiceProvider);
  final quoteId = ref.read(sideswapQuoteProvider).quoteId ?? 0; // Fallback to 0 if null

  // Listen to the quotePsetStream
  StreamSubscription? subscription;
  subscription = service.quotePsetStream.listen(
        (event) {
      try {
        // Parse the event to SideswapQuotePset
        final quotePset = SideswapQuotePset.fromJson(event, quoteId);
        // Complete the Future with the parsed result
        completer.complete(quotePset);
        // Cancel the subscription to avoid memory leaks
        subscription?.cancel();
      } catch (e, stackTrace) {
        // Complete with error if parsing fails
        completer.completeError(e, stackTrace);
        subscription?.cancel();
      }
    },
    onError: (error, stackTrace) {
      // Complete with error if the stream emits an error
      completer.completeError(error, stackTrace);
      subscription?.cancel();
    },
    onDone: () {
      // If the stream closes without emitting a value, complete with an error
      if (!completer.isCompleted) {
        completer.completeError(Exception('quotePsetStream closed without emitting a quote PSET'));
      }
      subscription?.cancel();
    },
  );

  // Trigger the request
  service.getQuotePset(quoteId: quoteId);

  // Return the Future
  return completer.future;
});

// FutureProvider for uploading and signing inputs
final sideswapUploadAndSignInputsProvider = FutureProvider.autoDispose<SideswapCompletedSwap>((ref) async {
  final completer = Completer<SideswapCompletedSwap>();
  final service = ref.read(sideswapServiceProvider);
  final quoteRequest = await ref.watch(quoteRequestProvider.future);

  // Construct QuoteExecutionRequest from QuoteRequest
  final request = QuoteExecutionRequest(
    quoteId: ref.read(sideswapQuoteProvider).quoteId ?? 0, // Fallback to 0 if null
    sendAsset: quoteRequest.assetType == 'Base' ? quoteRequest.baseAsset : quoteRequest.quoteAsset,
    sendAmount: quoteRequest.amount,
    recvAsset: quoteRequest.assetType == 'Base' ? quoteRequest.quoteAsset : quoteRequest.baseAsset,
    recvAmount: quoteRequest.amount, // Assume 1:1 for simplicity; adjust if needed
  );

  try {
    // Await the quote PSET from sideswapGetQuotePsetProvider
    final quotePset = await ref.watch(sideswapGetQuotePsetProvider.future);

    // Sign the PSET
    final signedPset = await ref.read(signLiquidPsetStringProvider(quotePset.pset).future);

    // Listen to the signedSwapStream
    StreamSubscription? subscription;
    subscription = service.signedSwapStream.listen(
          (event) {
        try {
          // Check for taker_sign event
          if (event['result']?['taker_sign'] != null) {
            // Construct the completed swap
            final completedSwap = SideswapCompletedSwap(
              txid: event['result']['taker_sign']['txid'],
              sendAsset: request.sendAsset,
              sendAmount: request.sendAmount,
              recvAsset: request.recvAsset,
              recvAmount: request.recvAmount,
              quoteId: request.quoteId,
              timestamp: DateTime.now().millisecondsSinceEpoch,
            );
            // Update the swaps provider
            ref.read(sideswapGetSwapsProvider.notifier).addOrUpdateSwap(completedSwap);
            // Complete the Future
            completer.complete(completedSwap);
            // Cancel the subscription
            subscription?.cancel();
          }
        } catch (e, stackTrace) {
          // Complete with error if processing fails
          completer.completeError(e, stackTrace);
          subscription?.cancel();
        }
      },
      onError: (error, stackTrace) {
        // Complete with error if the stream emits an error
        completer.completeError(error, stackTrace);
        subscription?.cancel();
      },
      onDone: () {
        // If the stream closes without a taker_sign event, complete with an error
        if (!completer.isCompleted) {
          completer.completeError(Exception('signedSwapStream closed without a taker_sign event'));
        }
        subscription?.cancel();
      },
    );

    // Trigger the signQuotePset request
    service.signQuotePset(quoteId: request.quoteId, pset: signedPset);
  } catch (e, stackTrace) {
    // Complete with error if any step fails
    completer.completeError(e, stackTrace);
  }

  // Return the Future
  return completer.future;
});

final sideswapGetSwapsProvider = StateNotifierProvider.autoDispose<SideswapSwapsNotifier, List<SideswapCompletedSwap>>((ref) {
  return SideswapSwapsNotifier();
});

final chosenAssetForPayjoin = StateProvider<String>((ref) => '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d');