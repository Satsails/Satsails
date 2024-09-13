import 'package:Satsails/helpers/liquid_block_height.dart';
import 'package:Satsails/models/auth_model.dart';
import 'package:Satsails/models/boltz/boltz_model.dart';
import 'package:Satsails/providers/address_receive_provider.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/bitcoin_provider.dart';
import 'package:Satsails/providers/liquid_provider.dart';
import 'package:Satsails/providers/send_tx_provider.dart';
import 'package:boltz_dart/boltz_dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Original Liquid Boltz Providers

final boltzReverseFeesProvider = FutureProvider.autoDispose<ReverseFeesAndLimits>((ref) async {
  try {
    final fees = await Fees.newInstance(boltzUrl: 'https://api.boltz.exchange');
    return await fees.reverse();
  } catch (e) {
    throw 'Could not fetch fees';
  }
});

final boltzSubmarineFeesProvider = FutureProvider.autoDispose<SubmarineFeesAndLimits>((ref) async {
  try {
    final fees = await Fees.newInstance(boltzUrl: 'https://api.boltz.exchange');
    return await fees.submarine();
  } catch (e) {
    throw 'Could not fetch fees';
  }
});

final boltzReceiveProvider = FutureProvider.autoDispose<LbtcBoltz>((ref) async {
  final fees = await ref.read(boltzReverseFeesProvider.future);
  final authModel = ref.read(authModelProvider);
  final mnemonic = await authModel.getMnemonic();
  final address = await ref.read(liquidAddressProvider.future);
  final amount = await ref.watch(lnAmountProvider.future);
  final receive = await LbtcBoltz.createBoltzReceive(
      fees: fees, mnemonic: mnemonic!, index: address.index, address: address.confidential, amount: amount);
  final box = await SecureKeyManager.openEncryptedBox('receiveBoltz');
  await box.put(receive.swap.id, receive);
  return receive;
});

final claimSingleBoltzTransactionProvider = FutureProvider.autoDispose.family<bool, String>((ref, id) async {
  final receiveAddress = await ref.read(liquidAddressProvider.future);
  final fees = await ref.read(boltzReverseFeesProvider.future);
  final box = await SecureKeyManager.openEncryptedBox('receiveBoltz');
  final boltzReceive = box.get(id) as LbtcBoltz;
  final received = await boltzReceive.claimBoltzTransaction(receiveAddress: receiveAddress.confidential, fees: fees, keyIndex: receiveAddress.index);
  if (received) {
    await box.delete(boltzReceive.swap.id);
  } else {
    throw 'Could not claim transaction';
  }
  return received;
});

final deleteSingleBoltzTransactionProvider = FutureProvider.autoDispose.family<void, String>((ref, id) async {
  final receiveBox = await SecureKeyManager.openEncryptedBox('receiveBoltz');
  final payBox = await SecureKeyManager.openEncryptedBox('payBoltz');
  await receiveBox.delete(id);
  await payBox.delete(id);
});


final boltzPayProvider = FutureProvider.autoDispose<LbtcBoltz>((ref) async {
  final fees = await ref.read(boltzSubmarineFeesProvider.future);
  var sendTx = ref.watch(sendTxProvider.notifier);
  final address = await ref.read(liquidAddressProvider.future);
  final authModel = ref.read(authModelProvider);
  final mnemonic = await authModel.getMnemonic();
  final pay = await LbtcBoltz.createBoltzPay(
      fees: fees, mnemonic: mnemonic!, invoice: sendTx.state.address, amount: sendTx.state.amount, index: address.index);
  final box = await SecureKeyManager.openEncryptedBox('payBoltz');
  await box.put(pay.swap.id, pay);
  sendTx.state = sendTx.state.copyWith(address: pay.swap.scriptAddress, amount: (pay.swap.outAmount).toInt());
  await ref.read(sendLiquidTransactionProvider.future).then((value) => value);
  return pay;
});

