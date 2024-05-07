class SideswapStartExchange {
  String orderId;
  String sendAsset;
  num sendAmount;
  String recvAsset;
  num recvAmount;
  String uploadUrl;

  SideswapStartExchange({
    required this.orderId,
    required this.sendAsset,
    required this.sendAmount,
    required this.recvAsset,
    required this.recvAmount,
    required this.uploadUrl,
  });

  factory SideswapStartExchange.fromJson(Map<String, dynamic> json) {
    var result = json['result'];
    return SideswapStartExchange(
      orderId: result['order_id'],
      sendAsset: result['send_asset'],
      sendAmount: result['send_amount'],
      recvAsset: result['recv_asset'],
      recvAmount: result['recv_amount'],
      uploadUrl: result['upload_url'],
    );
  }
}

class SideswapExchangeDone {
  String orderId;
  String status;
  int price;
  String sendAsset;
  int sendAmount;
  String recvAsset;
  int recvAmount;
  String? txid;
  int? networkFee;

  SideswapExchangeDone({
    required this.orderId,
    required this.status,
    required this.price,
    required this.sendAsset,
    required this.sendAmount,
    required this.recvAsset,
    required this.recvAmount,
    this.txid,
    this.networkFee,
  });

  factory SideswapExchangeDone.fromJson(Map<String, dynamic> json) {
    return SideswapExchangeDone(
      orderId: json['order_id'],
      status: json['status'],
      price: json['price'],
      sendAsset: json['send_asset'],
      sendAmount: json['send_amount'],
      recvAsset: json['recv_asset'],
      recvAmount: json['recv_amount'],
      txid: json['txid'],
      networkFee: json['network_fee'],
    );
  }
}