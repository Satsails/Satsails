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
      final balanceVisible = box.get('balanceVisible', defaultValue: false);
      final bitcoinElectrumNode = box.get('bitcoinElectrumNode', defaultValue: 'blockstream.info:700');
      final liquidElectrumNode = box.get('liquidElectrumNode', defaultValue: 'blockstream.info:995');
      final nodeType = box.get('nodeType', defaultValue: 'Blockstream');

      return Settings(currency: currency, language: language, btcFormat: btcFormat, online: true, backup: backup, bitcoinElectrumNode: bitcoinElectrumNode, liquidElectrumNode: liquidElectrumNode, nodeType: nodeType, balanceVisible: balanceVisible);
});

final settingsProvider = StateNotifierProvider<SettingsModel, Settings>((ref) {
      final initialSettings = ref.watch(initialSettingsProvider);
      final languageIsPortuguese = Platform.localeName.contains('pt');

      return SettingsModel(initialSettings.when(
            data: (settings) => settings,
            loading: () => Settings(currency: 'USD', language: languageIsPortuguese ? 'pt' : 'en', btcFormat: 'BTC', online: true, backup: false, bitcoinElectrumNode: 'blockstream.info:700', liquidElectrumNode: 'blockstream.info:995', nodeType: 'Blockstream', balanceVisible: false),
            error: (Object error, StackTrace stackTrace) {
                  throw error;
            },
      ));
});