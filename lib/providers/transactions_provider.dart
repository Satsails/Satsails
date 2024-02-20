import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void saveTransactionData(Map<String, dynamic> transactionData) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String transactionKey = "transaction_${transactionData['order_id']}";
  String transactionJson = jsonEncode(transactionData);
  prefs.setString(transactionKey, transactionJson);
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
