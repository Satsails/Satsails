import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails/models/settings_model.dart';
import 'package:hive/hive.dart';

final initialSettingsProvider = FutureProvider.autoDispose<Settings>((ref) async {
      final box = await Hive.openBox('settings');
      final currency = box.get('currency', defaultValue: 'USD');
      final language = box.get('language', defaultValue: 'EN');
      final btcFormat = box.get('btcFormat', defaultValue: 'BTC');

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