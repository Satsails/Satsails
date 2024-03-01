import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';

class BoltzStatus {
  late IOWebSocketChannel _channel;
  final _messageController = StreamController<dynamic>.broadcast();

  Stream<dynamic> get messageStream => _messageController.stream;

  void connect({
    required List args,
  }) {
    _channel = IOWebSocketChannel.connect('wss://api.boltz.exchange/v2/ws');
    peg(op: "subscribe", channel: "swap.update", args: args);

    _channel.stream.listen(handleIncomingMessage);
  }

  void peg({
    required String op,
    required String channel,
    required List args,
  }) {
    _channel.sink.add(json.encode({
      'op': op,
      'channel': channel,
      'args': args,
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