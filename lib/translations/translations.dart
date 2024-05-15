import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static var _t = Translations.byText('en_us') +
      {
        "en_us": "View Accounts",
        "pt_br": "Ver Contas",
      };

  String i18n(WidgetRef ref) {
    final currentLanguage = ref.read(settingsProvider).language;
    return localize(this, _t, locale: currentLanguage);
  }
}