import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  String currency;
  String language;

  SettingsModel({
    required this.currency,
    required this.language,
  });

  Future<void> setCurrency(String newCurrency) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('currency', newCurrency);
    currency = newCurrency;
    notifyListeners();
  }

  Future<void> setLanguage(String newLanguage) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('language', newLanguage);
    language = newLanguage;
    notifyListeners();
  }
}
