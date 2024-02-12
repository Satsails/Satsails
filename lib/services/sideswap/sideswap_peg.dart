import 'dart:convert';
import 'package:web_socket_channel/io.dart';

class SideswapPeg {
  late IOWebSocketChannel _channel;

  void connect({
    required String recv_addr,
    required bool peg_in,
  }) {
    _channel = IOWebSocketChannel.connect('wss://api.sideswap.io/json-rpc-ws');
    peg(method: 'peg', peg_in: peg_in, recv_addr: recv_addr);

    _channel.stream.listen(handleIncomingMessage);
  }

  void peg({
    required String method,
    required bool? peg_in,
    required String? recv_addr,
  }) {
    _channel.sink.add(json.encode({
      'id': 1,
      'method': method,
      'params': {
        'peg_in': peg_in,
        'recv_addr': recv_addr,
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

class SideswapPegStatus {
  late IOWebSocketChannel _channel;

  void connect({
    required String order_id,
    required bool peg_in,
  }) {
    _channel = IOWebSocketChannel.connect('wss://api.sideswap.io/json-rpc-ws');
    peg(method: 'peg_status', peg_in: peg_in, order_id: order_id);

    _channel.stream.listen(handleIncomingMessage);
  }

  void peg({
    required String method,
    required String order_id,
    required bool? peg_in,
  }) {
    _channel.sink.add(json.encode({
      'id': 1,
      'method': method,
      'params': {
        'peg_in': peg_in,
        'order_id': order_id,
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
