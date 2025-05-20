import 'package:Satsails/providers/address_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/sideshift_model.dart';

final selectedSendShiftPairProvider = StateProvider<ShiftPair>((ref) => ShiftPair.liquidUsdtToUsdtTron);

final sideShiftShiftsProvider = StateNotifierProvider<SideShiftShiftsNotifier, List<SideShift>>((ref) {
  return SideShiftShiftsNotifier();
});

// For receiving on Liquid
final createReceiveSideShiftShiftProvider = FutureProvider.family.autoDispose<SideShift, ShiftPair>((ref, pair) async {
  final params = shiftParamsMap[pair]!;
  final liquidAddress = ref.read(addressProvider).liquidAddress;

  final request = SideShiftShiftRequest(
    settleAddress: liquidAddress,
    depositCoin: params.depositCoin,
    settleCoin: params.settleCoin,
    depositNetwork: params.depositNetwork,
    settleNetwork: params.settleNetwork,
    affiliateId: dotenv.env['SIDESHIFTAFFILIATE']!,
  );

  final result = await SideShiftService.createShift(request);

  if (result.data != null) {
    ref.read(sideShiftShiftsProvider.notifier).addShift(result.data!);
    return result.data!;
  } else {
    throw result.error ?? 'Unknown error';
  }
});

// For sending from Liquid
final createSendSideShiftShiftProvider = FutureProvider.family.autoDispose<SideShift, (ShiftPair, String)>((ref, args) async {
  final (pair, settleAddress) = args;
  final params = shiftParamsMap[pair]!;
  final liquidAddress = ref.watch(addressProvider).liquidAddress;

  final request = SideShiftShiftRequest(
    settleAddress: settleAddress,
    refundAddress: liquidAddress,
    depositCoin: params.depositCoin,
    settleCoin: params.settleCoin,
    depositNetwork: params.depositNetwork,
    settleNetwork: params.settleNetwork,
    affiliateId: dotenv.env['SIDESHIFTAFFILIATE']!,
  );

  final result = await SideShiftService.createShift(request);

  if (result.data != null) {
    ref.read(sideShiftShiftsProvider.notifier).addShift(result.data!);
    return result.data!;
  } else {
    throw result.error ?? 'Unknown error';
  }
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
    await ref.read(sideShiftShiftsProvider.notifier).mergeShifts(shifts);
  } else {
    throw result.error ?? 'Unknown error';
  }
});

final deleteSideShiftProvider = FutureProvider.family.autoDispose<void, String>((ref, id) async {
  await ref.read(sideShiftShiftsProvider.notifier).deleteShift(id);
});

final setRefundAddressProvider = FutureProvider.family.autoDispose<void, RefundAddressParams>((ref, params) async {
  final result = await SideShiftService.setRefundAddress(params.shiftId, params.refundAddress);
  if (result.isSuccess) {
    await ref.read(updateSideShiftShiftsProvider([params.shiftId]).future);
  } else {
    throw result.error!;
  }
});

final shiftByIdProvider = Provider.family<SideShift, String>((ref, id) {
  final shifts = ref.watch(sideShiftShiftsProvider);
  return shifts.firstWhere((shift) => shift.id == id);
});
