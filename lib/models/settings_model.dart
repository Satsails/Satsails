import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class SettingsModel extends StateNotifier<Settings> {
  SettingsModel(super.state);

  Future<void> setCurrency(String newCurrency) async {
    final box = await Hive.openBox('settings');
    box.put('currency', newCurrency);
    state = state.copyWith(currency: newCurrency);
  }

  Future<void> setLanguage(String newLanguage) async {
    final box = await Hive.openBox('settings');
    box.put('language', newLanguage);
    state = state.copyWith(language: newLanguage);
  }

  Future<void> setBtcFormat(String newBtcFormat) async {
    final box = await Hive.openBox('settings');
    box.put('btcFormat', newBtcFormat);
    state = state.copyWith(btcFormat: newBtcFormat);
  }

  void setOnline(bool onlineStatus) {
    state = state.copyWith(online: onlineStatus);
  }

  Future<void> setBackup(bool backupStatus) async {
    final box = await Hive.openBox('settings');
    box.put('backup', backupStatus);
    state = state.copyWith(backup: backupStatus);
  }
}

class Settings {
  final String currency;
  final String language;
  late final String btcFormat;
  late bool online;
  final bool backup;

  Settings({
    required this.currency,
    required this.language,
    required String btcFormat,
    required this.online,
    required this.backup
  }) : btcFormat = (['BTC', 'mBTC', 'bits', 'sats'].contains(btcFormat)) ? btcFormat : throw ArgumentError('Invalid btcFormat'),
        super();

  Settings copyWith({
    String? currency,
    String? language,
    String? btcFormat,
    bool? online,
    bool? backup
  }) {
    return Settings(
      currency: currency ?? this.currency,
      language: language ?? this.language,
      btcFormat: btcFormat ?? this.btcFormat,
      online: online ?? this.online,
      backup: backup ?? this.backup
    );
  }
}