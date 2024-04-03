import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final initialSettingsProvider = FutureProvider.autoDispose<Settings>((ref) async {
      final prefs = await SharedPreferences.getInstance();
      final currency = prefs.getString('currency') ?? 'USD';
      final language = prefs.getString('language') ?? 'EN';

      return Settings(currency: currency, language: language);
});

final settingsProvider = StateNotifierProvider.autoDispose<SettingsModel, Settings>((ref) {
      final initialSettings = ref.watch(initialSettingsProvider);

      return SettingsModel(initialSettings.when(
            data: (settings) => settings,
            loading: () => Settings(currency: 'USD', language: 'EN'),
            error: (Object error, StackTrace stackTrace) {
                  throw error;
            },
      ));
});