import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/address_model.dart';

class SendTxModel extends StateNotifier<SendTx> {
  SendTxModel(SendTx state) : super(state);

  void updateBlocks(int blocks) {
    state = state.copyWith(blocks: blocks);
  }

  void updateAddress(String address) {
    state = state.copyWith(address: address);
  }

  void updateAmount(int amount) {
    state = state.copyWith(amount: amount);
  }

  void updatePaymentType(PaymentType type) {
    state = state.copyWith(type: type);
  }

  void updateAssetId(String assetId) {
    state = state.copyWith(assetId: assetId);
  }
}


class SendTx {
  final int blocks;
  final String address;
  final int amount;
  final PaymentType type;
  final String? assetId;

  SendTx({
    required this.blocks,
    required this.address,
    required this.amount,
    required this.type,
    this.assetId
  });
  
  SendTx copyWith({
    int? blocks,
    String? address,
    int? amount,
    PaymentType? type,
    String? assetId,
  }) {
    return SendTx(
      blocks: blocks ?? this.blocks,
      address: address ?? this.address,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      assetId: assetId,
    );
  }
}