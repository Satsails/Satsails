import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:satsails/providers/auth_provider.dart';
import 'package:satsails/providers/settings_provider.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrencySection(ref, context),
            _buildDivider(),
            _buildSupportSection(),
            _buildDivider(),
            // only show this section before release
            // _buildInfoSection(context),
            // only show this section before release
            _buildDivider(),
            _buildSeedSection(context),
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
      leading: const Icon(Iconsax.dollar_circle_outline),
      title: const Text('Currency'),
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
      leading: const Icon(Icons.language),
      title: const Text('Language'),
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
                    title: const Text('Portuguese'),
                    onTap: () {
                      settingsNotifier.setLanguage('PT');
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Flag(Flags.united_states_of_america),
                    title: const Text('English'),
                    onTap: () {
                      settingsNotifier.setLanguage('EN');
                      Navigator.pop(context);
                    },
                  ),
                ]
              );
            },
          );
        },
    );
  }

  Widget _buildSeedSection(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.currency_bitcoin),
      title: const Text('View Seed Words'),
      subtitle: const Text('Write them down and keep them safe!'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.pushNamed(context, '/seed_words');
      },
    );
  }

  Widget _buildSupportSection() {
    return ListTile(
      leading: const Icon(LineAwesome.whatsapp),
      title: const Text('WhatsApp'),
      subtitle: const Text('Coming soon!'),
      onTap: () {
        null;
      },
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return ListTile(
      leading: const Icon(Clarity.info_circle_line),
      title: const Text('Information'),
      onTap: () {
        Navigator.pushNamed(context, '/info');
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
      leading: const Icon(Icons.delete),
      title: const Text('Delete Wallet'),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm'),
              content: const Text('Are you sure you want to delete the wallet?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Yes'),
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
      leading: Icon(Icons.add_chart),
      title: const Text('Bitcoin Unit'),
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