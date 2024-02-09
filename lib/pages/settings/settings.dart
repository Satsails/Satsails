import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
    Provider.of<SettingsProvider>(context, listen: false).loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrencySection(),
            _buildDivider(),
            _buildSupportSection(),
            _buildDivider(),
            _buildFiatToggle(),
            _buildDivider(),
            _buildSeedSection(),
            _buildDivider(),
            _buildCountrySection(),
            _buildDivider(),
            _buildLanguageSection(),
            _buildDivider(),
            _buildProModeToggle(),
            _buildDivider(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySection() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return ListTile(
          leading: const Icon(Icons.account_balance_wallet),
          title: const Text('Currency'),
          subtitle: Text(settingsProvider.currency),
          onTap: () {
            settingsProvider.setCurrency(
              settingsProvider.currency == 'USD' ? 'USD' : 'USD',
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageSection() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          subtitle: Text(settingsProvider.language),
          onTap: () {
            settingsProvider.setLanguage(
              settingsProvider.language == 'EN' ? 'EN' : 'EN',
            );
          },
        );
      },
    );
  }

  Widget _buildCountrySection() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return ListTile(
          leading: const Icon(Icons.flag_circle),
          title: const Text('Country'),
          subtitle: Text(settingsProvider.country),
          onTap: () {
            settingsProvider.setCountry(
              settingsProvider.country == 'USA' ? 'USA' : 'USA',
            );
          },
        );
      },
    );
  }

  Widget _buildSeedSection() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return ListTile(
          leading: const Icon(Icons.currency_bitcoin),
          title: const Text('View Seed Words'),
          subtitle: Text('Write them down and keep them safe!'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.pushNamed(context, '/seed_words');
          },
        );
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

  Widget _buildFiatToggle() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return ListTile(
          leading: const Icon(Icons.attach_money_outlined),
          title: const Text('Fiat Currency Functionality'),
          onTap: () {
            settingsProvider.setFiatCapabilities(!settingsProvider.fiatCapabilities);
          },
          trailing: Switch(
            value: settingsProvider.fiatCapabilities,
            onChanged: (bool newValue) {
              settingsProvider.setFiatCapabilities(false);
            },
          ),
        );
      },
    );
  }

  Widget _buildProModeToggle() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return ListTile(
          leading: const Icon(Icons.paragliding_rounded),
          title: const Text('Enable Pro mode'),
          onTap: () {
            settingsProvider.setFiatCapabilities(!settingsProvider.proMode);
          },
          trailing: Switch(
            value: settingsProvider.proMode,
            onChanged: (bool newValue) {
              settingsProvider.setProMode(false);
            },
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[300],
    );
  }
}