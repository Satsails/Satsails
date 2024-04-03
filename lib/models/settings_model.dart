import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends StateNotifier<Settings> {
  SettingsModel(super.state);

  Future<void> setCurrency(String newCurrency) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('currency', newCurrency);
    state = state.copyWith(currency: newCurrency);
  }

  Future<void> setLanguage(String newLanguage) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('language', newLanguage);
    state = state.copyWith(language: newLanguage);
  }

  Future<void> setBtcFormat(String newBtcFormat) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('btcFormat', newBtcFormat);
    state = state.copyWith(btcFormat: newBtcFormat);
  }
}

class Settings {
  final String currency;
  final String language;
  late final String btcFormat;

  Settings({
    required this.currency,
    required this.language,
    required String btcFormat,
  }) : btcFormat = (['BTC', 'mBTC', 'bits', 'sats'].contains(btcFormat)) ? btcFormat : throw ArgumentError('Invalid btcFormat'),
        super();

  Settings copyWith({
    String? currency,
    String? language,
    String? btcFormat,
  }) {
    return Settings(
      currency: currency ?? this.currency,
      language: language ?? this.language,
      btcFormat: btcFormat ?? this.btcFormat,
    );
  }
}