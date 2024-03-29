import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends StateNotifier<Settings> {
  SettingsModel(Settings state) : super(state);

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
}

class Settings {
  final String currency;
  final String language;

  Settings({
    required this.currency,
    required this.language,
  });

  Settings copyWith({
    String? currency,
    String? language,
  }) {
    return Settings(
      currency: currency ?? this.currency,
      language: language ?? this.language,
    );
  }
}