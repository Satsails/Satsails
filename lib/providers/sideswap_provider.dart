import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:satsails/models/sideswap_peg_model.dart';
import 'package:satsails/models/sideswap_status_model.dart';
import 'package:satsails/providers/bitcoin_provider.dart';
import 'package:satsails/providers/liquid_provider.dart';
import 'package:satsails/services/sideswap/sideswap.dart';

final sideswapServiceProvider = Provider.autoDispose<Sideswap>((ref) {
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
  return swaps;
});

