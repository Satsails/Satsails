// import 'package:boltz_dart/boltz_dart.dart';
//
// Future<(SwapTx?, Err?)> receiveV2({
//   required String mnemonic,
//   required int index,
//   required int outAmount,
//   required Chain network,
//   required String electrumUrl,
//   required String boltzUrl,
//   required bool isLiquid,
// }) async {
//   try {
//     late SwapTx swapTx;
//     if (!isLiquid) {
//       final res = await BtcLnV2Swap.newReverse(
//         mnemonic: mnemonic,
//         index: index,
//         outAmount: outAmount,
//         network: network,
//         electrumUrl: electrumUrl,
//         boltzUrl: boltzUrl,
//       );
//       final obj = res;
//
//       final swapSensitive = res.createSwapFromBtcLnV2Swap();
//       // SwapTxSensitive.fromBtcLnSwap(res);
//       final err = await _secureStorage.saveValue(
//         key: StorageKeys.swapTxSensitive + '_' + obj.id,
//         value: jsonEncode(swapSensitive.toJson()),
//       );
//       if (err != null) throw err;
//       swapTx = res.createSwapFromBtcLnV2Swap();
//       // SwapTx.fromBtcLnSwap(res);
//     } else {
//       final res = await LbtcLnV2Swap.newReverse(
//         mnemonic: mnemonic,
//         index: index,
//         outAmount: outAmount,
//         network: network,
//         electrumUrl: electrumUrl,
//         boltzUrl: boltzUrl,
//       );
//       final obj = res;
//
//       final swapSensitive = res.createSwapSensitiveFromLbtcLnV2Swap();
//       // SwapTxSensitive.fromLbtcLnSwap(res);
//       final err = await _secureStorage.saveValue(
//         key: StorageKeys.swapTxSensitive + '_' + obj.id,
//         value: jsonEncode(swapSensitive.toJson()),
//       );
//       if (err != null) throw err;
//       swapTx = res.createSwapFromLbtcLnV2Swap();
//       // SwapTx.fromLbtcLnSwap(res);
//     }
//
//     return (swapTx, null);
//   } catch (e) {
//     return (null, Err(e.toString()));
//   }
// }
