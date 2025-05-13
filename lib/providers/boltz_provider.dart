import 'package:Satsails/providers/address_provider.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/helpers/liquid_block_height.dart';
import 'package:Satsails/models/boltz_model.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:boltz/boltz.dart';

// Single Box Provider for all swaps
final boltzSwapsBoxProvider = Provider<Box>((ref) {
  return Hive.box('boltzSwapsBox');
});

// Boltz Swap Notifier to manage all swaps
class BoltzSwapNotifier extends StateNotifier<List<LbtcBoltz>> {
  BoltzSwapNotifier() : super([]) {
    _loadSwaps();
  }

  LbtcBoltz getSwapById(String id) {
    return state.firstWhere((swap) => swap.swap.id == id, orElse: () => throw 'Swap not found');
  }

  Future<void> _loadSwaps() async {
    final box = await Hive.openBox<LbtcBoltz>('boltzSwapsBox');
    box.watch().listen((event) => _updateSwaps());
    _updateSwaps();
  }

  void _updateSwaps() {
    final box = Hive.box<LbtcBoltz>('boltzSwapsBox');
    final swaps = box.values.toList();
    swaps.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = swaps;
  }

  Future<void> addSwap(LbtcBoltz swap) async {
    final box = Hive.box<LbtcBoltz>('boltzSwapsBox');
    await box.put(swap.swap.id, swap);
    _updateSwaps();
  }

  Future<void> updateSwap(LbtcBoltz updatedSwap) async {
    final box = Hive.box<LbtcBoltz>('boltzSwapsBox');
    await box.put(updatedSwap.swap.id, updatedSwap);
    _updateSwaps();
  }

  Future<void> deleteSwap(String id) async {
    final box = Hive.box<LbtcBoltz>('boltzSwapsBox');
    await box.delete(id);
    _updateSwaps();
  }
}

final boltzSwapProvider = StateNotifierProvider<BoltzSwapNotifier, List<LbtcBoltz>>((ref) {
  return BoltzSwapNotifier();
});

// Original Liquid Boltz Providers adapted
final boltzReverseFeesProvider = FutureProvider.autoDispose<ReverseFeesAndLimits>((ref) async {
  try {
    final fees = await Fees.newInstance(boltzUrl: 'https://api.boltz.exchange/v2');
    return await fees.reverse();
  } catch (e) {
    throw 'Could not fetch fees';
  }
});

final boltzSubmarineFeesProvider = FutureProvider.autoDispose<SubmarineFeesAndLimits>((ref) async {
  try {
    final fees = await Fees.newInstance(boltzUrl: 'https://api.boltz.exchange/v2');
    return await fees.submarine();
  } catch (e) {
    throw 'Could not fetch fees';
  }
});

final boltzReceiveProvider = FutureProvider.autoDispose<LbtcBoltz>((ref) async {
  final fees = await ref.read(boltzReverseFeesProvider.future);
  final authModel = ref.read(authModelProvider);
  final mnemonic = await authModel.getMnemonic();
  final address = ref.read(addressProvider).liquidAddress;
  final addressIndex = ref.read(addressProvider).liquidAddressIndex;
  final amount = ref.watch(sendTxProvider).amount == 0 ? await ref.watch(lnAmountProvider.future) : ref.watch(sendTxProvider).amount;
  final electrumUrl = await ref.read(settingsProvider).liquidElectrumNode;
  final receive = await LbtcBoltz.createBoltzReceive(
    fees: fees,
    mnemonic: mnemonic!,
    index: addressIndex,
    address: address,
    amount: amount,
    electrumUrl: electrumUrl,
  );
  await ref.read(boltzSwapProvider.notifier).addSwap(receive);
  return receive;
});

final claimSingleBoltzTransactionProvider = FutureProvider.autoDispose.family<bool, String>((ref, id) async {
  final receiveAddress = ref.read(addressProvider).liquidAddress;
  final fees = await ref.read(boltzReverseFeesProvider.future);
  final box = ref.read(boltzSwapsBoxProvider);
  final boltzSwap = box.get(id) as LbtcBoltz;
  final electrumUrl = ref.read(settingsProvider).liquidElectrumNode;

  final received = await boltzSwap.claimBoltzTransaction(
    receiveAddress: receiveAddress,
    fees: fees,
    electrumUrl: electrumUrl,
  );

  if (received) {
    final updatedBoltz = boltzSwap.copyWith(completed: true);
    await ref.read(boltzSwapProvider.notifier).updateSwap(updatedBoltz);
  } else {
    throw 'Could not claim transaction';
  }

  return received;
});

