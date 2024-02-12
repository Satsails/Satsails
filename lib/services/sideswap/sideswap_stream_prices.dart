import 'dart:convert';
import 'package:web_socket_channel/io.dart';

class SideswapStreamPrices {
  late IOWebSocketChannel _channel;

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
      print(decodedMessage);
    }
  }

  void close() {
    _channel.sink.close();
  }
}
