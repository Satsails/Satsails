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

  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  final Duration _heartbeatInterval = Duration(seconds: 3); // Adjust as needed
  final Duration _reconnectDelay = Duration(seconds: 5);

  CoinosPushNotifications(this._token);

  /// Establishes the WebSocket connection and initializes heartbeat.
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
          _isConnected = false;
          _scheduleReconnect();
        },
        onDone: () {
          _isConnected = false;
          _scheduleReconnect();
        },
        cancelOnError: true,
      );

      _isConnected = true;
      _isConnecting = false;

      // Start the heartbeat timer
      _startHeartbeatTimer();
    } catch (e) {
      _isConnecting = false;
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  /// Handles incoming WebSocket messages.
  void _handleIncomingMessage(dynamic message) {
    var decodedMessage = json.decode(message);

    if (decodedMessage['type'] == 'payment') {
      _handlePaymentMessage(decodedMessage['data']);
    } else {
    }
  }

  /// Adds payment data to the payment stream.
  void _handlePaymentMessage(Map<String, dynamic> paymentData) {
    _paymentController.add(paymentData);
  }

  /// Starts the periodic heartbeat timer.
  void _startHeartbeatTimer() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected) {
        _sendHeartbeat();
      } else {
        timer.cancel();
      }
    });
  }

  /// Sends a heartbeat message with the token.
  void _sendHeartbeat() {
    try {
      _channel?.sink.add(json.encode({
        'type': 'heartbeat',
        'data': _token,
      }));
    } catch (e) {
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  /// Schedules a reconnection attempt after a delay.
  void _scheduleReconnect() {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;

    _reconnectTimer = Timer(_reconnectDelay, () {
      if (!_isConnected) {
        connect();
      }
    });
  }

  /// Closes the WebSocket connection and all timers.
  void close() {
    _isConnected = false;
    _isConnecting = false;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _paymentController.close();
  }
}
