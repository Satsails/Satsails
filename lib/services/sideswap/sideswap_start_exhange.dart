import 'dart:convert';
import 'package:web_socket_channel/io.dart';

class SideswapStartExhange {
  late IOWebSocketChannel _channel;

  void connect({
    required String asset,
    required bool sendBitcoins,
    required int price,
    required int recvAmount,
    int? sendAmount,
  }) {
    _channel = IOWebSocketChannel.connect('wss://api.sideswap.io/json-rpc-ws');
    startExchange(asset: asset, method: 'start_swap_web', sendBitcoins: sendBitcoins, sendAmount: sendAmount, recvAmount: recvAmount, price: price);
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

  void handleIncomingMessage(String message) {
    var decodedMessage = json.decode(message);
    print(decodedMessage);
  }

  void close() {
    _channel.sink.close();
  }
}
