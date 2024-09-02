import 'package:Satsails/providers/user_provider.dart';
import 'package:Satsails/screens/receive/components/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserView extends ConsumerWidget {
  const UserView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Black app bar
        title: const Text('User Details', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
      ),
      backgroundColor: Colors.black, // Black background color
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUserDetailRow('Payment ID', user.paymentId),
              const SizedBox(height: 16.0),
              _buildUserDetailRow('Affiliate Code', user.affiliateCode ?? 'N/A'),
              const SizedBox(height: 16.0),
              _buildUserDetailRow('Inserted Affiliate', user.hasInsertedAffiliate ? 'Yes' : 'No'),
              const SizedBox(height: 16.0),
              _buildUserDetailRow('Created Affiliate', user.hasCreatedAffiliate ? 'Yes' : 'No'),
              const SizedBox(height: 16.0),
              _buildUserDetailRow('Recovery Code', user.recoveryCode),
              const SizedBox(height: 24.0),
              Text(
                'Hint: Please store your recovery code somewhere safe. There is no other way to recover your account if you lose this code.',
                style: TextStyle(color: Colors.redAccent, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              CustomElevatedButton(
                onPressed: () {
                  // Add your onPressed code here for updating receive address
                },
                text: "Update Receive Address",
              ),
              const SizedBox(height: 16.0),
              CustomElevatedButton(
                onPressed: () {
                  // Add your onPressed code here for deleting the account
                },
                text: "Delete Account",
                backgroundColor: Colors.redAccent,
              ),
              const SizedBox(height: 16.0),
              CustomElevatedButton(
                onPressed: () {
                  // Navigate to affiliate section
                  Navigator.of(context).pushNamed('/affiliate');
                },
                text: "Go to Affiliate Section",
                backgroundColor: Colors.blueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
