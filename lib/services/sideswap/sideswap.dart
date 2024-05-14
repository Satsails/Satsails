import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class Sideswap {
  late WebSocketChannel _channel;
  final _loginController = StreamController<Map<String, dynamic>>.broadcast();
  final _statusController = StreamController<Map<String, dynamic>>.broadcast();
  final _pegController = StreamController<Map<String, dynamic>>.broadcast();
  final _pegStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final _priceController = StreamController<Map<String, dynamic>>.broadcast();
  final _unsubscribePriceController = StreamController<Map<String, dynamic>>.broadcast();
  final _exchangeController = StreamController<Map<String, dynamic>>.broadcast();
  final _exchangeDoneController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get loginStream => _loginController.stream;
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;
  Stream<Map<String, dynamic>> get pegStream => _pegController.stream;
  Stream<Map<String, dynamic>> get pegStatusStream => _pegStatusController.stream;
  Stream<Map<String, dynamic>> get priceStream => _priceController.stream;
  Stream<Map<String, dynamic>> get exchangeStream => _exchangeController.stream;
  Stream<Map<String, dynamic>> get unsubscribePriceStream => _unsubscribePriceController.stream;
  Stream<Map<String, dynamic>> get exchangeDoneStream => _exchangeDoneController.stream;

  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('wss://api.sideswap.io/json-rpc-ws'));
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

  void handleIncomingMessage(dynamic message) {
    var decodedMessage = json.decode(message);
    switch (decodedMessage['method']) {
      case 'login_client':
        _loginController.add(decodedMessage);
        break;
      case 'server_status':
        _statusController.add(decodedMessage);
        break;
      case 'peg':
        _pegController.add(decodedMessage);
        break;
      case 'peg_status':
        _pegStatusController.add(decodedMessage);
        break;
      case 'update_price_stream':
        _priceController.add(decodedMessage);
        break;
      case 'subscribe_price_stream':
        _priceController.add(decodedMessage);
        break;
      case 'unsubscribe_price_stream':
        _unsubscribePriceController.add(decodedMessage);
        break;
      case 'start_swap_web':
        _exchangeController.add(decodedMessage);
        break;
      case 'swap_done':
        _exchangeDoneController.add(decodedMessage);
        break;
      default:
        throw Exception('Unknown method: ${decodedMessage['method']}');
    }
  }

  void login() {
    _channel.sink.add(json.encode({
      'id': 1,
      'method': 'login_client',
      'params': {
        "api_key": "d0f9f22c7eab0f94d66846708025d75fe0b7d63aed805b400ba0c2c3783c1950",
        "user_agent": "satsails",
        "version": "1.0"
      }
    }));
  }

  void status() {
    _channel.sink.add(json.encode({
      'id': 1,
      'method': 'server_status',
      'params': null,
    }));
  }

  void peg({
    required bool? peg_in,
    required String? recv_addr,
    int? blocks
  }) {
    _channel.sink.add(json.encode({
      'id': 1,
      'method': 'peg',
      'params': {
        'blocks': blocks,
        'peg_in': peg_in,
        'recv_addr': recv_addr,
      }
    }));
  }

  void pegStatus({
    required String orderId,
    required bool? pegIn,
  }) {
    _channel.sink.add(json.encode({
      'id': 1,
      'method': 'peg_status',
      'params': {
        'peg_in': pegIn,
        'order_id': orderId,
      }
    }));
  }

  void streamPrices({
    required String asset,
    required bool? sendBitcoins,
    int? sendAmount} ) {
    _channel.sink.add(json.encode({
      'id': 1,
      'method': 'subscribe_price_stream',
      'params': {
        'asset': asset,
        'send_bitcoins': sendBitcoins,
        'send_amount': sendAmount,
      }
    }));
  }

  void unsubscribePrice({required String asset}) {
    _channel.sink.add(json.encode({
      'id': 1,
      'method': 'unsubscribe_price_stream',
      'params': {
        'asset': asset,
      }
    }));
  }

  void startExchange({
    required String asset,
    required bool sendBitcoins,
    required double price,
    required int sendAmount,
    required int recvAmount,
  }) {
    _channel.sink.add(json.encode({
      'id': 1,
      'method': 'start_swap_web',
      'params': {
        'asset': asset,
        'send_bitcoins': sendBitcoins,
        'price': price,
        'send_amount': sendAmount,
        'recv_amount': recvAmount,
      },
    }));
  }

  void close() {
    _channel.sink.close();
    _loginController.close();
    _statusController.close();
    _pegController.close();
    _pegStatusController.close();
    _priceController.close();
    _exchangeController.close();
    _unsubscribePriceController.close();
    _exchangeDoneController.close();
  }
}