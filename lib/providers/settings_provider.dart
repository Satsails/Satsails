import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  String _currency = 'USD';
  String _country = 'USA';
  String _language = 'EN';
  bool _fiatCapabilities = false;

  String get currency => _currency;
  String get country => _country;
  String get language => _language;
  bool get fiatCapabilities => _fiatCapabilities;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _currency = prefs.getString('currency') ?? 'USD';
    _country = prefs.getString('country') ?? 'United States';
    _language = prefs.getString('language') ?? 'English';
    _fiatCapabilities = prefs.getBool('fiatCapabilities') ?? false;
    notifyListeners();
  }

  Future<void> setCurrency(String newCurrency) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('currency', newCurrency);
    _currency = newCurrency;
    notifyListeners();
  }

  Future<void> setCountry(String newCountry) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('country', newCountry);
    _country = newCountry;
    notifyListeners();
  }

  Future<void> setLanguage(String newLanguage) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('language', newLanguage);
    _language = newLanguage;
    notifyListeners();
  }

  Future<void> setFiatCapabilities(bool newFiatCapabilities) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('fiatCapabilities', newFiatCapabilities);
    _fiatCapabilities = newFiatCapabilities;
    notifyListeners();
  }
}
