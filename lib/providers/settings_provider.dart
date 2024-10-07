import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/settings_model.dart';
import 'package:hive/hive.dart';

final initialSettingsProvider = FutureProvider<Settings>((ref) async {
      final languageIsPortuguese = Platform.localeName.contains('pt');
      final box = await Hive.openBox('settings');
      final currency = box.get('currency', defaultValue: 'USD');
      final language = box.get('language', defaultValue: languageIsPortuguese ? 'pt' : 'en');
      final btcFormat = box.get('btcFormat', defaultValue: 'BTC');
      final backup = box.get('backup', defaultValue: false);
      final bitcoinElectrumNode = box.get('bitcoinElectrumNode', defaultValue: 'electrum.bullbitcoin.com:50002');
      final liquidElectrumNode = box.get('liquidElectrumNode', defaultValue: 'les.bullbitcoin.com:995');
      final nodeType = box.get('nodeType', defaultValue: 'Bull Bitcoin');

      return Settings(currency: currency, language: language, btcFormat: btcFormat, online: true, backup: backup, bitcoinElectrumNode: bitcoinElectrumNode, liquidElectrumNode: liquidElectrumNode, nodeType: nodeType);
});

final settingsProvider = StateNotifierProvider<SettingsModel, Settings>((ref) {
      final initialSettings = ref.watch(initialSettingsProvider);
      final languageIsPortuguese = Platform.localeName.contains('pt');

      return SettingsModel(initialSettings.when(
            data: (settings) => settings,
            loading: () => Settings(currency: 'USD', language: languageIsPortuguese ? 'pt' : 'en', btcFormat: 'BTC', online: true, backup: false, bitcoinElectrumNode: 'electrum.bullbitcoin.com:50002', liquidElectrumNode: 'les.bullbitcoin.com:995', nodeType: 'Bull Bitcoin'),
            error: (Object error, StackTrace stackTrace) {
                  throw error;
            },
      ));
});