import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SideswapStartExchangeModel extends StateNotifier<SideswapStartExchange> {
  SideswapStartExchangeModel(SideswapStartExchange state) : super(state);

  void update(SideswapStartExchange state) {
    state = state;
  }

  Future<Map<String, dynamic>> uploadInputs(String returnAddress, Map<String, dynamic> inputs, String receiveAddress) async {
    final Map<String, dynamic> requestData = {
      "id": 1,
      "method": "swap_start",
      "params": {
        "change_addr": returnAddress,
        "inputs": inputs,
        "order_id": state.orderId,
        "recv_addr": receiveAddress,
        "recv_amount": state.recvAmount,
        "recv_asset": state.recvAsset,
        "send_amount": state.sendAmount,
        "send_asset": state.sendAsset,
      },
    };
    final uri = Uri.parse(state.uploadUrl);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      throw Exception('Failed: ${response.body}');
    }
  }
}

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

class SideswapExchangeStateModel extends StateNotifier<SideswapExchangeState> {
  SideswapExchangeStateModel(SideswapExchangeState state) : super(state);

  void update(SideswapExchangeState state) {
    state = state;
  }
}

class SideswapExchangeState {
  String orderId;
  String status;
  int price;
  String sendAsset;
  int sendAmount;
  String recvAsset;
  int recvAmount;
  String? txid;
  int? networkFee;

  SideswapExchangeState({
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

  factory SideswapExchangeState.fromJson(Map<String, dynamic> json) {
    return SideswapExchangeState(
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