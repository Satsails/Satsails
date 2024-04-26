import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;

class SideswapStreamPrices {
  late IOWebSocketChannel _channel;
  final _messageController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get messageStream => _messageController.stream;

  void connect({
    required String? asset,
    required bool? sendBitcoins,
    int? sendAmount,
  }) {
    _channel = IOWebSocketChannel.connect('wss://api.sideswap.io/json-rpc-ws');
    streamPrices(method: 'subscribe_price_stream', asset: asset, sendBitcoins: sendBitcoins, sendAmount: sendAmount);

    _channel.stream.listen(handleIncomingMessage);
  }

  void streamPrices({
    required String? asset,
    required String method,
    required bool? sendBitcoins,
    int? sendAmount,
  }) {
    _channel.sink.add(json.encode({
      'id': 1,
      'method': method,
      'params': {
        'asset': asset,
        'send_bitcoins': sendBitcoins,
        'send_amount': sendAmount,
      },
    }));
  }

  void handleIncomingMessage(dynamic message) {
    if (message is String) {
      var decodedMessage = json.decode(message);
      _messageController.add(decodedMessage);
    }
  }

  void close() {
    _channel.sink.close();
  }
}

class SideswapStartExchange {
  late IOWebSocketChannel _channel;
  final _messageController = StreamController<dynamic>.broadcast();
  Stream<dynamic> get messageStream => _messageController.stream;

  void connect({
    required String asset,
    required bool sendBitcoins,
    required double price,
    required int recvAmount,
    required int sendAmount,
  }) {
    _channel = IOWebSocketChannel.connect('wss://api.sideswap.io/json-rpc-ws');
    startExchange(
      asset: asset,
      method: 'start_swap_web',
      sendBitcoins: sendBitcoins,
      sendAmount: sendAmount,
      recvAmount: recvAmount,
      price: price,
    );

    _channel.stream.listen(handleIncomingMessage);
  }

  void startExchange({
    required String asset,
    required String method,
    required bool sendBitcoins,
    required double price,
    required int sendAmount,
    required int recvAmount,
  }) {
    _channel.sink.add(json.encode({
      'id': 1,
      'method': method,
      'params': {
        'asset': asset,
        'send_bitcoins': sendBitcoins,
        'price': price,
        'send_amount': sendAmount,
        'recv_amount': recvAmount,
      },
    }));
  }

  void handleIncomingMessage(dynamic message) {
    var decodedMessage = json.decode(message);
    _messageController.add(decodedMessage);
  }

  void close() {
    _channel.sink.close();
  }
}

class SideswapUploadData {
  Future<void> uploadInputs(
      Map<String, dynamic> params,
      // Map<String, dynamic> returnAddress,
      String returnAddress,
      Map<String, dynamic> inputs,
      Map<String, dynamic> receiveAddress,
      ) async {
    try {
      final result = params["result"];
      final endpoint = result["upload_url"];
      final Map<String, dynamic> requestData = {
        "id": 1,
        "method": "swap_start",
        "params": {
          "change_addr": returnAddress,
          "inputs": inputs["utxos"],
          "order_id": result["order_id"],
          "recv_addr": receiveAddress["address"],
          "recv_amount": result["recv_amount"],
          "recv_asset": result["recv_asset"],
          "send_amount": result["send_amount"],
          "send_asset": result["send_asset"],
        },
      };

      final uri = Uri.parse(endpoint);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // walletStrategy.signInputs(responseData, result["order_id"], uri, result["send_asset"]);

      } else {
        print('HTTP request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> signInputs(String data, String orderId, String submitId, Uri uri) async {
    final Map<String, dynamic> requestData = {
      "id": 1,
      "method": "swap_sign",
      "params": {
        "order_id": orderId,
        "submit_id": submitId,
        "pset": data,
      },
    };

    http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestData),
    ).then((response) {
      if (response.statusCode == 200) {
        print('Sign inputs response: ${response.body}');
      } else {
        print('HTTP request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    });
  }
}
