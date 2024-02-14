import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';

class SideswapPeg {
  late IOWebSocketChannel _channel;
  final _messageController = StreamController<dynamic>.broadcast();

  Stream<dynamic> get messageStream => _messageController.stream;

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
      _messageController.add(decodedMessage);
    }
  }

  void close() {
    _channel.sink.close();
    _messageController.close();
  }
}

class SideswapPegStatus {
  late IOWebSocketChannel _channel;
  final _messageController = StreamController<dynamic>.broadcast();

  Stream<dynamic> get messageStream => _messageController.stream;

  void connect({
    required String order_id,
    required bool pegIn,
  }) {
    _channel = IOWebSocketChannel.connect('wss://api.sideswap.io/json-rpc-ws');
    peg(method: 'peg_status', pegIn: pegIn, order_id: order_id);

    _channel.stream.listen(handleIncomingMessage);
  }

  void peg({
    required String method,
    required String order_id,
    required bool? pegIn,
  }) {
    _channel.sink.add(json.encode({
      'id': 1,
      'method': method,
      'params': {
        'peg_in': pegIn,
        'order_id': order_id,
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
    _messageController.close();
  }
}