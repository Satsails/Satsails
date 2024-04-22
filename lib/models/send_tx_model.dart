import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/address_model.dart';

class SendTxModel extends StateNotifier<SendTx> {
  SendTxModel(SendTx state) : super(state);

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
  final String address;
  final int amount;
  final PaymentType type;
  final String assetId;

  SendTx({
    required this.address,
    required this.amount,
    required this.type,
    required this.assetId
  });
  
  SendTx copyWith({
    String? address,
    int? amount,
    PaymentType? type,
    String? assetId,
  }) {
    return SendTx(
      address: address ?? this.address,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      assetId: assetId ?? this.assetId,
    );
  }
}