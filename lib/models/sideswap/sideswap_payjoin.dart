// import 'package:Satsails/models/liquid_model.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lwk/lwk.dart';
//
// class SideswapPayjoinModel extends StateNotifier<SideswapPayjoin> {
//   SideswapPayjoinModel(super.state);
//
//   void updatePayjoin(SideswapPayjoin newPayjoin) {
//     state = newPayjoin;
//   }
//
//   void updatePayjoinSigning(String signedPset) {
//     state = SideswapPayjoin(
//       orderId: state.orderId,
//       expiresAt: state.expiresAt,
//       price: state.price,
//       fixedFee: state.fixedFee,
//       feeAddress: state.feeAddress,
//       changeAddress: state.changeAddress,
//       utxos: state.utxos,
//       signedPset: signedPset,
//     );
//   }
// }
//
// class SideswapPayjoin {
//   String orderId;
//   int expiresAt;
//   double price;
//   int fixedFee;
//   String feeAddress;
//   String changeAddress;
//   List<ExternalUtxo> utxos;
//   String? signedPset;
//
//   SideswapPayjoin({
//     required this.orderId,
//     required this.expiresAt,
//     required this.price,
//     required this.fixedFee,
//     required this.feeAddress,
//     required this.changeAddress,
//     required this.utxos,
//     this.signedPset,
//   });
//
//   factory SideswapPayjoin.fromJson(Map<String, dynamic> json) {
//     if (json['start'] != null) {
//       var start = json['start'];
//       return SideswapPayjoin(
//         orderId: start['order_id'],
//         expiresAt: start['expires_at'],
//         price: start['price'].toDouble(),
//         fixedFee: start['fixed_fee'],
//         feeAddress: start['fee_address'],
//         changeAddress: start['change_address'],
//         utxos: (start['utxos'] as List)
//             .map((utxo) => ExternalUtxoExtension.fromPayjoinUtxo(PayjoinUtxo.fromJson(utxo), start['fee_address']))
//             .toList(),
//         signedPset: null,
//       );
//     } else if (json['pset'] != null) {
//       return SideswapPayjoin(
//         orderId: '',
//         expiresAt: 0,
//         price: 0.0,
//         fixedFee: 0,
//         feeAddress: '',
//         changeAddress: '',
//         utxos: [],
//         signedPset: json['pset'],
//       );
//     } else {
//       throw Exception('Invalid payjoin response: missing start or sign');
//     }
//   }
// }
//
// class PayjoinUtxo {
//   String txid;
//   int vout;
//   String scriptPubKey;
//   String assetId;
//   int value;
//   String assetBf;
//   String valueBf;
//   String assetCommitment;
//   String valueCommitment;
//
//   PayjoinUtxo({
//     required this.txid,
//     required this.vout,
//     required this.scriptPubKey,
//     required this.assetId,
//     required this.value,
//     required this.assetBf,
//     required this.valueBf,
//     required this.assetCommitment,
//     required this.valueCommitment,
//   });
//
//   factory PayjoinUtxo.fromJson(Map<String, dynamic> json) {
//     return PayjoinUtxo(
//       txid: json['txid'],
//       vout: json['vout'],
//       scriptPubKey: json['script_pub_key'],
//       assetId: json['asset_id'],
//       value: json['value'],
//       assetBf: json['asset_bf'],
//       valueBf: json['value_bf'],
//       assetCommitment: json['asset_commitment'],
//       valueCommitment: json['value_commitment'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'txid': txid,
//       'vout': vout,
//       'script_pub_key': scriptPubKey,
//       'asset_id': assetId,
//       'value': value,
//       'asset_bf': assetBf,
//       'value_bf': valueBf,
//       'asset_commitment': assetCommitment,
//       'value_commitment': valueCommitment,
//     };
//   }
// }
//
// extension ExternalUtxoExtension on ExternalUtxo {
//   static ExternalUtxo fromPayjoinUtxo(PayjoinUtxo payjoinUtxo, String feeAddress) {
//     final outpoint = OutPoint(
//       txid: payjoinUtxo.txid,
//       vout: payjoinUtxo.vout,
//     );
//
//     final unblinded = TxOutSecrets(
//       asset: payjoinUtxo.assetId,
//       value: BigInt.from(payjoinUtxo.value),
//       assetBf: payjoinUtxo.assetBf,
//       valueBf: payjoinUtxo.valueBf,
//     );
//
//     final txout = TxOut(
//       scriptPubkey: payjoinUtxo.scriptPubKey,
//       outpoint: outpoint,
//       unblinded: unblinded,
//       isSpent: false,
//       address: Address(standard: '', confidential: feeAddress),
//     );
//
//     final maxWeightToSatisfy = BigInt.from(1000);
//
//     return ExternalUtxo(
//       outpoint: outpoint,
//       txout: txout,
//       unblinded: unblinded,
//       maxWeightToSatisfy: maxWeightToSatisfy,
//     );
//   }
// }