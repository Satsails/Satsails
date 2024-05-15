import 'package:Satsails/models/boltz/boltz_model.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:boltz_dart/boltz_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final boltzFeesProvider = FutureProvider.autoDispose<AllFees>((ref) async {
  return await AllFees.fetch(boltzUrl: 'https://api.boltz.exchange');
});

final boltzReceiveProvider = FutureProvider.autoDispose<Boltz>((ref) async {
  final fees = await ref.read(boltzFeesProvider.future);
  final authModel = ref.read(authModelProvider);
  final mnemonic = await authModel.getMnemonic();
  final address = await ref.read(liquidAddressProvider.future);
  final amount = await ref.watch(lnAmountProvider.future);
  final recieve = await Boltz.createBoltzReceive(fees: fees, mnemonic: mnemonic!, index:address.index, address: address.confidential, amount: amount);
  final box = await Hive.openBox('receiveBoltz');
  await box.put(recieve.swap.id, recieve);
  return recieve;
});

final claimBoltzTransactionProvider = FutureProvider.autoDispose<bool>((ref) async {
  final receiveAddress = await ref.read(liquidAddressProvider.future);
  final fees = await ref.read(boltzFeesProvider.future);
  final boltzReceive = await ref.watch(boltzReceiveProvider.future);
  final received = await boltzReceive.claimBoltzTransaction(receiveAddress: receiveAddress.confidential, fees: fees);
  if (received) {
    final box = await Hive.openBox('receiveBoltz');
    await box.delete(boltzReceive.swap.id);
  }
  return received;
});

final claimSingleBoltzTransactionProvider = FutureProvider.autoDispose.family<bool, String>((ref, id) async {
  final receiveAddress = await ref.read(liquidAddressProvider.future);
  final fees = await ref.read(boltzFeesProvider.future);
  final box = await Hive.openBox('receiveBoltz');
  final boltzReceive = box.get(id) as Boltz;
  final received = await boltzReceive.claimBoltzTransaction(receiveAddress: receiveAddress.confidential, fees: fees);
  if (received) {
    await box.delete(boltzReceive.swap.id);
  } else {
    throw Exception('Could not claim transaction');
  }
  return received;
});

final deleteSingleBoltzTransactionProvider = FutureProvider.autoDispose.family<void, String>((ref, id) async {
  final recievebox = await Hive.openBox('receiveBoltz');
  final paybox = await Hive.openBox('payBoltz');
  await recievebox.delete(id);
  await paybox.delete(id);
});

final claimBoltzTransactionStreamProvider = StreamProvider.autoDispose<bool>((ref) async* {
  while (true) {
    try {
      final result = await ref.read(claimBoltzTransactionProvider.future);
      yield result;
      if (result) {
        break;
      }
    } catch (e) {
      yield false;
    } finally {
      await Future.delayed(const Duration(seconds: 2));
    }
  }
});

final boltzPayProvider = FutureProvider.autoDispose<Boltz>((ref) async {
    final fees = await ref.read(boltzFeesProvider.future);
    var sendTx = ref.watch(sendTxProvider.notifier);
    final address = await ref.read(liquidAddressProvider.future);
    final authModel = ref.read(authModelProvider);
    final mnemonic = await authModel.getMnemonic();
    final pay = await Boltz.createBoltzPay(fees: fees, mnemonic: mnemonic!, invoice: sendTx.state.address, amount: sendTx.state.amount, index: address.index);
    final box = await Hive.openBox('payBoltz');
    await box.put(pay.swap.id, pay);
    sendTx.state = sendTx.state.copyWith(address: pay.swap.scriptAddress, amount: (pay.swap.outAmount).toInt());
    await ref.read(sendLiquidTransactionProvider.future).then((value) => value);
    box.delete(pay.swap.id);
    return pay;
  }
);

final refundSingleBoltzTransactionProvider = FutureProvider.autoDispose.family<bool, String>((ref, id) async {
  final fees = await ref.read(boltzFeesProvider.future);
  final address = await ref.read(liquidAddressProvider.future);
  final box = await Hive.openBox('payBoltz');
  final boltzPay = box.get(id) as Boltz;
  final refunded = await boltzPay.refund(fees: fees, tryCooperate: true, outAddress: address.confidential);
  if (refunded) {
    await box.delete(boltzPay.swap.id);
  } else {
    throw Exception('Could not refund transaction');
  }
  return refunded;
});

final receivedBoltzProvider = FutureProvider.autoDispose<List<Boltz>>((ref) async {
  final box = await Hive.openBox('receiveBoltz');
  return box.values.map((item) => item as Boltz).toList();
});

final payedBoltzProvider = FutureProvider.autoDispose<List<Boltz>>((ref) async {
  final box = await Hive.openBox('payBoltz');
  return box.values.map((item) => item as Boltz).toList();
});