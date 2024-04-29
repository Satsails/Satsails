import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:satsails/models/sideswap_peg_model.dart';
import 'package:satsails/models/sideswap_status_model.dart';
import 'package:satsails/providers/bitcoin_provider.dart';
import 'package:satsails/providers/liquid_provider.dart';
import 'package:satsails/services/sideswap/sideswap_peg.dart';
import 'package:satsails/services/sideswap/sideswap_status.dart';

final sideswapServerStatusStream = StreamProvider.autoDispose<SideswapStatus>((ref) {
  final service = SideswapServerStatus();
  service.connect();
  final stream = service.messageStream;

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

final sideswapPegStreamProvider = StreamProvider.autoDispose<SideswapPeg>((ref) async* {
  final pegIn = ref.watch(pegInProvider);
  final blocks = ref.watch(pegOutBlocksProvider);
  final service = SideswapPegStream();
  final liquidAddress = ref.watch(liquidAddressProvider.future).then((value) => value);
  final bitcoinAddress = ref.watch(bitcoinAddressProvider.future).then((value) => value);

  pegIn ? service.connect(recv_addr: await liquidAddress, peg_in: pegIn) : service.connect(recv_addr: await bitcoinAddress, peg_in: pegIn, blocks: blocks);
  yield* service.messageStream.map((event) => SideswapPeg.fromJson(event));
});


final sideswapPegStatusStreamProvider = StreamProvider.autoDispose<SideswapPegStatus>((ref) async* {
  final orderId = await ref.watch(sideswapPegStreamProvider.future).then((value) => value.orderId ?? "");
  final pegIn = ref.watch(pegInProvider);
  final service = SideswapPegStatusStream();
  service.connect(orderId: orderId, pegIn: pegIn);
  final stream = service.messageStream;

  yield* stream.map((event) => SideswapPegStatus.fromJson(event));
});


final sideswapHiveStorageProvider = FutureProvider.autoDispose.family<void, String>((ref, orderId) async {
  final sideswapStatusProvider = ref.watch(sideswapPegStatusStreamProvider);
  final box = await Hive.openBox('sideswapStatus');
  box.put(orderId, sideswapStatusProvider);
});

