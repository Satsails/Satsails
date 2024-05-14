import 'package:Satsails/models/boltz/boltz_model.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:boltz_dart/boltz_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final boltzFeesProvider = FutureProvider.autoDispose<AllFees>((ref) async {
  return await AllFees.fetch(boltzUrl: 'https://api.boltz.exchange');
});

final boltzReceiveProvider = FutureProvider.autoDispose<Boltz>((ref) async {
  final fees = await ref.read(boltzFeesProvider.future);
  final authModel = ref.read(authModelProvider);
  final mnemonic = await authModel.getMnemonic();
  final address = await ref.read(liquidAddressProvider.future);
  final amount = await ref.watch(lnAmountProvider.future);
  return await Boltz.createBoltzReceive(fees: fees, mnemonic: mnemonic!, index:address.index, address: address.confidential, amount: amount);
});

final claimBoltzTransactionProvider = FutureProvider.autoDispose<bool>((ref) async {
  final receiveAddress = await ref.read(liquidAddressProvider.future);
  final fees = await ref.read(boltzFeesProvider.future);
  final boltzReceive = await ref.watch(boltzReceiveProvider.future);
  return await boltzReceive.claimBoltzTransaction(receiveAddress: receiveAddress.confidential, fees: fees);
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
      await Future.delayed(Duration(seconds: 2));
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
  sendTx.state = sendTx.state.copyWith(address: pay.swap.scriptAddress, amount: (pay.swap.outAmount).toInt());
  await ref.read(sendLiquidTransactionProvider.future).then((value) => value);
  return pay;
});