import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/address_model.dart';

class SendTxModel extends StateNotifier<SendTx> {
  SendTxModel(super.state);

  void updateAddress(String address) {
    state = state.copyWith(address: address);
  }

  void resetToDefault() {
    state = SendTx(address: '', amount: 0, type: PaymentType.Unknown, assetId: AssetMapper.reverseMapTicker(AssetId.LBTC), drain: false);
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

  void updateDrain(bool drain) {
    state = state.copyWith(drain: drain);
  }

  void updateAmountFromInput(String value, String denomination) {
    if (value.isEmpty || (Decimal.tryParse(value) ?? Decimal.zero) == Decimal.zero) {
      state = state.copyWith(amount: 0);
      return;
    }

    final amountDecimal = Decimal.parse(value);
    final satsFactor = Decimal.fromInt(100000000);

    if (state.assetId != AssetMapper.reverseMapTicker(AssetId.LBTC)) {
      final result = amountDecimal * satsFactor;
      state = state.copyWith(amount: result.toBigInt().toInt());
      return;
    }

    int amount;
    switch (denomination) {
      case 'sats':
        amount = amountDecimal.toBigInt().toInt();
        break;
      case 'BTC':
        final result = amountDecimal * satsFactor;
        amount = result.toBigInt().toInt();
        break;
      default:
        amount = 0;
    }
    state = state.copyWith(amount: amount);
  }
}

class SendTx {
  final String address;
  final int amount;
  final PaymentType type;
  final String assetId;
  final bool drain;

  SendTx({
    required this.address,
    required this.amount,
    required this.type,
    required this.assetId,
    required this.drain,
  });

  SendTx copyWith({
    String? address,
    int? amount,
    PaymentType? type,
    String? assetId,
    bool? drain,
  }) {
    return SendTx(
      address: address ?? this.address,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      assetId: assetId ?? this.assetId,
      drain: drain ?? this.drain,
    );
  }
}