import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/accounts_provider.dart';

class Accounts extends StatelessWidget {
  final Map<String, double> balances;

  const Accounts({Key? key, required this.balances}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Main',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            _buildAccountCard(
              title: 'All BTC',
              value: balances['totalBtcOnly']?.toString() ?? '0.0',
              subtitle: balances['totalBtcOnlyInUsd']?.toString() ?? '0.0',
            ),
            const SizedBox(height: 12.0),
            _buildAccountCard(
              title: 'USD',
              value: balances['usdOnly']?.toString() ?? '0.0',
            ),
            const SizedBox(height: 12.0),
            _buildDivider(),
            const SizedBox(height: 12.0),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'BTC Layers',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            _buildAccountCard(
              title: 'BTC',
              value: balances['btc']?.toString() ?? '0.0',
              subtitle: balances['btcInUsd']?.toString() ?? '0.0',
            ),
            const SizedBox(height: 12.0),
            _buildAccountCard(
              title: 'L-BTC',
              value: balances['l-btc']?.toString() ?? '0.0',
              subtitle: balances['l-btcInUsd']?.toString() ?? '0.0',
            ),
            const SizedBox(height: 12.0),
            _buildAccountCard(
              title: 'Lightening Network',
              subtitle: 'Coming Soon',
              disabled: true,
            ),
            _buildAutoManagementToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard({
    required String title,
    String? value,
    String? subtitle,
    bool disabled = false,
  }) {
    return Card(
      elevation: 4.0,
      color: disabled ? Colors.grey[300] : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle ?? ''),
        trailing: Text(
          value ?? '',
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[300],

    );
  }

  Widget _buildAutoManagementToggle() {
    return Consumer<AccountsProvider>(
      builder: (context, accountsProvider, child) {
        return ListTile(
          title: const Text('Auto balance BTC layers'),
          onTap: () {
            accountsProvider.setAutoBalancingCapabilities(
                !accountsProvider.autoBalancing);
          },
          trailing: Switch(
            value: accountsProvider.autoBalancing,
            onChanged: (bool newValue) {
              accountsProvider.setAutoBalancingCapabilities(true);
            },
          ),
        );
      },
    );
  }
}
