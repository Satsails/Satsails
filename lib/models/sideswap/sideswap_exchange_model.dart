import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lwk_dart/lwk_dart.dart';

part 'sideswap_exchange_model.g.dart';

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

  Future<SideswapPsetToSign> uploadInputs(String returnAddress, List<TxOut> inputs, String receiveAddress, int sendAmount) async {

    final List<TxOut> assetInputs = inputs.where((TxOut utxo) => utxo.unblinded.asset == sendAsset).toList();

    List<TxOut> assetInputForAmount = [];
    int total = 0;

    for (TxOut utxo in assetInputs) {
      if (total >= sendAmount) {
        break;
      }
      total += utxo.unblinded.value;
      assetInputForAmount.add(utxo);
    }

    List<Map<String, dynamic>> generateTransactionInputs(List<TxOut> assetInputForAmount) {
      List<Map<String, dynamic>> formattedTransactionInputs = [];

      for (TxOut utxo in assetInputForAmount) {
        Map<String, dynamic> transactionInput = {
          "asset": sendAsset,
          "asset_bf": utxo.unblinded.assetBf,
          "redeem_script": utxo.scriptPubkey,
          "txid": utxo.outpoint.txid,
          "value": utxo.unblinded.value,
          "value_bf": utxo.unblinded.valueBf,
          "vout": utxo.outpoint.vout,
        };
        formattedTransactionInputs.add(transactionInput);
      }

      return formattedTransactionInputs;
    }


    final Map<String, dynamic> requestData = {
      "id": 1,
      "method": "swap_start",
      "params": {
        "change_addr": returnAddress,
        "inputs": generateTransactionInputs(assetInputForAmount),
        "order_id": orderId,
        "recv_addr": receiveAddress,
        "recv_amount": recvAmount,
        "recv_asset": recvAsset,
        "send_amount": sendAmount,
        "send_asset": sendAsset,
      },
    };


    final uri = Uri.parse(uploadUrl);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return SideswapPsetToSign.fromJson(responseData, orderId);
      } else {
        response.body.contains("UTXO amount") ? throw Exception('Balance insufficient.') :
        throw 'Swap failed, please try again';
      }
  }


  Future<SideswapCompletedSwap> uploadPset(String pset, String submitId) async {
    final uri = Uri.parse(uploadUrl);

    final Map<String, dynamic> requestData = {
      "id": 1,
      "method": "swap_sign",
      "params": {
        "order_id": orderId,
        "submit_id": submitId,
        "pset": pset,
      },
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return  SideswapCompletedSwap(
        txid: responseData['result']['txid'],
        sendAsset: sendAsset,
        sendAmount: sendAmount,
        recvAsset: recvAsset,
        recvAmount: recvAmount,
        orderId: orderId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } else {
      throw 'Swap failed, please try again';
    }
  }
}

@HiveType(typeId: 11)
class SideswapCompletedSwap {
  @HiveField(0)
  final String txid;
  @HiveField(1)
  final String sendAsset;
  @HiveField(2)
  final num sendAmount;
  @HiveField(3)
  final String recvAsset;
  @HiveField(4)
  final num recvAmount;
  @HiveField(5)
  final String orderId;
  @HiveField(6)
  final int timestamp;

  SideswapCompletedSwap({
    required this.txid,
    required this.sendAsset,
    required this.sendAmount,
    required this.recvAsset,
    required this.recvAmount,
    required this.orderId,
    required this.timestamp,
  });
}

class SideswapPsetToSign {
  final String pset;
  final String submitId;
  final String orderId;

  SideswapPsetToSign({required this.pset, required this.submitId, required this.orderId});

  factory SideswapPsetToSign.fromJson(Map<String, dynamic> json, String orderId) {
    return SideswapPsetToSign(
      pset: json['result']['pset'],
      submitId: json['result']['submit_id'],
      orderId: orderId,
    );
  }
}

class SideswapExchangeStateModel extends StateNotifier<SideswapExchangeState> {
  SideswapExchangeStateModel(super.state);

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