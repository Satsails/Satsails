import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails_wallet/models/settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = FutureProvider<SettingsModel>((ref) async {
      final prefs = await SharedPreferences.getInstance();
      final currency = prefs.getString('currency');
      final language = prefs.getString('language');

      return SettingsModel(
            currency: currency ?? 'USD',
            language: language ?? 'EN',
      );
});
