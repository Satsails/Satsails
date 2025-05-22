import 'dart:async';
import 'dart:convert';
import 'package:Satsails/models/sideswap/sideswap_quote_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Sideswap {
  late WebSocketChannel _channel;
  final _loginController = StreamController<Map<String, dynamic>>.broadcast();
  final _statusController = StreamController<Map<String, dynamic>>.broadcast();
  final _pegController = StreamController<Map<String, dynamic>>.broadcast();
  final _pegStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final _listMarketsController = StreamController<Map<String, dynamic>>.broadcast();
  final _quoteController = StreamController<Map<String, dynamic>>.broadcast();
  final _quotePsetController = StreamController<Map<String, dynamic>>.broadcast();
  final _signedSwapController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get loginStream => _loginController.stream;
  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;
  Stream<Map<String, dynamic>> get pegStream => _pegController.stream;
  Stream<Map<String, dynamic>> get pegStatusStream => _pegStatusController.stream;
  Stream<Map<String, dynamic>> get listMarketsStream => _listMarketsController.stream;
  Stream<Map<String, dynamic>> get quoteStream => _quoteController.stream;
  Stream<Map<String, dynamic>> get quotePsetStream => _quotePsetController.stream;
  Stream<Map<String, dynamic>> get signedSwapStream => _signedSwapController.stream;

  Future<void> connect() async {
    const maxAttempts = 3;
    const delayBetweenAttempts = Duration(seconds: 1);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        _channel = WebSocketChannel.connect(Uri.parse('wss://api.sideswap.io/json-rpc-ws'));
        _channel.stream.listen(
          handleIncomingMessage,
          onError: (error) {
            throw Exception('Error connecting to WebSocket: $error');
          },
          cancelOnError: true,
        );
        print('Connected successfully on attempt $attempt');
        return; // Exit the function on successful connection
      } catch (e) {
        print('Attempt $attempt failed: $e');
        if (attempt < maxAttempts - 1) {
          await Future.delayed(delayBetweenAttempts); // Wait before next attempt
        }
      }
    }

    // If all attempts fail, throw an exception
    throw Exception('Failed to connect after $maxAttempts attempts');
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
      case 'market':
        if (decodedMessage["result"]?['list_markets'] != null) {
          _listMarketsController.add(decodedMessage);
        } else if (decodedMessage['params']?['quote'] != null) {
          _quoteController.add(decodedMessage);
        } else if (decodedMessage['result']?['start_quotes'] != null) {
          _quoteController.add(decodedMessage);
        } else if (decodedMessage['result']?['get_quote'] != null) {
          _quotePsetController.add(decodedMessage);
        } else if (decodedMessage['result']?['taker_sign'] != null) {
          _signedSwapController.add(decodedMessage);
        }
        break;
      default:
        if (decodedMessage['error']?['message'] == 'already registered') {
          break;
        }
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
    int? blocks,
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

  void listMarkets() {
    _channel.sink.add(json.encode({
      'id': 1,
      'method': 'market',
      'params': {
        'list_markets': {}
      }
    }));
  }

  void startQuotes({
    required String baseAsset,
    required String quoteAsset,
    required String assetType,
    required String tradeDir,
    required int amount,
    required String receiveAddress,
    required String changeAddress,
    required List<Utxo> utxos,
  }) {
    _channel.sink.add(json.encode({
      'id': 1,
      'method': 'market',
      'params': {
        'start_quotes': {
          'asset_pair': {
            'base': baseAsset,
            'quote': quoteAsset,
          },
          'asset_type': assetType,
          'trade_dir': tradeDir,
          'amount': amount,
          'utxos': utxos.map((utxo) => utxo.toJson()).toList(),
          'receive_address': receiveAddress,
          'change_address': changeAddress,
        }
      }
    }));
  }

  void getQuotePset({required int quoteId}) {
    _channel.sink.add(json.encode({
      'id': 1,
      'method': 'market',
      'params': {
        'get_quote': {
          'quote_id': quoteId,
        }
      }
    }));
  }

  void signQuotePset({required int quoteId, required String pset}) {
    _channel.sink.add(json.encode({
      'id': 1,
      'method': 'market',
      'params': {
        'taker_sign': {
          'quote_id': quoteId,
          'pset': pset,
        }
      }
    }));
  }

  void close() {
    _channel.sink.close();
    _loginController.close();
    _statusController.close();
    _pegController.close();
    _pegStatusController.close();
    _listMarketsController.close();
    _quoteController.close();
    _quotePsetController.close();
    _signedSwapController.close();
  }
}