import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';

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

  void connect({
    required String asset,
    required bool sendBitcoins,
    required int price,
    required int recvAmount,
    int? sendAmount,
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
    int? price,
    int? sendAmount,
    int? recvAmount,
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

class SideswapUploadData{

}

