import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satsails_wallet/providers/balance_provider.dart';

class Accounts extends ConsumerWidget {
  const Accounts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Account Management'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05), // Use a relative padding
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
            SizedBox(height: screenWidth * 0.02),
            // _buildAccountCard(
            //   title: 'Savings',
            //   value: ref.watch(balanceProvider).btcBalance.toString(),
            //   context: context,
            // ),
            SizedBox(height: screenWidth * 0.02),
            SizedBox(height: screenWidth * 0.02),
            _buildDivider(),
            SizedBox(height: screenWidth * 0.02),
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Spending',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            _buildAccountCard(
              title: 'Lightning Network',
              context: context,
            ),
            SizedBox(height: screenWidth * 0.02),
            // _buildAccountCard(
            //   title: 'L-BTC',
            //   value: ref.watch(balanceProvider).liquidBalance.toString(),
            //   context: context,
            // ),
            SizedBox(height: screenWidth * 0.02),
            _buildAccountCard(
              title: 'Lightning Network',
              subtitle: 'Coming Soon',
              disabled: true,
              context: context,
            ),
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
    required BuildContext context,
  }) {
    return Card(
      elevation: 4.0,
      color: disabled ? Colors.grey[300] : Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
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
}
