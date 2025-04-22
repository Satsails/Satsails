import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:lwk/lwk.dart';

part 'sideswap_exchange_model.g.dart';

class SideswapQuotePset {
  final String pset;
  final int ttl;
  final int quoteId;

  SideswapQuotePset({
    required this.pset,
    required this.ttl,
    required this.quoteId,
  });

  factory SideswapQuotePset.fromJson(Map<String, dynamic> json, int quoteId) {
    final result = json['result']['get_quote'];
    return SideswapQuotePset(
      pset: result['pset'],
      ttl: result['ttl'],
      quoteId: quoteId,
    );
  }
}

@HiveType(typeId: 11)
class SideswapCompletedSwap {
  @HiveField(0)
  final String txid;
  @HiveField(1)
  final String sendAsset;
  @HiveField(2)
  final num sendAmount;
  @HiveField(3)
  final String recvAsset;
  @HiveField(4)
  final num recvAmount;
  @HiveField(5)
  final int quoteId;
  @HiveField(6)
  final int timestamp;

  SideswapCompletedSwap({
    required this.txid,
    required this.sendAsset,
    required this.sendAmount,
    required this.recvAsset,
    required this.recvAmount,
    required this.quoteId,
    required this.timestamp,
  });
}

class SideswapSwapsNotifier extends StateNotifier<List<SideswapCompletedSwap>> {
  SideswapSwapsNotifier() : super([]) {
    _loadSwaps();
  }

  Future<void> _loadSwaps() async {
    final box = await Hive.openBox<SideswapCompletedSwap>('sideswapSwapNewData');
    box.watch().listen((event) => _updateSwaps());
    _updateSwaps();
  }

  void _updateSwaps() {
    final box = Hive.box<SideswapCompletedSwap>('sideswapSwapNewData');
    final swaps = box.values.toList();
    state = swaps;
  }

  Future<void> addOrUpdateSwap(SideswapCompletedSwap newSwap) async {
    final box = Hive.box<SideswapCompletedSwap>('sideswapSwapNewData');
    final existingSwap = box.get(newSwap.txid);

    if (existingSwap == null) {
      await box.put(newSwap.txid, newSwap);
    }
    _updateSwaps();
  }
}

class QuoteExecutionRequest {
  final int quoteId;
  final String sendAsset;
  final num sendAmount;
  final String recvAsset;
  final num recvAmount;

  QuoteExecutionRequest({
    required this.quoteId,
    required this.sendAsset,
    required this.sendAmount,
    required this.recvAsset,
    required this.recvAmount,
  });
}



// Future