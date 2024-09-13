import 'dart:async';
import 'dart:convert';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class Satsails {
  late PusherChannelsFlutter pusher;
  final _pixController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get loginStream => _pixController.stream;

  Future<void> connect(String paymentId) async {
    try {
      pusher = PusherChannelsFlutter.getInstance();

      await pusher.init(
        apiKey: 'd72ad57ca9898ced8710',
        cluster: 'sa1',
      );

      await pusher.connect();

      await pusher.subscribe(
        channelName: 'transaction_update_channel_$paymentId',
        onEvent: (event) {
          handleIncomingMessage(event);
        },
      );

    } catch (e) {
      throw Exception('Error connecting to Pusher: $e');
    }
  }

  void handleIncomingMessage(PusherEvent event) {
    var decodedMessage = json.decode(event.data);
    _pixController.add(decodedMessage);
  }

  void dispose(String paymentId) {
    _pixController.close();
    pusher.unsubscribe(channelName: 'transaction_update_channel_$paymentId');
    pusher.disconnect();
  }
}
