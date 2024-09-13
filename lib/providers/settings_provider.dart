import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/settings_model.dart';
import 'package:hive/hive.dart';

final initialSettingsProvider = FutureProvider.autoDispose<Settings>((ref) async {
      final languageIsPortuguese = Platform.localeName.contains('pt');
      final box = await Hive.openBox('settings');
      final currency = box.get('currency', defaultValue: 'USD');
      final language = box.get('language', defaultValue: languageIsPortuguese ? 'pt' : 'en');
      final btcFormat = box.get('btcFormat', defaultValue: 'BTC');
      final backup = box.get('backup', defaultValue: false);

      return Settings(currency: currency, language: language, btcFormat: btcFormat, online: true, backup: backup);
});

final settingsProvider = StateNotifierProvider.autoDispose<SettingsModel, Settings>((ref) {
      final initialSettings = ref.watch(initialSettingsProvider);
      final languageIsPortuguese = Platform.localeName.contains('pt');

      return SettingsModel(initialSettings.when(
            data: (settings) => settings,
            loading: () => Settings(currency: 'USD', language: languageIsPortuguese ? 'pt' : 'en', btcFormat: 'BTC', online: true, backup: false),
            error: (Object error, StackTrace stackTrace) {
                  throw error;
            },
      ));
});

final backgroundSyncInProgressProvider = StateProvider.autoDispose<bool>((ref) => false);