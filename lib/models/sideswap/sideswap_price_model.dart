import 'package:flutter_riverpod/flutter_riverpod.dart';

class SideswapPriceModel extends StateNotifier<SideswapPrice> {
  SideswapPriceModel(super.state);

  void updatePrice(SideswapPrice newPrice) {
    state = newPrice;
  }
}

class SideswapPrice {
  String? subscribeId;
  String? asset;
  bool? sendBitcoins;
  int? sendAmount;
  int? recvAmount;
  int? fixedFee;
  double? price;
  String? errorMsg;

  SideswapPrice({
    this.subscribeId,
    this.asset,
    this.sendBitcoins,
    this.sendAmount,
    this.recvAmount,
    this.fixedFee,
    this.price,
    this.errorMsg,
  });

  factory SideswapPrice.fromJson(Map<String, dynamic> json) {
    var result = json['result'] ?? json['params'];
    return SideswapPrice(
      subscribeId: result['subscribe_id'],
      asset: result['asset'],
      sendBitcoins: result['send_bitcoins'],
      sendAmount: result['send_amount'],
      recvAmount: result['recv_amount'],
      fixedFee: result['fixed_fee'],
      price: result['price'],
      errorMsg: result['error_msg'],
    );
  }
}