final refundSingleBoltzTransactionProvider = FutureProvider.autoDispose.family<bool, String>((ref, id) async {
  final fees = await ref.read(boltzSubmarineFeesProvider.future);
  final address = await ref.read(liquidAddressProvider.future);
  final box = await SecureKeyManager.openEncryptedBox('payBoltz');
  final boltzPay = box.get(id) as LbtcBoltz;
  final refunded = await boltzPay.refund(fees: fees, tryCooperate: true, outAddress: address.confidential, keyIndex: address.index);
  if (refunded) {
    await box.delete(boltzPay.swap.id);
  } else {
    throw 'Could not refund transaction';
  }
  return refunded;
});

final receivedBoltzProvider = FutureProvider.autoDispose<List<LbtcBoltz>>((ref) async {
  final box = await SecureKeyManager.openEncryptedBox('receiveBoltz');
  return box.values.map((item) => item as LbtcBoltz).toList();
});

final payedBoltzProvider = FutureProvider.autoDispose<List<LbtcBoltz>>((ref) async {
  final box = await SecureKeyManager.openEncryptedBox('payBoltz');
  return box.values.map((item) => item as LbtcBoltz).toList();
});

final claimAndDeleteAllBoltzProvider = FutureProvider.autoDispose<void>((ref) async {
  try {
    final receiveBox = await SecureKeyManager.openEncryptedBox('receiveBoltz');
    final receive = await ref.read(receivedBoltzProvider.future).then((value) => value);
    final currentLiquidTip = await getCurrentBlockHeight();

    for (var item in receive) {
      if (item.swapScript.locktime < currentLiquidTip) {
        receiveBox.delete(item.swap.id);
      } else {
        await ref.read(claimSingleBoltzTransactionProvider(item.swap.id).future).then((value) => value);
      }
    }
  } catch (_) {
    // Ignore any errors
  }
});

// New Bitcoin Boltz Providers

final bitcoinBoltzFeesProvider = FutureProvider.autoDispose<ReverseFeesAndLimits>((ref) async {
  try {
    final fees = await Fees.newInstance(boltzUrl: 'https://api.boltz.exchange');
    return await fees.reverse();
  } catch (e) {
    throw 'Could not fetch fees';
  }
});

final bitcoinBoltzSubmarineFeesProvider = FutureProvider.autoDispose<SubmarineFeesAndLimits>((ref) async {
  try {
    final fees = await Fees.newInstance(boltzUrl: 'https://api.boltz.exchange');
    return await fees.submarine();
  } catch (e) {
    throw 'Could not fetch fees';
  }
});


final bitcoinBoltzReceiveProvider = FutureProvider.autoDispose<BtcBoltz>((ref) async {
  final fees = await ref.read(bitcoinBoltzFeesProvider.future);
  final authModel = ref.read(authModelProvider);
  final mnemonic = await authModel.getMnemonic();
  final address = await ref.read(bitcoinAddressProvider.future);
  final addressInfo = await ref.read(bitcoinAddressInfoProvider.future);
  final amount = await ref.watch(lnAmountProvider.future);
  final receive = await BtcBoltz.createBoltzReceive(
      fees: fees, mnemonic: mnemonic!, index: addressInfo.index, address: address, amount: amount);
  final box = await SecureKeyManager.openEncryptedBox('bitcoinReceiveBoltz');
  await box.put(receive.swap.id, receive);
  return receive;
});


final claimSingleBitcoinBoltzTransactionProvider = FutureProvider.autoDispose.family<bool, String>((ref, id) async {
  final receiveAddress = await ref.read(bitcoinAddressProvider.future);
  final receiveAddressInfo = await ref.read(bitcoinAddressInfoProvider.future);
  final fees = await ref.read(bitcoinBoltzFeesProvider.future);
  final box = await SecureKeyManager.openEncryptedBox('bitcoinReceiveBoltz');
  final boltzReceive = box.get(id) as BtcBoltz;
  final received = await boltzReceive.claimBoltzTransaction(receiveAddress: receiveAddress, fees: fees, keyIndex: receiveAddressInfo.index);
  if (received) {
    await box.delete(boltzReceive.swap.id);
  } else {
    throw 'Could not claim transaction';
  }
  return received;
});

