import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/models/settings_model.dart';
import 'package:hive/hive.dart';

final initialSettingsProvider = FutureProvider<Settings>((ref) async {
      final languageIsPortuguese = Platform.localeName.contains('pt');
      final box = await Hive.openBox('settings');

      final currency = box.get('currency', defaultValue: 'USD');
      final language =
      box.get('language', defaultValue: languageIsPortuguese ? 'pt' : 'en');
      final btcFormat = box.get('btcFormat', defaultValue: 'BTC');
      final backup = box.get('backup', defaultValue: false);
      final balanceVisible = box.get('balanceVisible', defaultValue: false);
      final bitcoinElectrumNode = box.get('bitcoinElectrumNode',
          defaultValue: 'bitcoin-mainnet.blockstream.info:50002');
      final liquidElectrumNode = box.get('liquidElectrumNode',
          defaultValue: 'elements-mainnet.blockstream.info:50002');
      final nodeType = box.get('nodeType', defaultValue: 'Blockstream');
      final biometricsEnabled = box.get('biometricsEnabled', defaultValue: true);
      final reviewDone = box.get('reviewDone', defaultValue: false);

      return Settings(
            currency: currency,
            language: language,
            btcFormat: btcFormat,
            online: true,
            backup: backup,
            bitcoinElectrumNode: bitcoinElectrumNode,
            liquidElectrumNode: liquidElectrumNode,
            nodeType: nodeType,
            balanceVisible: balanceVisible,
            biometricsEnabled: biometricsEnabled,
            reviewDone: reviewDone,
      );
});

// The main provider now uses the FutureProvider to get its initial state.
final settingsProvider = StateNotifierProvider<SettingsModel, Settings>((ref) {
      final initialSettings = ref.watch(initialSettingsProvider);

      return SettingsModel(
            initialSettings.when(
                  data: (settings) => settings,
                  // Provide default settings for loading and error states.
                  loading: () {
                        final languageIsPortuguese = Platform.localeName.contains('pt');
                        return Settings(
                              currency: 'USD',
                              language: languageIsPortuguese ? 'pt' : 'en',
                              btcFormat: 'BTC',
                              online: true,
                              backup: false,
                              bitcoinElectrumNode: 'bitcoin-mainnet.blockstream.info:50002',
                              liquidElectrumNode: 'elements-mainnet.blockstream.info:50002',
                              nodeType: 'Blockstream',
                              balanceVisible: false,
                              biometricsEnabled: true,
                              reviewDone: false,
                        );
                  },
                  error: (err, stack) {
                        // In case of an error, also return default settings.
                        final languageIsPortuguese = Platform.localeName.contains('pt');
                        return Settings(
                              currency: 'USD',
                              language: languageIsPortuguese ? 'pt' : 'en',
                              btcFormat: 'BTC',
                              online: true,
                              backup: false,
                              bitcoinElectrumNode: 'bitcoin-mainnet.blockstream.info:50002',
                              liquidElectrumNode: 'elements-mainnet.blockstream.info:50002',
                              nodeType: 'Blockstream',
                              balanceVisible: false,
                              biometricsEnabled: true,
                              reviewDone: false,
                        );
                  },
            ),
      );
});
