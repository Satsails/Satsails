import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountsProvider extends ChangeNotifier {
  bool _autoBalancing = true;

  bool get autoBalancing => _autoBalancing;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _autoBalancing = prefs.getBool('autoBalancingCapabilities') ?? true;
    notifyListeners();
  }

  Future<void> setAutoBalancingCapabilities(bool newAutoBalancingCapablilities) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('autoBalancingCapabilities', newAutoBalancingCapablilities);
    _autoBalancing = newAutoBalancingCapablilities;
    notifyListeners();
  }
}