final deleteSingleBitcoinBoltzTransactionProvider = FutureProvider.autoDispose.family<void, String>((ref, id) async {
  final receiveBox = await SecureKeyManager.openEncryptedBox('bitcoinReceiveBoltz');
  final payBox = await SecureKeyManager.openEncryptedBox('bitcoinPayBoltz');
  await receiveBox.delete(id);
  await payBox.delete(id);
});

final bitcoinBoltzPayProvider = FutureProvider.autoDispose<BtcBoltz>((ref) async {
  final fees = await ref.read(bitcoinBoltzSubmarineFeesProvider.future);
  var sendTx = ref.watch(sendTxProvider.notifier);
  final addressInfo = await ref.read(bitcoinAddressInfoProvider.future);
  final authModel = ref.read(authModelProvider);
  final mnemonic = await authModel.getMnemonic();
  final pay = await BtcBoltz.createBoltzPay(
      fees: fees, mnemonic: mnemonic!, invoice: sendTx.state.address, amount: sendTx.state.amount, index: addressInfo.index);
  final box = await SecureKeyManager.openEncryptedBox('bitcoinPayBoltz');
  await box.put(pay.swap.id, pay);
  sendTx.state = sendTx.state.copyWith(address: pay.swap.scriptAddress, amount: (pay.swap.outAmount).toInt());
  await ref.read(sendBitcoinTransactionProvider.future).then((value) => value);
  return pay;
});

final refundSingleBitcoinBoltzTransactionProvider = FutureProvider.autoDispose.family<bool, String>((ref, id) async {
  final fees = await ref.read(bitcoinBoltzSubmarineFeesProvider.future);
  final address = await ref.read(bitcoinAddressProvider.future);
  final addressInfo = await ref.read(bitcoinAddressInfoProvider.future);
  final box = await SecureKeyManager.openEncryptedBox('bitcoinPayBoltz');
  final boltzPay = box.get(id) as BtcBoltz;
  final refunded = await boltzPay.refund(fees: fees, tryCooperate: true, outAddress: address, keyIndex: addressInfo.index);
  if (refunded) {
    await box.delete(boltzPay.swap.id);
  } else {
    throw 'Could not refund transaction';
  }
  return refunded;
});

final receivedBitcoinBoltzProvider = FutureProvider.autoDispose<List<BtcBoltz>>((ref) async {
  final box = await SecureKeyManager.openEncryptedBox('bitcoinReceiveBoltz');
  return box.values.map((item) => item as BtcBoltz).toList();
});

final payedBitcoinBoltzProvider = FutureProvider.autoDispose<List<BtcBoltz>>((ref) async {
  final box = await SecureKeyManager.openEncryptedBox('bitcoinPayBoltz');
  return box.values.map((item) => item as BtcBoltz).toList();
});

final claimAndDeleteAllBitcoinBoltzProvider = FutureProvider.autoDispose<void>((ref) async {
  try {
    final receiveBox = await SecureKeyManager.openEncryptedBox('bitcoinReceiveBoltz');
    final receive = await ref.read(receivedBitcoinBoltzProvider.future).then((value) => value);
    final currentBitcoinTip = await getCurrentBitcoinBlockHeight();

    for (var item in receive) {
      if (item.swapScript.locktime < currentBitcoinTip) {
        receiveBox.delete(item.swap.id);
      } else {
        await ref.read(claimSingleBitcoinBoltzTransactionProvider(item.swap.id).future).then((value) => value);
      }
    }
  } catch (_) {
    // Ignore any errors
  }
});
