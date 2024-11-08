import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class CoisosPushNotifications {
  late WebSocketChannel _channel;
  final _paymentController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get paymentStream => _paymentController.stream;

  // Connect method for login using the provided token
  void connect(String token) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('wss://coinos.io/ws'));
      // Send login data with token as soon as the connection is established
      _channel.sink.add(json.encode({
        'type': 'login',
        'data': token,
      }));

      _channel.stream.listen(
        handleIncomingMessage,
        onError: (error) {
          throw Exception('Error connecting to WebSocket: $error');
        },
        cancelOnError: true,
      );
    } catch (e) {
      throw Exception('Error connecting to WebSocket: $e');
    }
  }

  // Handle incoming WebSocket messages
  void handleIncomingMessage(dynamic message) {
    var decodedMessage = json.decode(message);

    if (decodedMessage['type'] == 'payment') {
      handlePaymentMessage(decodedMessage['data']);
    }
  }

  // Method to handle payment messages
  void handlePaymentMessage(Map<String, dynamic> paymentData) {
    _paymentController.add(paymentData);
  }

  // Close all resources
  void close() {
    _channel.sink.close();
    _paymentController.close();
  }
}
