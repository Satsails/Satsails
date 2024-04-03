import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final initialSettingsProvider = FutureProvider.autoDispose<Settings>((ref) async {
      final prefs = await SharedPreferences.getInstance();
      final currency = prefs.getString('currency') ?? 'USD';
      final language = prefs.getString('language') ?? 'EN';
      final btcFormat = prefs.getString('btcFormat') ?? 'BTC';

      return Settings(currency: currency, language: language, btcFormat: btcFormat);
});

final settingsProvider = StateNotifierProvider.autoDispose<SettingsModel, Settings>((ref) {
      final initialSettings = ref.watch(initialSettingsProvider);

      return SettingsModel(initialSettings.when(
            data: (settings) => settings,
            loading: () => Settings(currency: 'USD', language: 'EN', btcFormat: 'BTC'),
            error: (Object error, StackTrace stackTrace) {
                  throw error;
            },
      ));
});

final onlineProvider = StateProvider<bool>((ref) => false);