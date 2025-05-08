import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:Satsails/models/sideshift_model.dart';
import 'package:Satsails/providers/liquid_provider.dart';

enum ShiftPair {
  usdtTronToLiquidUsdt,
  usdtBscToLiquidUsdt,
  usdtEthToLiquidUsdt,
  usdtSolToLiquidUsdt,
  usdtPolygonToLiquidUsdt,
  usdcEthToLiquidUsdt,
  usdcTronToLiquidUsdt,
  usdcBscToLiquidUsdt,
  usdcSolToLiquidUsdt,
  usdcPolygonToLiquidUsdt,
  ethToLiquidBtc,
  trxToLiquidBtc,
  bnbToLiquidBtc,
  solToLiquidBtc,
}

final shiftParamsMap = {
  ShiftPair.usdtTronToLiquidUsdt: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDT',
    depositNetwork: 'tron',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdtBscToLiquidUsdt: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDT',
    depositNetwork: 'bsc',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdtSolToLiquidUsdt: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDT',
    depositNetwork: 'solana',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdtPolygonToLiquidUsdt: ShiftParams(
    depositCoin: 'USDT',
    settleCoin: 'USDT',
    depositNetwork: 'polygon',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdcTronToLiquidUsdt: ShiftParams(
    depositCoin: 'USDC',
    settleCoin: 'USDT',
    depositNetwork: 'tron',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdcBscToLiquidUsdt: ShiftParams(
    depositCoin: 'USDC',
    settleCoin: 'USDT',
    depositNetwork: 'bsc',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdcSolToLiquidUsdt: ShiftParams(
    depositCoin: 'USDC',
    settleCoin: 'USDT',
    depositNetwork: 'solana',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdcPolygonToLiquidUsdt: ShiftParams(
    depositCoin: 'USDC',
    settleCoin: 'USDT',
    depositNetwork: 'polygon',
    settleNetwork: 'liquid',
  ),
  ShiftPair.usdcEthToLiquidUsdt: ShiftParams(
    depositCoin: 'USDC',
    settleCoin: 'USDT',
    depositNetwork: 'ethereum',
    settleNetwork: 'liquid',
  ),
  ShiftPair.ethToLiquidBtc: ShiftParams(
    depositCoin: 'ETH',
    settleCoin: 'BTC',
    depositNetwork: 'ethereum',
    settleNetwork: 'liquid',
  ),
  ShiftPair.trxToLiquidBtc: ShiftParams(
    depositCoin: 'TRX',
    settleCoin: 'BTC',
    depositNetwork: 'tron',
    settleNetwork: 'liquid',
  ),
  ShiftPair.bnbToLiquidBtc: ShiftParams(
    depositCoin: 'BNB',
    settleCoin: 'BTC',
    depositNetwork: 'bsc',
    settleNetwork: 'liquid',
  ),
  ShiftPair.solToLiquidBtc: ShiftParams(
    depositCoin: 'SOL',
    settleCoin: 'BTC',
    depositNetwork: 'solana',
    settleNetwork: 'liquid',
  ),
};

class ShiftParams {
  final String depositCoin;
  final String settleCoin;
  final String depositNetwork;
  final String settleNetwork;
  final String? refundAddress;

  ShiftParams({
    required this.depositCoin,
    required this.settleCoin,
    required this.depositNetwork,
    required this.settleNetwork,
    this.refundAddress,
  });
}

class SideShiftShiftsNotifier extends StateNotifier<List<SideShift>> {
  SideShiftShiftsNotifier() : super([]) {
    _loadShifts();
  }

  SideShift getShiftById(String id) {
    return state.firstWhere((shift) => shift.id == id, orElse: () => throw 'Shift not found');
  }

  Future<void> _loadShifts() async {
    final box = await Hive.openBox<SideShift>('sideShiftShifts');
    box.watch().listen((event) => _updateShifts());
    _updateShifts();
  }

  void _updateShifts() {
    final box = Hive.box<SideShift>('sideShiftShifts');
    final shifts = box.values.toList();
    shifts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = shifts;
  }

  Future<void> addShift(SideShift shift) async {
    final box = Hive.box<SideShift>('sideShiftShifts');
    await box.put(shift.id, shift);
    _updateShifts();
  }

  Future<void> updateShift(SideShift updatedShift) async {
    final box = Hive.box<SideShift>('sideShiftShifts');
    await box.put(updatedShift.id, updatedShift);
    _updateShifts();
  }

  Future<void> deleteShift(String id) async {
    final box = Hive.box<SideShift>('sideShiftShifts');
    await box.delete(id);
    _updateShifts();
  }
}

final sideShiftShiftsProvider = StateNotifierProvider<SideShiftShiftsNotifier, List<SideShift>>((ref) {
  return SideShiftShiftsNotifier();
});

final createSideShiftShiftProvider = FutureProvider.family.autoDispose<SideShift, ShiftParams>((ref, params) async {
  final settleAddress = await ref.watch(liquidAddressProvider.future);

  final request = SideShiftShiftRequest(
    settleAddress: settleAddress.confidential,
    refundAddress: params.refundAddress,
    depositCoin: params.depositCoin,
    settleCoin: params.settleCoin,
    depositNetwork: params.depositNetwork,
    settleNetwork: params.settleNetwork,
    affiliateId: 'QsbsXsGKU',
  );

  final result = await SideShiftService.createShift(request);

  if (result.data != null) {
    ref.read(sideShiftShiftsProvider.notifier).addShift(result.data!);
    return result.data!;
  } else {
    throw result.error ?? 'Unknown error';
  }
});

final createSideShiftShiftForPairProvider = FutureProvider.family.autoDispose<SideShift, ShiftPair>((ref, pair) async {
  final params = shiftParamsMap[pair];
  if (params == null) {
    throw 'Invalid shift pair';
  }
  return await ref.read(createSideShiftShiftProvider(params).future);
});

final allSideShiftShiftsProvider = Provider<List<SideShift>>((ref) {
  return ref.watch(sideShiftShiftsProvider);
});

final sideshiftAssetPairProvider = Provider.family<SideshiftAssetPair, ShiftPair>((ref, shiftPair) {
  final params = shiftParamsMap[shiftPair]!;
  final fromAsset = SideshiftAsset(
    id: '${params.depositCoin.toLowerCase()}-${params.depositNetwork.toLowerCase()}',
    coin: params.depositCoin,
    network: params.depositNetwork,
    name: params.depositCoin,
  );
  final toAsset = SideshiftAsset(
    id: '${params.settleCoin.toLowerCase()}-${params.settleNetwork.toLowerCase()}',
    coin: params.settleCoin,
    network: params.settleNetwork,
    name: params.settleCoin,
  );
  return SideshiftAssetPair(from: fromAsset, to: toAsset);
});

final selectedShiftPairProvider = StateProvider<ShiftPair?>((ref) => null);

final updateSideShiftShiftsProvider = FutureProvider.family.autoDispose<void, List<String>>((ref, shiftIds) async {
  final result = await SideShiftService.getShiftsByIds(shiftIds);

  if (result.data != null) {
    final shifts = result.data!;
    final box = Hive.box<SideShift>('sideShiftShifts');

    for (var shift in shifts) {
      await box.put(shift.id, shift);
    }

    ref.read(sideShiftShiftsProvider.notifier)._updateShifts();
  } else {
    throw result.error ?? 'Unknown error';
  }
});

final setRefundAddressProvider = FutureProvider.family.autoDispose<void, RefundAddressParams>((ref, params) async {
  await SideShiftService.setRefundAddress(params.shiftId, params.refundAddress);


  // Update the shift in the Hive box after setting the refund address
  final shiftIds = [params.shiftId];
  await ref.read(updateSideShiftShiftsProvider(shiftIds).future);
});

class RefundAddressParams {
  final String shiftId;
  final String refundAddress;

  RefundAddressParams({required this.shiftId, required this.refundAddress});
}