final boltzPayProvider = FutureProvider.autoDispose<LbtcBoltz>((ref) async {
  final fees = await ref.read(boltzSubmarineFeesProvider.future);
  var sendTx = ref.watch(sendTxProvider.notifier);
  final addressIndex = ref.read(addressProvider).liquidAddressIndex;
  final authModel = ref.read(authModelProvider);
  final mnemonic = await authModel.getMnemonic();
  final electrumUrl = await ref.read(settingsProvider).liquidElectrumNode;
  final pay = await LbtcBoltz.createBoltzPay(
    fees: fees,
    mnemonic: mnemonic!,
    invoice: sendTx.state.address,
    amount: sendTx.state.amount,
    index: addressIndex,
    electrumUrl: electrumUrl,
  );
  await ref.read(boltzSwapProvider.notifier).addSwap(pay);
  sendTx.state = sendTx.state.copyWith(address: pay.swap.scriptAddress, amount: (pay.swap.outAmount).toInt());
  await ref.read(sendLiquidTransactionProvider.future).then((value) => value);
  final updatedBoltz = pay.copyWith(completed: true);
  await ref.read(boltzSwapProvider.notifier).updateSwap(updatedBoltz);
  return pay;
});

final refundSingleBoltzTransactionProvider = FutureProvider.autoDispose.family<bool, String>((ref, id) async {
  final fees = await ref.read(boltzSubmarineFeesProvider.future);
  final address = ref.read(addressProvider).liquidAddress;
  final box = ref.read(boltzSwapsBoxProvider);
  final boltzSwap = box.get(id) as LbtcBoltz;
  final electrumUrl = await ref.read(settingsProvider).liquidElectrumNode;

  final refunded = await boltzSwap.refund(
    fees: fees,
    tryCooperate: true,
    outAddress: address,
    electrumUrl: electrumUrl,
  );

  if (refunded) {
    final updatedBoltz = boltzSwap.copyWith(completed: true);
    await ref.read(boltzSwapProvider.notifier).updateSwap(updatedBoltz);
  } else {
    throw 'Could not refund transaction';
  }

  return refunded;
});

final receivedBoltzProvider = Provider.autoDispose<List<LbtcBoltz>>((ref) {
  final allSwaps = ref.watch(boltzSwapProvider);
  return allSwaps.where((swap) => swap.swap.kind == SwapType.reverse).toList();
});

final payedBoltzProvider = Provider.autoDispose<List<LbtcBoltz>>((ref) {
  final allSwaps = ref.watch(boltzSwapProvider);
  return allSwaps.where((swap) => swap.swap.kind == SwapType.submarine).toList();
});

final claimAndDeleteAllBoltzProvider = FutureProvider.autoDispose<void>((ref) async {
  try {
    final allSwaps = ref.read(boltzSwapProvider);
    final receiveSwaps = allSwaps.where((swap) => swap.swap.kind == SwapType.reverse).toList();
    final currentLiquidTip = await getCurrentBlockHeight();

    for (var item in receiveSwaps) {
      try {
        if (item.swapScript.locktime < currentLiquidTip || (item.completed ?? false)) {
          continue;
        } else {
          await ref.read(claimSingleBoltzTransactionProvider(item.swap.id).future).then((value) => value);
        }
      } catch (_) {
        // Ignore any errors for this item and continue to the next
      }
    }
  } catch (_) {
    // Ignore any errors
  }
});

final allTransactionsProvider = Provider.autoDispose<List<dynamic>>((ref) {
  final allSwaps = ref.watch(boltzSwapProvider);
  return allSwaps.map((swap) {
    bool isSending = swap.swap.kind == SwapType.submarine;
    return {'tx': swap, 'isBitcoin': false, 'isSending': isSending};
  }).toList();
});