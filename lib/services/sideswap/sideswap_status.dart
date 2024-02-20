import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';

class SideswapServerStatus {
  late IOWebSocketChannel _channel;
  final _messageController = StreamController<dynamic>.broadcast();

  Stream<dynamic> get messageStream => _messageController.stream;

  void connect() {
    _channel = IOWebSocketChannel.connect('wss://api.sideswap.io/json-rpc-ws');
    _channel.sink.add(json.encode({'method': 'server_status', 'id': 1, 'params': null}));
    _channel.stream.listen(handleIncomingMessage);
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