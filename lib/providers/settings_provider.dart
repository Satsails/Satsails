import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/settings_model.dart';
import 'package:hive/hive.dart';

final initialSettingsProvider = FutureProvider.autoDispose<Settings>((ref) async {
      final box = await Hive.openBox('settings');
      final currency = box.get('currency', defaultValue: 'USD');
      final language = box.get('language', defaultValue: 'en');
      final btcFormat = box.get('btcFormat', defaultValue: 'BTC');

      return Settings(currency: currency, language: language, btcFormat: btcFormat, online: true);
});

final settingsProvider = StateNotifierProvider.autoDispose<SettingsModel, Settings>((ref) {
      final initialSettings = ref.watch(initialSettingsProvider);

      return SettingsModel(initialSettings.when(
            data: (settings) => settings,
            loading: () => Settings(currency: 'USD', language: 'en', btcFormat: 'BTC', online: true),
            error: (Object error, StackTrace stackTrace) {
                  throw error;
            },
      ));
});