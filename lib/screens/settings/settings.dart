import 'package:Satsails/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Settings'.i18n(ref)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrencySection(ref, context),
            _buildDivider(),
            _buildSupportSection(ref),
            _buildDivider(),
            _buildClaimBoltzTransactionsSection(context, ref),
            _buildDivider(),
            _buildSeedSection(context, ref),
            _buildDivider(),
            _buildLanguageSection(ref, context),
            _buildDivider(),
            _buildBtcUnitSection(ref, context),
            _buildDivider(),
            _builDeleteWalletSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySection(WidgetRef ref, BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return ListTile(
      leading: const Icon(Iconsax.dollar_circle_outline, color: Colors.orangeAccent),
      title: Text('Currency'.i18n(ref)),
      subtitle: Text(settings.currency),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Flag(Flags.brazil),
                  title: const Text('BRL'),
                  onTap: () {
                    settingsNotifier.setCurrency('BRL');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Flag(Flags.united_states_of_america),
                  title: const Text('USD'),
                  onTap: () {
                    settingsNotifier.setCurrency('USD');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Flag(Flags.european_union),
                  title: const Text('EUR'),
                  onTap: () {
                    settingsNotifier.setCurrency('EUR');
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageSection(WidgetRef ref, BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return ListTile(
      leading: const Icon(Icons.language, color: Colors.orangeAccent),
      title: Text('Language'.i18n(ref)),
      subtitle: Text(settings.language),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Flag(Flags.portugal),
                  title: Text('Portuguese'.i18n(ref)),
                  onTap: () {
                    settingsNotifier.setLanguage('pt');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Flag(Flags.united_states_of_america),
                  title: Text('English'.i18n(ref)),
                  onTap: () {
                    settingsNotifier.setLanguage('en');
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSeedSection(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.currency_bitcoin, color: Colors.orangeAccent),
      title: Text('View Seed Words'.i18n(ref)),
      subtitle: Text('Write them down and keep them safe!'.i18n(ref)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.orangeAccent),
      onTap: () {
        Navigator.pushNamed(context, '/seed_words');
      },
    );
  }

  Widget _buildSupportSection(WidgetRef ref) {
    final Uri url = Uri.parse('https://t.me/deepcodevalue');

    return ListTile(
      leading: const Icon(LineAwesome.telegram, color: Colors.orangeAccent),
      title:  Text('Help & Support & Bug reporting'.i18n(ref)),
      subtitle: Text('Chat with us on Telegram!'.i18n(ref)),
      onTap: () {
        launchUrl(url);
      },
    );
  }

  Widget _buildClaimBoltzTransactionsSection(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.flash_on, color: Colors.orangeAccent),
      title: Text('Claim Lightning Transactions'.i18n(ref)),
      onTap: () {
        Navigator.pushNamed(context, '/claim_boltz_transactions');
      },
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[300],
    );
  }

  Widget _builDeleteWalletSection(BuildContext context, WidgetRef ref) {
    final authModel = ref.read(authModelProvider);
    return ListTile(
      leading: const Icon(Icons.delete, color: Colors.orangeAccent),
      title: Text('Delete Wallet'.i18n(ref)),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm'.i18n(ref)),
              content:  Text('Are you sure you want to delete the wallet?'.i18n(ref)),
              actions: <Widget>[
                TextButton(
                  child:  Text('Cancel'.i18n(ref)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Yes'.i18n(ref)),
                  onPressed: () async {
                    await authModel.deleteAuthentication();
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBtcUnitSection(WidgetRef ref, BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return ListTile(
      leading: const Icon(Icons.add_chart, color: Colors.orangeAccent),
      title: Text('Bitcoin Unit'.i18n(ref)),
      subtitle: Text(settings.btcFormat),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Text('₿'),
                  title: const Text('BTC'),
                  onTap: () {
                    settingsNotifier.setBtcFormat('BTC');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Text('sats ₿'),
                  title: const Text('Satoshi'),
                  onTap: () {
                    settingsNotifier.setBtcFormat('sats');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Text('mBTC'),
                  title: const Text('mBTC'),
                  onTap: () {
                    settingsNotifier.setBtcFormat('mBTC');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Text('bits'),
                  title: const Text('bits'),
                  onTap: () {
                    settingsNotifier.setBtcFormat('bits');
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}