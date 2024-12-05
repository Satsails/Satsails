import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class CoinosPushNotifications {
  WebSocketChannel? _channel;
  final _paymentController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get paymentStream => _paymentController.stream;

  final String _token;
  bool _isConnecting = false;
  bool _isConnected = false;

  Timer? _pingTimer;
  Timer? _pongTimeoutTimer;
  Timer? _reconnectTimer;

  final Duration _pingInterval = Duration(seconds: 30); // Adjust as needed
  final Duration _pongTimeout = Duration(seconds: 10);  // Adjust as needed
  final Duration _reconnectDelay = Duration(seconds: 5);

  CoinosPushNotifications(this._token);

  void connect() {
    if (_isConnecting || _isConnected) return;

    _isConnecting = true;
    try {
      _channel = WebSocketChannel.connect(Uri.parse('wss://coinos.io/ws'));

      // Send login data with token as soon as the connection is established
      _channel!.sink.add(json.encode({
        'type': 'login',
        'data': _token,
      }));

      _channel!.stream.listen(
        _handleIncomingMessage,
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
          _scheduleReconnect();
        },
        onDone: () {
          print('WebSocket connection closed');
          _isConnected = false;
          _scheduleReconnect();
        },
        cancelOnError: true,
      );

      _isConnected = true;
      _isConnecting = false;

      // Start the ping timer
      _startPingTimer();

    } catch (e) {
      print('Error connecting to WebSocket: $e');
      _isConnecting = false;
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _handleIncomingMessage(dynamic message) {
    var decodedMessage = json.decode(message);

    if (decodedMessage['type'] == 'pong') {
      // Received pong response
      _pongTimeoutTimer?.cancel();
    } else if (decodedMessage['type'] == 'payment') {
      _handlePaymentMessage(decodedMessage['data']);
    } else {
      // Handle other message types if necessary
    }
  }

  void _handlePaymentMessage(Map<String, dynamic> paymentData) {
    _paymentController.add(paymentData);
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (timer) {
      if (_isConnected) {
        _sendPing();
        _startPongTimeout();
      } else {
        timer.cancel();
      }
    });
  }

  void _sendPing() {
    try {
      _channel?.sink.add(json.encode({
        'type': 'ping',
      }));
    } catch (e) {
      print('Error sending ping: $e');
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _startPongTimeout() {
    _pongTimeoutTimer?.cancel();
    _pongTimeoutTimer = Timer(_pongTimeout, () {
      print('Pong timeout, reconnecting...');
      _isConnected = false;
      _channel?.sink.close();
      _scheduleReconnect();
    });
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;

    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_isConnected) {
        print('Attempting to reconnect...');
        connect();
      }
    });
  }

  void close() {
    _isConnected = false;
    _isConnecting = false;
    _pingTimer?.cancel();
    _pongTimeoutTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _paymentController.close();
  }
}
