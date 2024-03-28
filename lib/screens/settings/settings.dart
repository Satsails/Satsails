import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails_wallet/providers/settings_provider.dart';
import 'package:satsails_wallet/models/mnemonic_model.dart';

class Settings extends ConsumerWidget {
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
            _buildCurrencySection(ref),
            _buildDivider(),
            _buildSupportSection(),
            _buildDivider(),
            _buildInfoSection(context),
            _buildDivider(),
            _buildSeedSection(context),
            _buildDivider(),
            _buildLanguageSection(ref),
            _buildDivider(),
            _builDeleteWalletSection(context)
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySection(WidgetRef ref) {
    final asyncSettings = ref.watch(settingsProvider);

    return asyncSettings.when(
      data: (settings) {
        return ListTile(
          leading: const Icon(Icons.account_balance_wallet),
          title: const Text('Currency'),
          subtitle: Text(settings.currency),
          onTap: () {
            settings.setCurrency('USD');
          },
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) => Text('Error: $error'),
    );
  }

  Widget _buildLanguageSection(WidgetRef ref) {
    final asyncSettings = ref.watch(settingsProvider);

    return asyncSettings.when(
      data: (settings) {
        return ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          subtitle: Text(settings.language),
          onTap: () {
            settings.setLanguage('EN');
          },
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) => Text('Error: $error'),
    );
  }

  Widget _buildSeedSection(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.currency_bitcoin),
      title: const Text('View Seed Words'),
      subtitle: Text('Write them down and keep them safe!'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.pushNamed(context, '/seed_words');
      },
    );
  }

  Widget _buildSupportSection() {
    return ListTile(
      leading: const Icon(Icons.headset_mic),
      title: const Text('Support'),
      onTap: () {
        // Handle support section tap
      },
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info),
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

  Widget _builDeleteWalletSection(BuildContext context) {
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
                  onPressed: () {
                    MnemonicModel().deleteMnemonic();
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
}
