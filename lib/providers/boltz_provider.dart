// COMMENTED OUT IN CASE WE HAVE TO RETURN IT BACK DEPENDING ON JOLTZ IMPLEMENTATION

// import 'package:Satsails/helpers/liquid_block_height.dart';
// import 'package:Satsails/models/auth_model.dart';
// import 'package:Satsails/models/boltz/boltz_model.dart';
// import 'package:Satsails/providers/address_receive_provider.dart';
// import 'package:Satsails/providers/auth_provider.dart';
// import 'package:Satsails/providers/bitcoin_provider.dart';
// import 'package:Satsails/providers/liquid_provider.dart';
// import 'package:Satsails/providers/send_tx_provider.dart';
// import 'package:Satsails/providers/settings_provider.dart';
// import 'package:boltz_dart/boltz_dart.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// // Original Liquid Boltz Providers
//
// final boltzReverseFeesProvider = FutureProvider.autoDispose<ReverseFeesAndLimits>((ref) async {
//   try {
//     final fees = await Fees.newInstance(boltzUrl: 'https://api.boltz.exchange/v2');
//     return await fees.reverse();
//   } catch (e) {
//     throw 'Could not fetch fees';
//   }
// });
//
// final boltzSubmarineFeesProvider = FutureProvider.autoDispose<SubmarineFeesAndLimits>((ref) async {
//   try {
//     final fees = await Fees.newInstance(boltzUrl: 'https://api.boltz.exchange/v2');
//     return await fees.submarine();
//   } catch (e) {
//     throw 'Could not fetch fees';
//   }
// });
//
// final boltzReceiveProvider = FutureProvider.autoDispose<LbtcBoltz>((ref) async {
//   final fees = await ref.read(boltzReverseFeesProvider.future);
//   final authModel = ref.read(authModelProvider);
//   final mnemonic = await authModel.getMnemonic();
//   final address = await ref.read(liquidAddressProvider.future);
//   final amount = ref.watch(sendTxProvider).amount == 0 ? await ref.watch(lnAmountProvider.future) : ref.watch(sendTxProvider).amount;
//   final electrumUrl = await ref.read(settingsProvider).liquidElectrumNode;
//   final receive = await LbtcBoltz.createBoltzReceive(fees: fees, mnemonic: mnemonic!, index: address.index, address: address.confidential, amount: amount, electrumUrl: electrumUrl);
//   final box = await SecureKeyManager.openEncryptedBox('receiveBoltz');
//   await box.put(receive.swap.id, receive);
//   return receive;
// });
//
// final claimSingleBoltzTransactionProvider = FutureProvider.autoDispose.family<bool, String>((ref, id) async {
//   final receiveAddress = await ref.read(liquidAddressProvider.future);
//   final fees = await ref.read(boltzReverseFeesProvider.future);
//   final box = await SecureKeyManager.openEncryptedBox('receiveBoltz');
//   final boltzReceive = box.get(id) as LbtcBoltz;
//
//   final electrumUrl = await ref.read(settingsProvider).liquidElectrumNode;
//
//   final received = await boltzReceive.claimBoltzTransaction(
//     receiveAddress: receiveAddress.confidential,
//     fees: fees,
//     electrumUrl: electrumUrl,
//     keyIndex: receiveAddress.index,
//   );
//
//   if (received) {
//     final updatedBoltz = LbtcBoltz(
//       swap: boltzReceive.swap,
//       keys: boltzReceive.keys,
//       preimage: boltzReceive.preimage,
//       swapScript: boltzReceive.swapScript,
//       timestamp: boltzReceive.timestamp,
//       completed: true,
//     );
//
//     await box.put(boltzReceive.swap.id, updatedBoltz);
//   } else {
//     throw 'Could not claim transaction';
//   }
//
//   return received;
// });
//
// final boltzPayProvider = FutureProvider.autoDispose<LbtcBoltz>((ref) async {
//   final fees = await ref.read(boltzSubmarineFeesProvider.future);
//   var sendTx = ref.watch(sendTxProvider.notifier);
//   final address = await ref.read(liquidAddressProvider.future);
//   final authModel = ref.read(authModelProvider);
//   final mnemonic = await authModel.getMnemonic();
//   final electrumUrl = await ref.read(settingsProvider).liquidElectrumNode;
//   final pay = await LbtcBoltz.createBoltzPay(fees: fees, mnemonic: mnemonic!, invoice: sendTx.state.address, amount: sendTx.state.amount, index: address.index, electrumUrl: electrumUrl);
//   final box = await SecureKeyManager.openEncryptedBox('payBoltz');
//   await box.put(pay.swap.id, pay);
//   sendTx.state = sendTx.state.copyWith(address: pay.swap.scriptAddress, amount: (pay.swap.outAmount).toInt());
//   await ref.read(sendLiquidTransactionProvider.future).then((value) => value);
//   final updatedBoltz = LbtcBoltz(
//     swap: pay.swap,
//     keys: pay.keys,
//     preimage: pay.preimage,
//     swapScript: pay.swapScript,
//     timestamp: pay.timestamp,
//     completed: true,
//   );
//   await box.put(pay.swap.id, updatedBoltz);
//   return pay;
// });
//
// final refundSingleBoltzTransactionProvider = FutureProvider.autoDispose.family<bool, String>((ref, id) async {
//   final fees = await ref.read(boltzSubmarineFeesProvider.future);
//   final address = await ref.read(liquidAddressProvider.future);
//   final box = await SecureKeyManager.openEncryptedBox('payBoltz');
//   final electrumUrl = await ref.read(settingsProvider).liquidElectrumNode;
//
//   final boltzPay = box.get(id) as LbtcBoltz;
//
//   final refunded = await boltzPay.refund(
//     fees: fees,
//     tryCooperate: true,
//     outAddress: address.confidential,
//     electrumUrl: electrumUrl,
//     keyIndex: address.index,
//   );
//
//   if (refunded) {
//     final updatedBoltz = LbtcBoltz(
//       swap: boltzPay.swap,
//       keys: boltzPay.keys,
//       preimage: boltzPay.preimage,
//       swapScript: boltzPay.swapScript,
//       timestamp: boltzPay.timestamp, // Keep the original timestamp
//       completed: true, // Mark as completed
//     );
//
//     await box.put(boltzPay.swap.id, updatedBoltz);
//   } else {
//     throw 'Could not refund transaction';
//   }
//
//   return refunded;
// });
//
//
// final receivedBoltzProvider = FutureProvider.autoDispose<List<LbtcBoltz>>((ref) async {
//   final box = await SecureKeyManager.openEncryptedBox('receiveBoltz');
//   return box.values.map((item) => item as LbtcBoltz).toList();
// });
//
// final payedBoltzProvider = FutureProvider.autoDispose<List<LbtcBoltz>>((ref) async {
//   final box = await SecureKeyManager.openEncryptedBox('payBoltz');
//   return box.values.map((item) => item as LbtcBoltz).toList();
// });
//
// final claimAndDeleteAllBoltzProvider = FutureProvider.autoDispose<void>((ref) async {
//   try {
//     final receive = await ref.read(receivedBoltzProvider.future).then((value) => value);
//     final currentLiquidTip = await getCurrentBlockHeight();
//
//     for (var item in receive) {
//       try {
//         if (item.swapScript.locktime < currentLiquidTip || (item.completed ?? false)) {
//           continue;
//         } else {
//           await ref.read(claimSingleBoltzTransactionProvider(item.swap.id).future).then((value) => value);
//         }
//       } catch (_) {
//         // Ignore any errors for this item and continue to the next
//       }
//     }
//   } catch (_) {
//     // Ignore any errors
//   }
// });
//
//
// final bitcoinBoltzReceiveProvider = FutureProvider.autoDispose<BtcBoltz>((ref) async {
//   final fees = await ref.read(boltzReverseFeesProvider.future);
//   final authModel = ref.read(authModelProvider);
//   final mnemonic = await authModel.getMnemonic();
//   final address = await ref.read(bitcoinAddressProvider.future);
//   final addressInfo = await ref.read(bitcoinAddressInfoProvider.future);
//   final amount = ref.watch(sendTxProvider).amount == 0 ? await ref.watch(lnAmountProvider.future) : ref.watch(sendTxProvider).amount;
//   final electrumUrl = await ref.read(settingsProvider).bitcoinElectrumNode;
//   final receive = await BtcBoltz.createBoltzReceive(
//       fees: fees, mnemonic: mnemonic!, index: addressInfo.index, address: address, amount: amount, electrumUrl: electrumUrl);
//   final box = await SecureKeyManager.openEncryptedBox('bitcoinReceiveBoltz');
//   await box.put(receive.swap.id, receive);
//   return receive;
// });
//
//
// final claimSingleBitcoinBoltzTransactionProvider = FutureProvider.autoDispose.family<bool, String>((ref, id) async {
//   final receiveAddress = await ref.read(bitcoinAddressProvider.future);
//   final receiveAddressInfo = await ref.read(bitcoinAddressInfoProvider.future);
//   final fees = await ref.read(boltzReverseFeesProvider.future);
//   final box = await SecureKeyManager.openEncryptedBox('bitcoinReceiveBoltz');
//   final electrumUrl = await ref.read(settingsProvider).bitcoinElectrumNode;
//
//   final boltzReceive = box.get(id) as BtcBoltz;
//
//   final received = await boltzReceive.claimBoltzTransaction(
//     receiveAddress: receiveAddress,
//     fees: fees,
//     keyIndex: receiveAddressInfo.index,
//     electrumUrl: electrumUrl,
//   );
//
//   if (received) {
//     final updatedBoltz = BtcBoltz(
//       swap: boltzReceive.swap,
//       keys: boltzReceive.keys,
//       preimage: boltzReceive.preimage,
//       swapScript: boltzReceive.swapScript,
//       timestamp: boltzReceive.timestamp,
//       completed: true,
//     );
//
//     await box.put(boltzReceive.swap.id, updatedBoltz);
//   } else {
//     throw 'Could not claim transaction';
//   }
//
//   return received;
// });
//
//
// final bitcoinBoltzPayProvider = FutureProvider.autoDispose<BtcBoltz>((ref) async {
//   final fees = await ref.read(boltzSubmarineFeesProvider.future);
//   var sendTx = ref.watch(sendTxProvider.notifier);
//   final addressInfo = await ref.read(bitcoinAddressInfoProvider.future);
//   final authModel = ref.read(authModelProvider);
//   final mnemonic = await authModel.getMnemonic();
//   final electrumUrl = await ref.read(settingsProvider).bitcoinElectrumNode;
//   final pay = await BtcBoltz.createBoltzPay(
//       fees: fees, mnemonic: mnemonic!, invoice: sendTx.state.address, amount: sendTx.state.amount, index: addressInfo.index, electrumUrl: electrumUrl);
//   final box = await SecureKeyManager.openEncryptedBox('bitcoinPayBoltz');
//   await box.put(pay.swap.id, pay);
//   sendTx.state = sendTx.state.copyWith(address: pay.swap.scriptAddress, amount: (pay.swap.outAmount).toInt());
//   await ref.read(sendBitcoinTransactionProvider.future).then((value) => value);
//   final updatedPay = BtcBoltz(
//     swap: pay.swap,
//     keys: pay.keys,
//     preimage: pay.preimage,
//     swapScript: pay.swapScript,
//     timestamp: pay.timestamp,
//     completed: true,
//   );
//   await box.put(pay.swap.id, updatedPay);
//   return pay;
// });
//
// final refundSingleBitcoinBoltzTransactionProvider = FutureProvider.autoDispose.family<bool, String>((ref, id) async {
//   final fees = await ref.read(boltzSubmarineFeesProvider.future);
//   final address = await ref.read(bitcoinAddressProvider.future);
//   final addressInfo = await ref.read(bitcoinAddressInfoProvider.future);
//   final box = await SecureKeyManager.openEncryptedBox('bitcoinPayBoltz');
//   final boltzPay = box.get(id) as BtcBoltz;
//   final electrumUrl = await ref.read(settingsProvider).bitcoinElectrumNode;
//
//   // Perform the refund
//   final refunded = await boltzPay.refund(
//     fees: fees,
//     tryCooperate: true,
//     outAddress: address,
//     keyIndex: addressInfo.index,
//     electrumUrl: electrumUrl,
//   );
//
//   if (refunded) {
//     // Instead of deleting the transaction, update its 'completed' status and save it back to the box
//     final updatedBoltz = BtcBoltz(
//       swap: boltzPay.swap,
//       keys: boltzPay.keys,
//       preimage: boltzPay.preimage,
//       swapScript: boltzPay.swapScript,
//       timestamp: boltzPay.timestamp, // Retain the original timestamp
//       completed: true, // Mark as completed
//     );
//
//     await box.put(boltzPay.swap.id, updatedBoltz);
//   } else {
//     throw 'Could not refund transaction';
//   }
//
//   return refunded;
// });
//
//
// final receivedBitcoinBoltzProvider = FutureProvider.autoDispose<List<BtcBoltz>>((ref) async {
//   final box = await SecureKeyManager.openEncryptedBox('bitcoinReceiveBoltz');
//   return box.values.map((item) => item as BtcBoltz).toList();
// });
//
// final payedBitcoinBoltzProvider = FutureProvider.autoDispose<List<BtcBoltz>>((ref) async {
//   final box = await SecureKeyManager.openEncryptedBox('bitcoinPayBoltz');
//   return box.values.map((item) => item as BtcBoltz).toList();
// });
//
// final claimAndDeleteAllBitcoinBoltzProvider = FutureProvider.autoDispose<void>((ref) async {
//   try {
//     final receive = await ref.read(receivedBitcoinBoltzProvider.future).then((value) => value);
//     final currentBitcoinTip = await getCurrentBitcoinBlockHeight();
//
//     for (var item in receive) {
//       try {
//         if (item.swapScript.locktime < currentBitcoinTip || (item.completed ?? false)) {
//           continue;
//         } else {
//           await ref.read(claimSingleBitcoinBoltzTransactionProvider(item.swap.id).future).then((value) => value);
//         }
//       } catch (_) {
//         // Ignore any errors for this item and continue to the next
//       }
//     }
//   } catch (_) {
//     // Ignore any errors
//   }
// });
//
// final allTransactionsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
//   final liquidReceived = await ref.watch(receivedBoltzProvider.future);
//   final bitcoinReceived = await ref.watch(receivedBitcoinBoltzProvider.future);
//   final liquidSent = await ref.watch(payedBoltzProvider.future);
//   final bitcoinSent = await ref.watch(payedBitcoinBoltzProvider.future);
//
//   return [
//     ...liquidReceived.map((tx) => {'tx': tx, 'isBitcoin': false, 'isSending': false}),
//     ...bitcoinReceived.map((tx) => {'tx': tx, 'isBitcoin': true, 'isSending': false}),
//     ...liquidSent.map((tx) => {'tx': tx, 'isBitcoin': false, 'isSending': true}),
//     ...bitcoinSent.map((tx) => {'tx': tx, 'isBitcoin': true, 'isSending': true}),
//   ];
// });

// final deleteBoltzTransactionProvider = FutureProvider.autoDispose.family<void, String>((ref, id) async {
//   final box = await SecureKeyManager.openEncryptedBox('receiveBoltz');
//   final bitcoinBox = await SecureKeyManager.openEncryptedBox('bitcoinReceiveBoltz');
//   final payBox = await SecureKeyManager.openEncryptedBox('payBoltz');
//   final bitcoinPayBox = await SecureKeyManager.openEncryptedBox('bitcoinPayBoltz');
//   await box.delete(id);
//   await bitcoinBox.delete(id);
//   await payBox.delete(id);
//   await bitcoinPayBox.delete(id);
// });