import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/helpers/asset_mapper.dart';
import 'package:Satsails/models/address_model.dart';

class SendTxModel extends StateNotifier<SendTx> {
  SendTxModel(super.state);

  void updateAddress(String address) {
    state = state.copyWith(address: address);
  }

  void resetToDefault() {
    state = SendTx(address: '', amount: 0, type: PaymentType.Unknown, assetId: AssetMapper.reverseMapTicker(AssetId.LBTC));
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

  void updateAmountFromInput(String value, String denomination) {
    if (value.isEmpty) {
      state = state.copyWith(amount: 0);
      return;
    }

    if (state.assetId != AssetMapper.reverseMapTicker(AssetId.LBTC)) {
      state = state.copyWith(amount: (double.parse(value) * 100000000).toInt());
      return;
    }

    int amount;
    switch (denomination) {
      case 'sats':
        amount = int.parse(value);
        break;
      case 'BTC':
        amount = (double.parse(value) * 100000000).toInt();
        break;
      case 'mBTC':
        amount = (double.parse(value) * 100000).toInt();
        break;
      case 'bits':
        amount = (double.parse(value) * 100).toInt();
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


  double btcBalanceInDenominationFormatted(String denomination) {
    double balance;

    if (assetId != AssetMapper.reverseMapTicker(AssetId.LBTC)) {
      return amount / 100000000;
    }

    switch (denomination) {
      case 'sats':
        balance = amount.toDouble();
        return balance;
      case 'BTC':
        balance = (amount / 100000000);
        return balance;
      case 'mBTC':
        balance = (amount / 100000000) * 1000;
        return balance;
      case 'bits':
        balance = (amount / 100000000) * 1000000;
        return balance;
      default:
        return 0;
    }
  }
}