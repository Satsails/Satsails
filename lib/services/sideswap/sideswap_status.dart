import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class SideswapServerStatus extends ChangeNotifier{
  late IOWebSocketChannel _channel;
  final _messageController = StreamController<dynamic>.broadcast();

  Stream<dynamic> get messageStream => _messageController.stream;

  void connect() {
    _channel = IOWebSocketChannel.connect('wss://api.sideswap.io/json-rpc-ws');
    _channel.stream.listen(handleIncomingMessage);
  }

  void handleIncomingMessage(dynamic message) {
    if (message is String) {
      var decodedMessage = json.decode(message);
      _messageController.add(decodedMessage);
      notifyListeners();
    }
  }

  void close() {
    _channel.sink.close();
    _messageController.close();
  }
}