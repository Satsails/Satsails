import 'package:flutter/foundation.dart';

class BalanceProvider extends ChangeNotifier {
  Map<String, dynamic> _balance = {};

  Map<String, dynamic> get balance => _balance;

  void setBalance(Map<String, dynamic> newBalance) {
    _balance = newBalance;
    notifyListeners();
  }
}