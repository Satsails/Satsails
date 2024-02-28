import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class TransactionNotifier extends ChangeNotifier {
  Map<String, dynamic> _allTransactions = {};
  Map<String, dynamic> _allExchanges = {};

  Map<String, dynamic> get allTransactions => _allTransactions;
  Map<String, dynamic> get allExchanges => _allExchanges;

  void saveTransactionData(Map<String, dynamic> transactionData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String transactionKey = "transaction_${transactionData['order_id']}";
    String transactionJson = jsonEncode(transactionData);
    prefs.setString(transactionKey, transactionJson);

    _allTransactions[transactionKey] = transactionData;
    notifyListeners();
  }

  void saveExchangeData(Map<String, dynamic> exchangeData) async {
    if (exchangeData['method'] == "swap_done") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String exchangeKey = "exchange_${exchangeData['params']['send_asset']}";
      String exchangeJson = jsonEncode(exchangeData);
      prefs.setString(exchangeKey, exchangeJson);

      _allExchanges[exchangeKey] = exchangeData;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getExchangeData(String assetId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String exchangeKey = "exchange_$assetId";
    String? exchangeJson = prefs.getString(exchangeKey);

    if (exchangeJson != null) {
      Map<String, dynamic> exchangeData = jsonDecode(exchangeJson);
      return exchangeData;
    } else {
      return {};
    }
  }

  Future<Map<String, dynamic>> getTransactionData(String orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String transactionKey = "transaction_$orderId";
    String? transactionJson = prefs.getString(transactionKey);

    if (transactionJson != null) {
      Map<String, dynamic> transactionData = jsonDecode(transactionJson);
      return transactionData;
    } else {
      return {};
    }
  }

  Future<Map<String, dynamic>> getAllTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> allTransactions = {};

    for (String key in prefs.getKeys()) {
      if (key.contains("transaction_")) {
        String? transactionJson = prefs.getString(key);
        if (transactionJson != null) {
          Map<String, dynamic> transactionData = jsonDecode(transactionJson);
          allTransactions[key] = transactionData;
        }
      }
    }

    return allTransactions;
  }

  Future<Map<String, dynamic>> getAllExchanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> allExchanges = {};

    for (String key in prefs.getKeys()) {
      if (key.contains("exchange_")) {
        String? exchangeJson = prefs.getString(key);
        if (exchangeJson != null) {
          Map<String, dynamic> exchangeData = jsonDecode(exchangeJson);
          allExchanges[key] = exchangeData;
        }
      }
    }

    return allExchanges;
  }
}
